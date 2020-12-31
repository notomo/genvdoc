local M = {}

local Result = {}
Result.__index = Result

function Result.new()
  local tbl = {lines = {}, declaration = nil}
  return setmetatable(tbl, Result)
end

function Result.merge(self, result)
  vim.validate({result = {result, "table", true}})
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

local State = {}
State.__index = State

function State.new(stage_name, processor, stages)
  vim.validate({
    stage_name = {stage_name, "string"},
    processor = {processor, "table"},
    stages = {stages, "table"},
  })
  local tbl = {_stage_name = stage_name, _processor = processor, _stages = stages}
  return setmetatable(tbl, State)
end

function State.changed(self, stage_name)
  vim.validate({stage_name = {stage_name, "string", true}})
  if stage_name == nil then
    return false
  end
  return self._stage_name ~= stage_name
end

function State.process(self, values)
  local f = self._stages[self._stage_name]
  return f(self._processor, unpack(values))
end

function State.transition(self, stage_name)
  vim.validate({stage_name = {stage_name, "string"}})
  return self.new(stage_name, self._processor, self._stages)
end

local Parser = {}
Parser.__index = Parser
M.Parser = Parser

function Parser.new(stage_name, processor, stages, iter)
  vim.validate({
    stage_name = {stage_name, "string"},
    processor = {processor, "table"},
    stages = {stages, "table"},
    iter = {iter, "function"},
  })
  local state = State.new(stage_name, processor, stages)
  local tbl = {_state = state, _iter = iter, _first_stage = stage_name}
  return setmetatable(tbl, Parser)
end

function Parser.parse(self)
  local node = Result.new()
  local nodes = {}
  while true do
    local values = {self._iter()}
    if values[1] == nil then
      break
    end

    local result, next_stage = self._state:process(values)
    node:merge(result)
    if not self._state:changed(next_stage) then
      goto continue
    end

    local state = self._state:transition(next_stage)
    if next_stage == self._first_stage then
      table.insert(nodes, node)
      node = Result.new()
    end
    self._state = state

    ::continue::
  end

  return nodes
end

return M
