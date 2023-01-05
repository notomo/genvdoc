local add_indent = require("genvdoc.documentor.indent").add_indent

local M = {}

function M.build_lines(declaration)
  local lines = {}
  if #declaration.returns > 0 then
    table.insert(lines, "")
    table.insert(lines, "Return: ~")
  end
  for _, ret in ipairs(declaration.returns) do
    local line = ("  (%s) %s"):format(ret.type, ret.descriptions[1])
    table.insert(lines, line)
    vim.list_extend(lines, add_indent(vim.list_slice(ret.descriptions, 2), 4))
  end
  return lines
end

return M
