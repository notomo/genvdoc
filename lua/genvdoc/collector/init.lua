local M = {}

local Source = {}
Source.__index = Source
M.Source = Source

function Source.new(opts)
  local tbl = {target_dir = vim.fn.fnamemodify(opts.target_dir or ".", ":p")}
  local origin = setmetatable(require("genvdoc/collector/" .. opts.name), Source)
  origin.__index = origin
  return setmetatable(tbl, origin)
end

local Collector = {}
Collector.__index = Collector
M.Collector = Collector

function Collector.new(source_opts)
  vim.validate({source_opts = {source_opts, "table", true}})
  source_opts = source_opts or {{name = "vim"}, {name = "lua"}}
  local tbl = {
    _sources = vim.tbl_map(function(opts)
      return Source.new(opts)
    end, source_opts),
  }
  return setmetatable(tbl, Collector)
end

function Collector.collect(self)
  local nodes = {}
  for _, source in ipairs(self._sources) do
    vim.list_extend(nodes, source:collect())
  end
  return nodes
end

return M
