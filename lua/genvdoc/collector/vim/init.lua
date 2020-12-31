local Path = require("genvdoc/lib/path").Path
local Parser = require("genvdoc/collector/parser").Parser
local DeclarationParser = require("genvdoc/collector/vim/declaration").DeclarationParser

local M = {}

local Processor = {}
Processor.__index = Processor
Processor.STAGE = {SEARCH = "SEARCH", PARSE = "PARSE"}

function Processor.new()
  local tbl = {}
  return setmetatable(tbl, Processor)
end

function Processor.search(self, line)
  local s, e = line:find([[^%s*""%s?]])
  if s == nil then
    return nil
  end

  local comment = line:sub(e + 1)
  return {line = comment}, self.STAGE.PARSE
end

function Processor.parse(self, line)
  local s, e = line:find([[^%s*"%s?]])
  if s == nil then
    local declaration = DeclarationParser.new():eat(line)
    return {declaration = declaration}, self.STAGE.SEARCH
  end

  local comment = line:sub(e + 1)
  return {line = comment}
end

function M.collect(self)
  local all_nodes = {}

  local processor = Processor.new()
  local stages = {
    [processor.STAGE.SEARCH] = processor.search,
    [processor.STAGE.PARSE] = processor.parse,
  }

  local paths = Path.new(self.target_dir):glob("**/*.vim")
  for _, path in ipairs(paths) do
    local iter = Path.new(path):iter_lines()
    local nodes = Parser.new(processor.STAGE.SEARCH, processor, stages, iter):parse()
    vim.list_extend(all_nodes, nodes)
  end

  return all_nodes
end

return M
