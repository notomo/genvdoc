local Tag = require("genvdoc.documentor.help.tag")
local add_indent = require("genvdoc.documentor.indent").add_indent

local M = {}
M.__index = M

function M.new(declaration)
  local params_except_self = vim
    .iter(declaration.params)
    :filter(function(param)
      return param.name ~= "self"
    end)
    :totable()

  local params = vim
    .iter(params_except_self)
    :map(function(param)
      return ("{%s}"):format(param.name)
    end)
    :totable()

  local tbl = {
    _declaration = declaration,
    _params_except_self = params_except_self,
    _params = params,
    _has_self = #declaration.params > #params_except_self,
  }
  return setmetatable(tbl, M)
end

function M.tagged_line(self, width)
  local module_tail = vim.iter(vim.split(self._declaration.module, ".", { plain = true })):last()
  local namespace = vim
    .iter(self._declaration.method_tables)
    :filter(function(x)
      return x ~= "M" and string.lower(x) ~= module_tail
    end)
    :join(".")

  local name_path = vim
    .iter({ namespace, self._declaration.name })
    :filter(function(x)
      return x ~= ""
    end)
    :join(".")

  local path = vim
    .iter({ self._declaration.module, namespace })
    :filter(function(x)
      return x ~= ""
    end)
    :join(".")

  local name, str
  if self._declaration.name then
    if self._has_self then
      name = ("%s:%s()"):format(path, self._declaration.name)
    else
      name = ("%s.%s()"):format(path, self._declaration.name)
    end
    str = ("%s(%s)"):format(name_path, table.concat(self._params, ", "))
  else
    name = ("%s()"):format(path)
    local splitted = vim.split(self._declaration.module, ".", { plain = true })
    local tail = splitted[#splitted]
    str = ("%s(%s)"):format(tail, table.concat(self._params, ", "))
  end
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
