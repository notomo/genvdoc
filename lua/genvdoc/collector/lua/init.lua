local pathlib = require("genvdoc.vendor.misclib.path")
local Modules = require("genvdoc.collector.lua.module")

local M = {}

function M.collect(pattern)
  local query = vim.treesitter.parse_query(
    "lua",
    [[
((comment) @comment (match? @comment "^---"))
(function_declaration
  name: (_ field: (identifier) @method)
  parameters: (_ name: (identifier) @param)
)
]]
  )

  local modules = Modules.new(".")
  local current_path = vim.fn.fnamemodify(".", ":p")
  local full_pattern = pathlib.join(current_path, pattern)
  local paths = vim.fn.glob(full_pattern, true, true)

  local all_nodes = {}
  for _, path in ipairs(paths) do
    local nodes = M._parse(query, modules, path)
    vim.list_extend(all_nodes, nodes)
  end
  return all_nodes
end

function M._parse(query, modules, path)
  local str, err = require("genvdoc.lib.file").read_all(path)
  if err then
    error(err)
  end

  local parser = vim.treesitter.get_string_parser(str, "lua")
  local trees, _ = parser:parse()

  local ctx = {
    query = query,
    module_name = modules:from_path(path),
    str = str,
    iterator = require("genvdoc.collector.iterator").new(query:iter_captures(trees[1]:root(), str, 0, -1)),
    results = {},
  }
  while true do
    local result = {
      lines = {},
      declaration = {
        params = {},
        param_lines = {},
        returns = {},
        has_variadic = false,
      },
    }
    local ok = M._parse_comment(ctx, result)
    if not ok then
      break
    end
  end
  return ctx.results
end

local parse_comment = function(text)
  local _, e = text:find([[^%s*%-%-%-%s?]])
  return text:sub(e + 1)
end

function M._parse_comment(ctx, result)
  local id, node = ctx.iterator:next()
  if not id then
    return false
  end

  local capture_name = ctx.query.captures[id]
  local text = vim.treesitter.query.get_node_text(node, ctx.str)

  if capture_name == "comment" then
    local comment = parse_comment(text)
    table.insert(result.lines, comment)
    return M._search_declaration(ctx, result)
  end

  return true
end

local parse_annotation = function(name, comment)
  if not vim.startswith(comment, "@" .. name .. " ") then
    return nil
  end

  local pattern = "^@" .. name .. "%s+"
  local _, e = comment:find(pattern)
  return comment:sub(e + 1)
end

function M._search_declaration(ctx, result)
  local id, node = ctx.iterator:next()
  if not id then
    return false
  end

  local capture_name = ctx.query.captures[id]
  local text = vim.treesitter.query.get_node_text(node, ctx.str)

  if capture_name == "method" then
    result.declaration.name = text
    result.declaration.type = "method"
    result.declaration.module = ctx.module_name
    return M._parse_declaration(ctx, result)
  end

  if capture_name == "comment" then
    local comment = parse_comment(text)

    local param = parse_annotation("param", comment)
    if param then
      table.insert(result.declaration.param_lines, param)
      return M._search_declaration(ctx, result)
    end

    local vararg = parse_annotation("vararg", comment)
    if vararg then
      result.declaration.has_variadic = true
      table.insert(result.declaration.param_lines, vararg)
      return M._search_declaration(ctx, result)
    end

    local return_ = parse_annotation("return", comment)
    if return_ then
      table.insert(result.declaration.returns, return_)
      return M._search_declaration(ctx, result)
    end

    table.insert(result.lines, comment)
    return M._search_declaration(ctx, result)
  end

  return true
end

function M._parse_declaration(ctx, result)
  local id, node = ctx.iterator:next()
  if not id then
    table.insert(ctx.results, result)
    return false
  end

  local capture_name = ctx.query.captures[id]
  local text = vim.treesitter.query.get_node_text(node, ctx.str)

  if capture_name == "param" then
    table.insert(result.declaration.params, text)
    return M._parse_declaration(ctx, result)
  end

  table.insert(ctx.results, result)
  ctx.iterator:back()

  return true
end

return M
