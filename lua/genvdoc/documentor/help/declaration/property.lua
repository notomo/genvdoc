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

function M.build_lines(_, description_lines)
  return add_indent(vim.deepcopy(description_lines), 2)
end

return M
