local Path = require("genvdoc/lib/path").Path
local Parser = require("genvdoc/collector/vim/parser").Parser
local DeclarationParser = require("genvdoc/collector/vim/declaration").DeclarationParser

local M = {}

local STAGE = {SEARCH = "SEARCH", PARSE = "PARSE"}

local search = function(line)
  local s, e = line:find([[^%s*""%s?]])
  if s == nil then
    return nil
  end

  local comment = line:sub(e + 1)
  return {line = comment}, STAGE.PARSE
end

local parse = function(line)
  local s, e = line:find([[^%s*"%s?]])
  if s == nil then
    local declaration = DeclarationParser.new():eat(line)
    return {declaration = declaration}, STAGE.SEARCH
  end

  local comment = line:sub(e + 1)
  return {line = comment}
end

function M.collect(self)
  local all_nodes = {}
  local stages = {SEARCH = search, PARSE = parse}

  local paths = Path.new(self.target_dir):glob("**/*.vim")
  for _, path in ipairs(paths) do
    local iter = Path.new(path):iter_lines()
    local nodes = Parser.new(STAGE.SEARCH, stages, iter):parse()
    vim.list_extend(all_nodes, nodes)
  end

  return all_nodes
end

return M
