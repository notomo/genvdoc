local Separator = {}
Separator.__index = Separator

function Separator.new(width)
  return "\n" .. ("="):rep(width)
end

return Separator
