local Path = require("genvdoc/lib/path").Path
local Collector = require("genvdoc/collector").Collector
local Documentor = require("genvdoc/documentor").Documentor

local M = {}

--- Generate a document.
function M.generate(plugin_name, opts)
  local nodes = Collector.new(opts.sources):collect()
  local doc = Documentor.new(opts.document_type, opts.chapters):generate(plugin_name, nodes)
  Path.new(opts.output_dir or "./doc/"):join(doc.name):write(doc:build())
end

return M
