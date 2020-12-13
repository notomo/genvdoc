local M = {}

local Separator = {}
Separator.__index = Separator
M.Separator = Separator

function Separator.new(width)
  return "\n" .. ("="):rep(width)
end

return M
