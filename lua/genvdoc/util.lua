local M = {}

function M.help_code_block_from_file(file_path, opts)
  vim.validate({file_path = {file_path, "string"}})
  opts = opts or {}
  opts.include = opts.include or function(_)
    return true
  end
  local f = io.open(file_path, "r")
  local lines = {}
  for line in f:lines() do
    if opts.include(line) then
      table.insert(lines, line)
    end
  end
  f:close()
  local indented = M.indent(table.concat(lines, "\n"), 2)
  return (">\n%s\n<"):format(indented)
end

function M.indent(str, count)
  vim.validate({str = {str, "string"}, count = {count, "number"}})
  local indent = (" "):rep(count)
  local lines = {}
  for _, line in ipairs(vim.split(str, "\n", true)) do
    if line == "" then
      table.insert(lines, line)
    else
      table.insert(lines, ("%s%s"):format(indent, line))
    end
  end
  return table.concat(lines, "\n")
end

function M.help_tagged(ctx, name, tag_name)
  return require("genvdoc.documentor.help.tag").Tag.add(name, ctx.width, tag_name) .. "\n"
end

function M.each_keys_description(keys, descriptions, format_values)
  keys = vim.deepcopy(keys)
  table.sort(keys, function(a, b)
    return a < b
  end)

  format_values = format_values or {}

  local lines = {}
  for _, key in ipairs(keys) do
    local desc = ("- {%s} " .. (descriptions[key] or "Todo")):format(key, vim.inspect(format_values[key]))
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
    table.insert(sections, M.help_tagged(ctx, hl_group, "hl-" .. hl_group) .. M.indent(descriptions[hl_group] or "Todo", 2))
  end
  return table.concat(sections, "\n\n")
end

return M
