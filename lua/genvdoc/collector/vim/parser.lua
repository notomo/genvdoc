local M = {}

local ParseResult = {}
ParseResult.__index = ParseResult

function ParseResult.new()
  local tbl = {lines = {}, declaration = nil}
  return setmetatable(tbl, ParseResult)
end

function ParseResult.merge(self, result)
  if result == nil then
    return
  end
  if result.line then
    table.insert(self.lines, result.line)
  end
  if result.declaration then
    self.declaration = result.declaration
  end
end

local ParseState = {}
ParseState.__index = ParseState

function ParseState.new(stage_name, stages)
  vim.validate({stage_name = {stage_name, "string"}, stages = {stages, "table"}})
  local tbl = {_stage_name = stage_name, _stages = stages}
  return setmetatable(tbl, ParseState)
end

function ParseState.changed(self, stage_name)
  vim.validate({stage_name = {stage_name, "string", true}})
  if stage_name == nil then
    return false
  end
  return self._stage_name ~= stage_name
end

function ParseState.process(self, value)
  local f = self._stages[self._stage_name]
  return f(value)
end

function ParseState.transition(self, stage_name)
  vim.validate({stage_name = {stage_name, "string"}})
  return self.new(stage_name, self._stages)
end

local Parser = {}
Parser.__index = Parser
M.Parser = Parser

function Parser.new(stage_name, stages, iter)
  vim.validate({
    stage_name = {stage_name, "string"},
    stages = {stages, "table"},
    iter = {iter, "function"},
  })
  local state = ParseState.new(stage_name, stages)
  local tbl = {_state = state, _iter = iter, _first_stage = stage_name}
  return setmetatable(tbl, Parser)
end

function Parser.parse(self)
  local node = ParseResult.new()
  local nodes = {}
  for value in self._iter do
    local result, next_stage = self._state:process(value)
    node:merge(result)
    if not self._state:changed(next_stage) then
      goto continue
    end

    local state = self._state:transition(next_stage)
    if next_stage == self._first_stage then
      table.insert(nodes, node)
      node = ParseResult.new()
    end
    self._state = state

    ::continue::
  end

  return nodes
end

return M
