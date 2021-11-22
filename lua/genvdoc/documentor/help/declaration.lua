local Tag = require("genvdoc.documentor.help.tag").Tag

local M = {}

local Declaration = {}
Declaration.__index = Declaration
M.Declaration = Declaration

function Declaration.new(declaration)
  local tbl = {_declaration = declaration}
  return setmetatable(tbl, Declaration)
end

function Declaration.build(self, lines, width)
  local title
  local results = {}
  if self._declaration.type == "command" then
    local name = ":" .. self._declaration.name
    local str = name
    if #self._declaration.params > 0 then
      str = ("%s %s"):format(name, table.concat(self._declaration.params, " "))
    end
    title = Tag.add(str, width, name)
    vim.list_extend(results, lines)
  end
  if self._declaration.type == "method" then
    local has_self_param = self._declaration.params[1] == "self"
    local name
    if has_self_param then
      name = ("%s:%s()"):format(self._declaration.module, self._declaration.name)
    else
      name = ("%s.%s()"):format(self._declaration.module, self._declaration.name)
    end
    local params_except_self = vim.tbl_filter(function(param)
      return param ~= "self"
    end, self._declaration.params)
    local params = vim.tbl_map(function(param)
      return ("{%s}"):format(param)
    end, params_except_self)
    if self._declaration.has_variadic then
      table.insert(params, "{...}")
    end
    local str = ("%s(%s)"):format(self._declaration.name, table.concat(params, ", "))
    title = Tag.add(str, width, name)
    vim.list_extend(results, lines)
    if #params > 0 then
      table.insert(results, "")
      table.insert(results, "Parameters: ~")
    end
    for i, param in ipairs(params_except_self) do
      local comment = self._declaration.param_lines[i] or "TODO"
      local factors = vim.split(comment, "%s+")
      local typ = (factors[2] or "TODO"):gsub(":", "")
      local desc = table.concat(vim.list_slice(factors, 3), " ")
      local line = ("  {%s} (%s) %s"):format(param, typ, desc)
      table.insert(results, line)
    end
    if self._declaration.has_variadic then
      local comment = self._declaration.param_lines[#self._declaration.param_lines] or "TODO"
      local factors = vim.split(comment, "%s+")
      local typ = (factors[1] or "TODO"):gsub(":", "")
      local desc = table.concat(vim.list_slice(factors, 2), " ")
      local line = ("  {%s} (%s) %s"):format("...", typ, desc)
      table.insert(results, line)
    end

    if #self._declaration.returns > 0 then
      table.insert(results, "")
      table.insert(results, "Return: ~")
    end
    for _, ret in ipairs(self._declaration.returns) do
      local factors = vim.split(ret, "%s+")
      local typ = (factors[1] or "TODO"):gsub(":", "")
      local desc = table.concat(vim.list_slice(factors, 2), " ")
      local line = ("  (%s) %s"):format(typ, desc)
      table.insert(results, line)
    end
  end

  results = vim.tbl_map(function(line)
    if line == "" then
      return line
    end
    return ("  %s"):format(line)
  end, results)
  table.insert(results, 1, title)

  return results
end

return M
