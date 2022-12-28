local Tag = require("genvdoc.documentor.help.tag")
local Declaration = require("genvdoc.documentor.help.declaration")
local add_indent = require("genvdoc.documentor.indent").add_indent

local Chapter = {}
Chapter.__index = Chapter

function Chapter.new(name, group_name, nodes, body)
  vim.validate({
    name = { name, "string" },
    group_name = { group_name, "string" },
    nodes = { nodes, "table", true },
    body = { body, "function", true },
  })
  local tbl = {
    _name = name,
    _group_name = group_name,
    _nodes = nodes or {},
    _body = body,
  }
  return setmetatable(tbl, Chapter)
end

function Chapter.build(self, plugin_name, width)
  local lines = {
    Tag.add(self._name, width, plugin_name .. "-" .. self._group_name),
    "",
  }

  if self._body then
    local ctx = { plugin_name = plugin_name, width = width }
    table.insert(lines, self._body(ctx))
    return table.concat(lines, "\n")
  end

  for _, node in ipairs(self._nodes) do
    if node.declaration ~= nil then
      vim.list_extend(lines, Declaration.build_lines(node.declaration, node.lines, width))
    else
      vim.list_extend(lines, add_indent(node.lines))
    end
    table.insert(lines, "")
  end
  table.remove(lines, #lines)

  return table.concat(lines, "\n")
end

return Chapter
