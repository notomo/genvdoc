local M = {}

local Tag = {}
Tag.__index = Tag
M.Tag = Tag

function Tag.new(str)
  return ("*%s*"):format(str)
end

function Tag.add(str, width, name)
  local tag_str = name or str
  local tag = Tag.new(tag_str:gsub("%s+", "-"))
  local count = width - #tag - #str
  local spaces
  if count > 0 then
    spaces = (" "):rep(count)
  else
    spaces = "\n" .. (" "):rep(width - #tag)
  end
  return str .. spaces .. tag
end

return M
