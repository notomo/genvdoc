local ChapterSetting = require("genvdoc.documentor.chapter").ChapterSetting
local modulelib = require("genvdoc.vendor.misclib.module")

local M = {}

local Documentor = {}
Documentor.__index = Documentor
M.Documentor = Documentor

function Documentor.new(document_type, settings)
  vim.validate({
    document_type = { document_type, "string", true },
    settings = { settings, "table", true },
  })

  document_type = document_type or "help"
  settings = settings or {}

  local document_module, d_err = modulelib.find("genvdoc/documentor/" .. document_type)
  if d_err ~= nil then
    return nil, d_err
  end

  local chapter_module, c_err = modulelib.find("genvdoc/documentor/" .. document_type .. "/chapter")
  if c_err ~= nil then
    return nil, c_err
  end

  local tbl = {
    _document_cls = document_module.Document,
    _chapter_cls = chapter_module.Chapter,
    _settings = settings,
  }
  return setmetatable(tbl, Documentor)
end

function Documentor.generate(self, plugin_name, nodes)
  vim.validate({ plugin_name = { plugin_name, "string" }, nodes = { nodes, "table" } })

  local all_chapters = {}
  for _, setting in ipairs(self._settings) do
    local chapters = ChapterSetting.new(self._chapter_cls, setting):group(nodes)
    vim.list_extend(all_chapters, chapters)
  end

  return self._document_cls.new(plugin_name, all_chapters)
end

return M
