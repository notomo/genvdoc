local Path = require("genvdoc/lib/path").Path
local Collector = require("genvdoc/collector").Collector
local Documentor = require("genvdoc/documentor").Documentor

local M = {}

--- Generate a document.
function M.generate(plugin_name, opts)
  local collector, c_err = Collector.new(opts.sources)
  if c_err ~= nil then
    return c_err
  end

  local documentor, d_err = Documentor.new(opts.document_type, opts.chapters)
  if d_err ~= nil then
    return d_err
  end

  local nodes = collector:collect()
  local doc = documentor:generate(plugin_name, nodes)
  Path.new(opts.output_dir or "./doc/"):join(doc.name):write(doc:build())

  return nil
end

return M
