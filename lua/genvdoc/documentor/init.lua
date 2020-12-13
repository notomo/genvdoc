local M = {}

local Documentor = {}
Documentor.__index = Documentor
M.Documentor = Documentor

function Documentor.new(document_type, chapters)
  vim.validate({
    document_type = {document_type, "string", true},
    chapters = {chapters, "table", true},
  })
  document_type = document_type or "help"
  chapters = chapters or {}
  local tbl = {
    _document = require("genvdoc/documentor/" .. document_type).Document,
    _chapter = require("genvdoc/documentor/" .. document_type .. "/chapter").Chapter,
    _chapters = chapters,
  }
  return setmetatable(tbl, Documentor)
end

function Documentor.generate(self, plugin_name, nodes)
  vim.validate({plugin_name = {plugin_name, "string"}, nodes = {nodes, "table"}})
  local chapters = {}
  for _, chapter in ipairs(self._chapters) do
    table.insert(chapters, self._chapter.new(chapter.name, vim.tbl_filter(chapter.filter, nodes)))
  end
  return self._document.new(plugin_name, chapters)
end

return M
