local Tag = require("genvdoc.documentor.help.tag")
local Separator = require("genvdoc.documentor.help.separator")

local Document = {}
Document.__index = Document

function Document.new(plugin_name, chapters)
  local width = 78
  local tbl = {
    name = plugin_name .. ".txt",
    _separator = Separator.new(width),
    _plugin_name = plugin_name,
    _width = width,
    _tabstop = 8,
    _chapters = chapters,
  }
  return setmetatable(tbl, Document)
end

function Document.build(self)
  local factors = {
    self:_header(),
    self:_body(),
    self._separator,
    self:_footer(),
  }
  return table.concat(factors, "\n") .. "\n"
end

function Document._header(self)
  return Tag.new(self.name)
end

function Document._body(self)
  local chapters = vim.tbl_map(function(chapter)
    return ("%s\n%s"):format(self._separator, chapter:build(self._plugin_name, self._width))
  end, self._chapters)
  return table.concat(chapters, "\n")
end

function Document._footer(self)
  return ("vim:tw=%s:ts=%s:ft=help"):format(self._width, self._tabstop)
end

return Document
