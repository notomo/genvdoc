local Path = require("genvdoc/lib/path").Path
local Parser = require("genvdoc/collector/parser").Parser
local DeclarationParser = require("genvdoc/collector/vim/declaration").DeclarationParser

local M = {}

local Processor = {}
Processor.__index = Processor
Processor.STAGE = {SEARCH = "SEARCH", PARSE = "PARSE"}
Processor.FIRST_STAGE = Processor.STAGE.SEARCH
Processor.COMPLETE_STAGE = {}

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
  return {lines = comment}, self.STAGE.PARSE
end

function Processor.parse(self, line)
  local s, e = line:find([[^%s*"%s?]])
  if s == nil then
    local declaration = DeclarationParser.new():parse(line)
    return {declaration = declaration}, self.STAGE.SEARCH
  end

  local comment = line:sub(e + 1)
  return {lines = comment}
end

Processor.STAGES = {
  [Processor.STAGE.SEARCH] = Processor.search,
  [Processor.STAGE.PARSE] = Processor.parse,
}

function M.collect(self)
  local all_nodes = {}

  local processor = Processor.new()
  local paths = Path.new(self.target_dir):glob("**/*.vim")
  for _, path in ipairs(paths) do
    local iter = Path.new(path):iter_lines()
    local nodes = Parser.new(processor, iter):parse()
    vim.list_extend(all_nodes, nodes)
  end

  return all_nodes
end

return M
