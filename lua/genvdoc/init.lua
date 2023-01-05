local pathlib = require("genvdoc.vendor.misclib.path")

local M = {}

---Generate a document.
---@param plugin_name string: used for document name
---@param opts table|nil:
---  {
---    output_dir = (string),
---    source = { patterns = string[] },
---    chapters = {
---      name = (string|function),
---      group = (function|nil),
---      body = (function|nil)
---    }[]
---  }
function M.generate(plugin_name, opts)
  opts = require("genvdoc.option").new(opts)

  local nodes = require("genvdoc.collector").collect(opts.source)
  local document = require("genvdoc.documentor").generate(plugin_name, nodes, opts.chapters)

  local path = pathlib.join(opts.output_dir, document.name)
  require("genvdoc.lib.file").write(path, document:build())
end

return M
