local M = {}

local Result = {}
Result.__index = Result

function Result.new()
  local tbl = {lines = {}, declaration = {params = {}, param_lines = {}}}
  return setmetatable(tbl, Result)
end

local function merge(origin, result)
  for key, value in pairs(result) do
    local v = origin[key]
    if vim.tbl_islist(v) then
      if vim.tbl_islist(value) then
        vim.list_extend(v, value)
      else
        table.insert(v, value)
      end
    elseif type(v) == "table" then
      merge(v, value)
    else
      origin[key] = value
    end
  end
end

function Result.merge(self, result)
  vim.validate({result = {result, "table", true}})
  if result == nil then
    return
  end
  merge(self, result)
end

local State = {}
State.__index = State

function State.new(stage_name, processor, stages)
  vim.validate({
    stage_name = {stage_name, "string"},
    processor = {processor, "table"},
    stages = {stages, "table"},
  })
  local tbl = {stage_name = stage_name, _processor = processor, _stages = stages}
  return setmetatable(tbl, State)
end

function State.changed(self, stage_name)
  vim.validate({stage_name = {stage_name, "string", true}})
  if stage_name == nil then
    return false
  end
  return self.stage_name ~= stage_name
end

function State.process(self, values)
  local f = self._stages[self.stage_name]
  return f(self._processor, unpack(values))
end

function State.transition(self, stage_name)
  vim.validate({stage_name = {stage_name, "string"}})
  return self.new(stage_name, self._processor, self._stages)
end

local Parser = {}
Parser.__index = Parser
M.Parser = Parser

function Parser.new(first_stage_name, completed_stage_names, processor, stages, iter)
  vim.validate({
    first_stage_name = {first_stage_name, "string"},
    completed_stage_names = {completed_stage_names, "table"},
    processor = {processor, "table"},
    stages = {stages, "table"},
    iter = {iter, "function"},
  })
  local state = State.new(first_stage_name, processor, stages)
  local tbl = {
    _state = state,
    _iter = iter,
    _first_stage = first_stage_name,
    _completed_stage_names = completed_stage_names,
  }
  return setmetatable(tbl, Parser)
end

function Parser.parse(self)
  local node = Result.new()
  local nodes = {}
  local values = {}
  local stop_iter = false
  while true do
    if not stop_iter then
      values = {self._iter()}
    end

    if values[1] == nil then
      break
    end

    local result, next_stage, stop = self._state:process(values)
    stop_iter = stop
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

  if vim.tbl_contains(self._completed_stage_names, self._state.stage_name) then
    table.insert(nodes, node)
  end

  return nodes
end

return M
