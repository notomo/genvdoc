local M = {}

local Tag = {}
Tag.__index = Tag
M.Tag = Tag

function Tag.new(str)
  return ("*%s*"):format(str)
end

function Tag.add(str, width, name)
  local tag_str = name or str
  local tag = Tag.new(tag_str)
  local spaces = (" "):rep(width - #tag - #str)
  return str .. spaces .. tag
end

return M
