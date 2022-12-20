local pathlib = require("genvdoc.vendor.misclib.path")

local M = {}

---Generate a document.
---@param plugin_name string
---@param opts table
function M.generate(plugin_name, opts)
  opts = require("genvdoc.option").new(opts)

  local nodes = require("genvdoc.collector").collect(opts.source)
  local doc = require("genvdoc.documentor").generate(plugin_name, nodes, opts.chapters)

  local path = pathlib.join(opts.output_dir, doc.name)
  vim.fn.mkdir(pathlib.parent(path), "p")
  local f = io.open(path, "w")
  f:write(doc:build())
  f:close()

  return nil
end

return M
