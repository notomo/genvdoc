local Tag = require("genvdoc.documentor.help.tag")
local Declaration = require("genvdoc.documentor.help.declaration")
local add_indent = require("genvdoc.documentor.indent").add_indent

local Chapter = {}
Chapter.__index = Chapter

--- @param name string
--- @param group_name string
--- @param nodes table?
--- @param body function?
function Chapter.new(name, group_name, nodes, body)
  local tbl = {
    _name = name,
    _group_name = group_name,
    _nodes = nodes or {},
    _body = body,
  }
  return setmetatable(tbl, Chapter)
end

function Chapter.build(self, plugin_name, width)
  local all_lines = {
    Tag.add(self._name, width, plugin_name .. "-" .. self._group_name),
    "",
  }

  if self._body then
    local ctx = { plugin_name = plugin_name, width = width }
    table.insert(all_lines, self._body(ctx))
    return table.concat(all_lines, "\n")
  end

  for _, node in ipairs(self._nodes) do
    local lines
    if node.declaration ~= nil then
      lines = Declaration.build_lines(node.declaration, node.lines, width)
    else
      lines = add_indent(node.lines, 2)
    end

    vim.list_extend(all_lines, lines)
    if #lines > 0 then
      table.insert(all_lines, "")
    end
  end
  table.remove(all_lines, #all_lines)

  return table.concat(all_lines, "\n")
end

return Chapter
