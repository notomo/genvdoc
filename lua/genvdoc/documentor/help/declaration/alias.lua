local Tag = require("genvdoc.documentor.help.tag")
local add_indent = require("genvdoc.documentor.indent").add_indent

local M = {}
M.__index = M

function M.new(declaration)
  local tbl = {
    _declaration = declaration,
  }
  return setmetatable(tbl, M)
end

function M.tagged_line(self, width)
  local name = self._declaration.name
  return Tag.add(name, width, name)
end

function M.build_lines(self, description_lines)
  local names = vim
    .iter(self._declaration.alias_values)
    :map(function(alias_value)
      return alias_value.name
    end)
    :totable()
  local union = "= " .. table.concat(names, " | ")

  local lines = {}
  vim.list_extend(lines, add_indent(vim.deepcopy(description_lines), 2))
  vim.list_extend(lines, add_indent({ union }, 2))
  table.insert(lines, "")

  for _, alias_value in ipairs(self._declaration.alias_values) do
    local line = ("- %s"):format(alias_value.name)
    if alias_value.description then
      line = line .. ": " .. alias_value.description
    end
    table.insert(lines, line)
  end
  return lines
end

return M
