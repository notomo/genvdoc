local Path = require("genvdoc.lib.path").Path

local M = {}

---Generate a document.
---@param plugin_name string
---@param opts table
function M.generate(plugin_name, opts)
  opts = require("genvdoc.option").new(opts)

  local nodes = require("genvdoc.collector").collect(opts.source)
  local doc = require("genvdoc.documentor").generate(plugin_name, nodes, opts.chapters)

  Path.new(opts.output_dir):join(doc.name):write(doc:build())

  return nil
end

return M
