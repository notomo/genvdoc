local pathlib = require("genvdoc.vendor.misclib.path")
local Modules = require("genvdoc.collector.lua.module")

local M = {}

function M.collect(pattern)
  local query = vim.treesitter.query.parse_query(
    "lua",
    [[
((comment) @comment (match? @comment "^---"))
(function_declaration
  name: (_ field: (identifier) @function)
  parameters: (_ name: (identifier) @param)
)
(function_definition
  parameters: (_ name: (identifier) @param)
) @anonymous_function
(assignment_statement
  (variable_list
    name: (dot_index_expression
      field: (identifier) @property
    )
  )
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

  local module_name = modules:from_path(path)
  local iterator = require("genvdoc.collector.iterator").new(query:iter_captures(trees[1]:root(), str, 0, -1))
  local current_node, last_node
  local ctx = {
    iterator_next = function()
      local id, node = iterator:next()
      last_node = current_node
      current_node = node
      return id, node
    end,
    iterator_back = function()
      return iterator:back()
    end,
    is_continuous_line = function(node)
      if not last_node then
        return true
      end
      local first_row = node:start()
      local last_row = last_node:end_()
      return first_row <= last_row + 1
    end,
    get_node_text = function(node)
      return vim.treesitter.query.get_node_text(node, str)
    end,
    get_capture_name = function(id)
      return query.captures[id]
    end,
    results = {},
  }
  while true do
    local result = {
      lines = {},
      declaration = {
        module = module_name,
        name = nil,
        type = nil,

        -- type: function
        params = {},
        returns = {},

        -- type: class
        fields = {},

        -- type: alias
        alias_values = {},
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

local is_annotation = function(comment)
  return vim.startswith(comment, "@")
end

function M._parse_comment(ctx, result)
  local id, node = ctx.iterator_next()
  if not id then
    return false
  end
  if not ctx.is_continuous_line(node) then
    ctx.iterator_back()
    return true
  end

  local capture_name = ctx.get_capture_name(id)
  local text = ctx.get_node_text(node)

  if capture_name == "comment" then
    local comment = parse_comment(text)

    if is_annotation(comment) then
      ctx.iterator_back()
      return M._search_declaration(ctx, result)
    end

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

local new_parameter = function(name, typ, description)
  return {
    name = name,
    type = typ,
    descriptions = { description },
  }
end

local parse_param_line = function(line)
  local factors = vim.split(line, "%s+")
  local typ = (factors[2] or "TODO"):gsub(":$", "")
  local description = table.concat(vim.list_slice(factors, 3), " ")
  return new_parameter(factors[1], typ, description)
end

local parse_return_line = function(line)
  local factors = vim.split(line, "%s+")
  local typ = (factors[1] or "TODO"):gsub(":$", "")
  local description = table.concat(vim.list_slice(factors, 2), " ")
  return {
    type = typ,
    descriptions = { description },
  }
end

local field_scopes = {
  "private",
  "protected",
  "public",
  "package",
}

local parse_field_line = function(line)
  local factors = vim.split(line, "%s+")

  local scope, name, type_index
  if not vim.tbl_contains(field_scopes, factors[1]) then
    scope = "public"
    name = factors[1]
    type_index = 2
  else
    scope = factors[1]
    name = factors[2]
    type_index = 3
  end

  local typ = (factors[type_index] or "TODO"):gsub(":$", "")
  local description = table.concat(vim.list_slice(factors, type_index + 1), " ")
  if description == "" then
    description = nil
  end

  return {
    name = name,
    scope = scope,
    type = typ,
    descriptions = { description },
  }
end

function M._search_declaration(ctx, result)
  local id, node = ctx.iterator_next()
  if not id then
    return false
  end
  if not ctx.is_continuous_line(node) then
    ctx.iterator_back()
    return true
  end

  local capture_name = ctx.get_capture_name(id)
  local text = ctx.get_node_text(node)

  if capture_name == "function" then
    result.declaration.name = text
    result.declaration.type = "function"
    return M._parse_declaration(ctx, result)
  end

  if capture_name == "anonymous_function" then
    result.declaration.type = "anonymous_function"
    return M._parse_declaration(ctx, result)
  end

  if capture_name == "property" then
    result.declaration.name = text
    result.declaration.type = "property"
    table.insert(ctx.results, result)
    return true
  end

  if capture_name == "comment" then
    local comment = parse_comment(text)

    local class_name = parse_annotation("class", comment)
    if class_name then
      result.declaration.name = class_name
      result.declaration.type = "class"
      return M._collect_class_fields(ctx, result)
    end

    local param_line = parse_annotation("param", comment)
    if param_line then
      local param = parse_param_line(param_line)
      table.insert(result.declaration.params, param)
      return M._collect_declaration_description(ctx, result, function(description)
        table.insert(param.descriptions, description)
      end)
    end

    local return_line = parse_annotation("return", comment)
    if return_line then
      local return_ = parse_return_line(return_line)
      table.insert(result.declaration.returns, return_)
      return M._collect_declaration_description(ctx, result, function(description)
        table.insert(return_.descriptions, description)
      end)
    end

    local alias_name = parse_annotation("alias", comment)
    if alias_name then
      result.declaration.name = alias_name
      result.declaration.type = "alias"
      return M._collect_alias_values(ctx, result, function(alias_value)
        table.insert(result.declaration.alias_values, alias_value)
      end)
    end

    table.insert(result.lines, comment)
    return M._search_declaration(ctx, result)
  end

  return true
end

function M._collect_declaration_description(ctx, result, add_description)
  local id, node = ctx.iterator_next()
  if not id then
    return false
  end
  if not ctx.is_continuous_line(node) then
    ctx.iterator_back()
    return true
  end

  local capture_name = ctx.get_capture_name(id)
  local text = ctx.get_node_text(node)

  if capture_name == "comment" then
    local comment = parse_comment(text)
    if not is_annotation(comment) then
      add_description(comment)
      return M._collect_declaration_description(ctx, result, add_description)
    end
  end

  ctx.iterator_back()

  return M._search_declaration(ctx, result)
end

function M._collect_class_fields(ctx, result, add_description)
  local id, node = ctx.iterator_next()
  if not id then
    table.insert(ctx.results, result)
    return false
  end
  if not ctx.is_continuous_line(node) then
    table.insert(ctx.results, result)
    ctx.iterator_back()
    return true
  end

  local capture_name = ctx.get_capture_name(id)
  local text = ctx.get_node_text(node)

  if capture_name == "comment" then
    local comment = parse_comment(text)

    local field_line = parse_annotation("field", comment)
    if field_line then
      local field = parse_field_line(field_line)
      table.insert(result.declaration.fields, field)
      return M._collect_class_fields(ctx, result, function(description)
        table.insert(field.descriptions, description)
      end)
    end

    add_description(comment)
    return M._collect_class_fields(ctx, result, add_description)
  end

  table.insert(ctx.results, result)
  ctx.iterator_back()

  return true
end

function M._parse_declaration(ctx, result)
  local id, node = ctx.iterator_next()
  if not id then
    table.insert(ctx.results, result)
    return false
  end

  local capture_name = ctx.get_capture_name(id)
  local text = ctx.get_node_text(node)

  if capture_name == "param" then
    if text == "self" then
      local param = new_parameter("self", "self")
      table.insert(result.declaration.params, 1, param)
    end
    return M._parse_declaration(ctx, result)
  end

  table.insert(ctx.results, result)
  ctx.iterator_back()

  return true
end

local parse_alias_value = function(line)
  local name, description = line:match([[^| '([^']+)' # (.*)]])
  if not name then
    return nil
  end
  return {
    name = name,
    description = description,
  }
end

function M._collect_alias_values(ctx, result, add_alias_value)
  local id, node = ctx.iterator_next()
  if not id then
    table.insert(ctx.results, result)
    return false
  end
  if not ctx.is_continuous_line(node) then
    table.insert(ctx.results, result)
    ctx.iterator_back()
    return true
  end

  local capture_name = ctx.get_capture_name(id)
  local text = ctx.get_node_text(node)

  if capture_name == "comment" then
    local comment = parse_comment(text)
    local alias_value = parse_alias_value(comment)
    if alias_value then
      add_alias_value(alias_value)
      return M._collect_alias_values(ctx, result, add_alias_value)
    end
  end

  table.insert(ctx.results, result)
  ctx.iterator_back()

  return false
end

return M
