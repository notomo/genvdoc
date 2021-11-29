local Path = require("genvdoc.lib.path").Path
local modulelib = require("genvdoc.lib.module")

local M = {}

local Source = {}
Source.__index = Source
M.Source = Source

function Source.new(setting)
  local source, err = modulelib.find("genvdoc/collector/" .. setting.name)
  if err ~= nil then
    return nil, err
  end

  local tbl = {target_dir = Path.new(setting.target_dir or "."):get(), pattern = setting.pattern}
  local origin = setmetatable(source, Source)
  origin.__index = origin
  return setmetatable(tbl, origin)
end

local Collector = {}
Collector.__index = Collector
M.Collector = Collector

function Collector.new(settings)
  vim.validate({settings = {settings, "table", true}})
  settings = settings or {{name = "lua", pattern = "lua/**/*.lua"}}

  local sources = {}
  for _, setting in ipairs(settings) do
    local source, err = Source.new(setting)
    if err ~= nil then
      return nil, err
    end
    table.insert(sources, source)
  end

  local tbl = {_sources = sources}
  return setmetatable(tbl, Collector), nil
end

function Collector.collect(self)
  local nodes = {}
  for _, source in ipairs(self._sources) do
    vim.list_extend(nodes, source:collect())
  end
  return nodes
end

return M
