local pathlib = require("genvdoc.vendor.misclib.path")

local M = {}

--- @class GenvdocGenerateOption
--- @field output_dir string? output directory path (default: "./doc/")
--- @field source GenvdocSourceOption? |GenvdocSourceOption|
--- @field chapters (GenvdocChapterOption[])? |GenvdocChapterOption|

--- @class GenvdocSourceOption
--- @field patterns string[] glob patterns to collect document source (default: { "lua/**/*.lua" })

--- @class GenvdocChapterOption
--- @field name string|fun(group:string):string chapter name
--- @field group (fun(node:GenvdocNode):string?)? chapter grouping
--- @field body (fun(ctx:GenvdocChapterBodyContext):string)? returns chapter body string

--- @class GenvdocChapterBodyContext
--- @field plugin_name string
--- @field width integer

--- @class GenvdocNode
--- @field declaration GenvdocDeclaration? |GenvdocDeclaration|

--- @class GenvdocDeclaration
--- @field type GenvdocDeclarationType
--- @field module string module name including this declaration

--- @alias GenvdocDeclarationType
--- | '"function"' # has module function's params and returns
--- | '"anonymous_function"' # same with "function" but does not have name
--- | '"class"' # has class name and fields
--- | '"alias"' # has enum like union values

---Generate a document.
---@param plugin_name string: used for document name
---@param opts GenvdocGenerateOption? |GenvdocGenerateOption|
function M.generate(plugin_name, opts)
  opts = require("genvdoc.option").new(opts)

  local nodes = require("genvdoc.collector").collect(opts.source)
  local document = require("genvdoc.documentor").generate(plugin_name, nodes, opts.chapters)

  local path = pathlib.join(opts.output_dir, document.name)
  require("genvdoc.lib.file").write(path, document:build())
end

return M
