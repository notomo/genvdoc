local Tag = require("genvdoc.documentor.help.tag")

local M = {}
M.__index = M

function M.new(declaration)
  local params_except_self = vim.tbl_filter(function(param)
    return param ~= "self"
  end, declaration.params)

  local params = vim.tbl_map(function(param)
    return ("{%s}"):format(param)
  end, params_except_self)
  if declaration.has_variadic then
    table.insert(params, "{...}")
  end

  local tbl = {
    _declaration = declaration,
    _params_except_self = params_except_self,
    _params = params,
  }
  return setmetatable(tbl, M)
end

function M.tagged_line(self, width)
  local has_self_param = self._declaration.params[1] == "self"
  local name
  if has_self_param then
    name = ("%s:%s()"):format(self._declaration.module, self._declaration.name)
  else
    name = ("%s.%s()"):format(self._declaration.module, self._declaration.name)
  end
  local str = ("%s(%s)"):format(self._declaration.name, table.concat(self._params, ", "))
  return Tag.add(str, width, name)
end

function M.build_lines(self, description_lines)
  local lines = vim.deepcopy(description_lines)
  if #self._params > 0 then
    table.insert(lines, "")
    table.insert(lines, "Parameters: ~")
  end

  for i, param in ipairs(self._params_except_self) do
    local comment = self._declaration.param_lines[i] or "TODO"
    local factors = vim.split(comment, "%s+")
    local typ = (factors[2] or "TODO"):gsub(":", "")
    local desc = table.concat(vim.list_slice(factors, 3), " ")
    local line = ("  {%s} (%s) %s"):format(param, typ, desc)
    table.insert(lines, line)
  end

  if self._declaration.has_variadic then
    local comment = self._declaration.param_lines[#self._declaration.param_lines] or "TODO"
    local factors = vim.split(comment, "%s+")
    local typ = (factors[1] or "TODO"):gsub(":", "")
    local desc = table.concat(vim.list_slice(factors, 2), " ")
    local line = ("  {%s} (%s) %s"):format("...", typ, desc)
    table.insert(lines, line)
  end

  return lines
end

return M
