local M = {}

local CommentParser = {}
CommentParser.__index = CommentParser
M.CommentParser = CommentParser

function CommentParser.new(comments)
  vim.validate({comments = {comments, "table", true}})
  local tbl = {comments = comments or {}}
  return setmetatable(tbl, CommentParser)
end

function CommentParser.search_head(line)
  local s, e = line:find([[^%s*""%s?]])
  if s == nil then
    return nil, false
  end

  local comment = line:sub(e + 1)
  return CommentParser.new({comment}), true
end

function CommentParser.eat(self, line)
  local s, e = line:find([[^%s*"%s?]])
  if s == nil then
    return false
  end

  local comment = line:sub(e + 1)
  table.insert(self.comments, comment)

  return true
end

return M
