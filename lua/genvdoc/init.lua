local pathlib = require("genvdoc.vendor.misclib.path")

local M = {}

--- @class genvdoc_generate_option
--- @field output_dir string? output directory path (default: "./doc/")
--- @field source genvdoc_source_option? |genvdoc_source_option|
--- @field chapters (genvdoc_chapter_option[])? |genvdoc_chapter_option|

--- @class genvdoc_source_option
--- @field patterns string[] glob patterns to collect document source (default: { "lua/**/*.lua" })

--- @class genvdoc_chapter_option
--- @field name string|fun(group:string):string chapter name
--- @field group (fun(node:genvdoc_node):string?)? chapter grouping
--- @field body (fun():string)? returns chapter body string

--- @class genvdoc_node
--- @field declaration genvdoc_declaration?

--- @class genvdoc_declaration
--- @field type "function"|"class"
--- @field module string module name including this declaration

---Generate a document.
---@param plugin_name string: used for document name
---@param opts genvdoc_generate_option? |genvdoc_generate_option|
function M.generate(plugin_name, opts)
  opts = require("genvdoc.option").new(opts)

  local nodes = require("genvdoc.collector").collect(opts.source)
  local document = require("genvdoc.documentor").generate(plugin_name, nodes, opts.chapters)

  local path = pathlib.join(opts.output_dir, document.name)
  require("genvdoc.lib.file").write(path, document:build())
end

return M
