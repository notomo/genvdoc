local M = {}

--- Example1
--- @param arg1 string|nil: description1
--- @vararg any: description2
function M.a(arg1, ...)
  return arg1, ...
end

return M
