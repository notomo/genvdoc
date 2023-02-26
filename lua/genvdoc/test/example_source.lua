local M = {}

--- Example1
--- @param arg1 string|nil: description1
--- @return string return description
function M.a(arg1)
  return arg1 or ""
end

return M
