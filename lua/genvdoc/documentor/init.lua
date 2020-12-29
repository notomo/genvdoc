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
    local groups = {}
    for _, node in ipairs(nodes) do
      local group = chapter.group(node)
      if group == nil then
        goto continue
      end
      local group_nodes = groups[group] or {}
      table.insert(group_nodes, node)
      groups[group] = group_nodes
      ::continue::
    end

    local keys = vim.tbl_keys(groups)
    table.sort(keys, function(a, b)
      return a < b
    end)

    for _, key in ipairs(keys) do
      local name
      if type(chapter.name) == "function" then
        name = chapter.name(key)
      else
        name = chapter.name
      end
      table.insert(chapters, self._chapter.new(name, key, groups[key]))
    end
  end
  return self._document.new(plugin_name, chapters)
end

return M
