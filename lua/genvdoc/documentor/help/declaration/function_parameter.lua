local Tag = require("genvdoc.documentor.help.tag")
local add_indent = require("genvdoc.documentor.indent").add_indent

local M = {}
M.__index = M

function M.new(declaration)
  local params_except_self = vim.tbl_filter(function(param)
    return param.name ~= "self"
  end, declaration.params)

  local params = vim.tbl_map(function(param)
    return ("{%s}"):format(param.name)
  end, params_except_self)

  local tbl = {
    _declaration = declaration,
    _params_except_self = params_except_self,
    _params = params,
    _has_self = #declaration.params > #params_except_self,
  }
  return setmetatable(tbl, M)
end

function M.tagged_line(self, width)
  local name
  if self._has_self then
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

  for _, param in ipairs(self._params_except_self) do
    local line = ("  {%s} (%s) %s"):format(param.name, param.type, param.descriptions[1])
    table.insert(lines, line)
    vim.list_extend(lines, add_indent(vim.list_slice(param.descriptions, 2), 4))
  end

  return lines
end

return M
