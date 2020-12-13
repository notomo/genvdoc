local CommandParser = require("genvdoc.collector.vim.declaration.command").CommandParser

local M = {}

local DeclarationParser = {}
DeclarationParser.__index = DeclarationParser
M.DeclarationParser = DeclarationParser

function DeclarationParser.new()
  local tbl = {_parsers = {CommandParser}}
  return setmetatable(tbl, DeclarationParser)
end

function DeclarationParser.eat(self, line)
  local tokens = vim.split(line, "%s+")
  for _, parser in ipairs(self._parsers) do
    local declaration = parser:eat(tokens)
    if declaration ~= nil then
      return declaration
    end
  end
  error("parse declaration: " .. line)
end

return M
