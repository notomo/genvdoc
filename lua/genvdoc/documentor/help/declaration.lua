local Tag = require("genvdoc/documentor/help/tag").Tag

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
    local name = ("%s.%s()"):format(self._declaration.module, self._declaration.name)
    local params = vim.tbl_map(function(param)
      return ("{%s}"):format(param)
    end, self._declaration.params)
    local str = ("%s(%s)"):format(self._declaration.name, table.concat(params, ", "))
    title = Tag.add(str, width, name)
    vim.list_extend(results, lines)
    if #self._declaration.params > 0 then
      table.insert(results, "")
      table.insert(results, "Parameters: ~")
    end
    for i, param in ipairs(self._declaration.params) do
      local comment = self._declaration.param_lines[i] or "TODO"
      local factors = vim.split(comment, "%s+")
      local typ = (factors[2] or "TODO"):gsub(":", "")
      local desc = table.concat(vim.list_slice(factors, 3), " ")
      local line = ("  {%s} (%s) %s"):format(param, typ, desc)
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
