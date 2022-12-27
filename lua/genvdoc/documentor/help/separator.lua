local Separator = {}

function Separator.new(width)
  return "\n" .. ("="):rep(width)
end

return Separator
