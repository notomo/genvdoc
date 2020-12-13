local Path = require("genvdoc/lib/path").Path
local DeclarationParser = require("genvdoc/collector/vim/declaration").DeclarationParser
local CommentParser = require("genvdoc/collector/vim/comment").CommentParser

local M = {}

local Parser = {}
Parser.__index = Parser

function Parser.new()
  local tbl = {results = {}, _comment_parser = nil, _declaration_parser = DeclarationParser.new()}
  return setmetatable(tbl, Parser)
end

function Parser.eat(self, line)
  if self._comment_parser == nil then
    local comment_parser, ok = CommentParser.search_head(line)
    if ok then
      self._comment_parser = comment_parser
    end
    return
  end

  if not self._comment_parser:eat(line) then
    local declaration = self._declaration_parser:eat(line)
    table.insert(self.results, {lines = self._comment_parser.comments, declaration = declaration})
    self._comment_parser = nil
  end
end

function M.collect(self)
  local pattern = Path.new(self.target_dir):join("**/*.vim"):get()
  local paths = vim.fn.glob(pattern, true, true)

  local results = {}
  for _, path in ipairs(paths) do
    local f = io.open(path, "r")
    local parser = Parser.new()
    for line in f:lines() do
      parser:eat(line)
    end
    f:close()
    vim.list_extend(results, parser.results)
  end
  return results
end

return M
