local Tag = {}

function Tag.new(str)
  return ("*%s*"):format(str)
end

function Tag.add(line, width, tag_name)
  local tag = Tag.new(tag_name:gsub("%s+", "-"))

  if width > #tag + #line then
    local spaces = (" "):rep(width - #tag - #line)
    return line .. spaces .. tag
  end

  local spaces = (" "):rep(width - #tag)
  return line .. "\n" .. spaces .. tag
end

return Tag
