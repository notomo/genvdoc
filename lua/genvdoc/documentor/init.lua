local M = {}

function M.generate(plugin_name, nodes, raw_chapter_settings)
  vim.validate({
    plugin_name = { plugin_name, "string" },
    nodes = { nodes, "table" },
    raw_chapter_settings = { raw_chapter_settings, "table" },
  })
  local new_chapter = require("genvdoc.documentor.help.chapter").new

  local all_chapters = {}
  for _, raw_setting in ipairs(raw_chapter_settings) do
    local chapters = require("genvdoc.documentor.chapter").grouping(new_chapter, raw_setting, nodes)
    vim.list_extend(all_chapters, chapters)
  end

  return require("genvdoc.documentor.help").new(plugin_name, all_chapters)
end

return M
