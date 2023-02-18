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
  local name = ("%s.%s"):format(self._declaration.module, self._declaration.name)
  return Tag.add(self._declaration.name, width, name)
end

function M.build_lines(self)
  local lines = {
    "",
  }
  for _, field in ipairs(self._declaration.fields) do
    local line = ("- {%s} (%s)"):format(field.name, field.type)
    if field.descriptions[1] then
      line = line .. " " .. field.descriptions[1]
    end
    table.insert(lines, line)
    vim.list_extend(lines, add_indent(vim.list_slice(field.descriptions, 2), 2))
  end
  return lines
end

return M
