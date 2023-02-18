local pathlib = require("genvdoc.vendor.misclib.path")

local M = {}

--- @class GenerateOption
--- @field output_dir string? output directory path (default: "./doc/")
--- @field source GenerateSource? |genvdoc.GenerateSource|
--- @field chapters (GenerateChapter[])? |genvdoc.GenerateChapter|

--- @class GenerateSource
--- @field patterns string[] glob patterns to collect document source (default: { "lua/**/*.lua" })

--- @class GenerateChapter
--- @field name string|fun(group:string):string chapter name
--- @field group (fun(node:GenvdocNode):string?)? chapter grouping
--- @field body (fun():string)? returns chapter body string

--- @class GenvdocNode
--- @field declaration GenvdocDeclaration?

--- @class GenvdocDeclaration
--- @field type "function"|"class"
--- @field module string module name including this declaration

---Generate a document.
---@param plugin_name string: used for document name
---@param opts GenerateOption? |genvdoc.GenerateOption|
function M.generate(plugin_name, opts)
  opts = require("genvdoc.option").new(opts)

  local nodes = require("genvdoc.collector").collect(opts.source)
  local document = require("genvdoc.documentor").generate(plugin_name, nodes, opts.chapters)

  local path = pathlib.join(opts.output_dir, document.name)
  require("genvdoc.lib.file").write(path, document:build())
end

return M
