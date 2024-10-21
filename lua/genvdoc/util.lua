local M = {}

--- Returns help code block using file.
--- @param file_path string: used for code block
--- @param opts table|nil: default {language = nil}
function M.help_code_block_from_file(file_path, opts)
  opts = opts or {}
  opts.include = opts.include or function(_)
    return true
  end

  local f = io.open(file_path, "r")
  if not f then
    error("failed to open: " .. file_path)
  end

  local lines = {}
  for line in f:lines() do
    if opts.include(line) then
      table.insert(lines, line)
    end
  end
  f:close()
  local str = table.concat(lines, "\n")
  return M.help_code_block(str, opts)
end

--- Returns help code block using string.
--- @param str string: used for code block
--- @param opts table|nil: default {language = ""}
function M.help_code_block(str, opts)
  opts = opts or {}
  opts.language = opts.language or ""
  local indented = M.indent(str, 2)
  return (">%s\n%s\n<"):format(opts.language, indented)
end

--- @param str string
--- @param count integer
function M.indent(str, count)
  local indent = (" "):rep(count)
  local lines = {}
  for _, line in ipairs(vim.split(str, "\n", { plain = true })) do
    if line == "" then
      table.insert(lines, line)
    else
      table.insert(lines, ("%s%s"):format(indent, line))
    end
  end
  return table.concat(lines, "\n")
end

function M.help_tagged(ctx, name, tag_name)
  return require("genvdoc.documentor.help.tag").add(name, ctx.width, tag_name) .. "\n"
end

function M.each_keys_description(keys, descriptions, format_values)
  keys = vim.deepcopy(keys)
  table.sort(keys, function(a, b)
    return a < b
  end)

  format_values = format_values or {}

  local lines = {}
  for _, key in ipairs(keys) do
    local description = descriptions[key]

    local text
    if type(description) == "table" then
      local children_descriptions = description.children or {}
      local children_keys = vim.tbl_keys(children_descriptions)
      local children_format_values = format_values[key] or {}
      local children_lines = M.each_keys_description(children_keys, children_descriptions, children_format_values)
      text = description.text .. "\n" .. M.indent(table.concat(children_lines, "\n"), 2)
    else
      text = description
    end
    text = text or "Todo"

    local desc = ("- {%s} " .. text):format(key, vim.inspect(format_values[key]))
    table.insert(lines, desc)
  end
  return lines
end

function M.sections(ctx, sections)
  local contents = {}
  for _, section in ipairs(sections) do
    local tag = M.help_tagged(ctx, section.name, ("%s-%s"):format(ctx.plugin_name, section.tag_name))
    table.insert(contents, tag .. "\n" .. section.text)
  end
  return table.concat(contents, "\n\n")
end

function M.hl_group_sections(ctx, names, descriptions)
  local sections = {}
  for _, hl_group in ipairs(names) do
    table.insert(
      sections,
      M.help_tagged(ctx, hl_group, "hl-" .. hl_group) .. M.indent(descriptions[hl_group] or "Todo", 2)
    )
  end
  return table.concat(sections, "\n\n")
end

function M.read_all(path)
  local str = require("genvdoc.lib.file").read_all(path)
  if type(str) == "table" then
    local err = str
    error(err.message)
  end
  return str
end

function M.write(path, str)
  require("genvdoc.lib.file").write(path, str)
end

function M.extract_variable_as_text(path, variable_name, opts)
  opts = opts or {}
  local target_node_name = opts.target_node or "variable_declaration"

  local str = M.read_all(path)

  local query = vim.treesitter.query.parse(
    "lua",
    ([[
(variable_declaration
  (assignment_statement
    (variable_list
        name: (_) @name (#match? @name "^%s$")
    ) @variable_list
    (expression_list) @expression_list
  ) @assignment_statement
) @variable_declaration
]]):format(variable_name)
  )

  local parser = vim.treesitter.get_string_parser(str, "lua")
  local trees = parser:parse()
  local root = trees[1]:root()
  local _, match = query:iter_matches(root, str, 0, -1)()

  local target_node
  for id, nodes in pairs(match) do
    for _, node in pairs(nodes) do
      local captured = query.captures[id]
      if captured == target_node_name then
        target_node = node
        break
      end
    end
  end

  return vim.treesitter.get_node_text(target_node, str)
end

function M.execute(str)
  local f, err = loadstring(str)
  if err then
    error(err)
  end
  ---@diagnostic disable-next-line: need-check-nil
  return f()
end

function M.extract_documented_table(path)
  local str = M.read_all(path)

  local query = vim.treesitter.query.parse(
    "lua",
    [[
  (
    (comment content: (comment_content) @document)
    .
    (field
      name: (_) @key
      value: (_) @value
    )
  )
]]
  )

  local parser = vim.treesitter.get_string_parser(str, "lua")
  local trees = parser:parse()
  local root = trees[1]:root()

  local list = {}
  for _, match in query:iter_matches(root, str, 0, -1) do
    local extracted = require("genvdoc.vendor.misclib.treesitter").get_captures(match, query, function(tbl, key, node)
      tbl[key] = vim.treesitter.get_node_text(node, str)
    end)
    table.insert(list, extracted)
  end
  return list
end

return M
