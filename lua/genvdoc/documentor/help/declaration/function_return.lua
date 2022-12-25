local M = {}

function M.build_lines(declaration)
  local lines = {}
  if #declaration.returns > 0 then
    table.insert(lines, "")
    table.insert(lines, "Return: ~")
  end
  for _, ret in ipairs(declaration.returns) do
    local factors = vim.split(ret, "%s+")
    local typ = (factors[1] or "TODO"):gsub(":", "")
    local desc = table.concat(vim.list_slice(factors, 2), " ")
    local line = ("  (%s) %s"):format(typ, desc)
    table.insert(lines, line)
  end
  return lines
end

return M
