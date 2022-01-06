local Tag = require("genvdoc.documentor.help.tag").Tag
local Declaration = require("genvdoc.documentor.help.declaration").Declaration

local M = {}

local Chapter = {}
Chapter.__index = Chapter
M.Chapter = Chapter

function Chapter.new(name, group_name, nodes, body)
  vim.validate({
    name = { name, "string" },
    group_name = { group_name, "string" },
    nodes = { nodes, "table", true },
    body = { body, "function", true },
  })
  local tbl = { _name = name, _group_name = group_name, _nodes = nodes or {}, _body = body }
  return setmetatable(tbl, Chapter)
end

function Chapter.build(self, plugin_name, width)
  local tag = Tag.add(self._name, width, plugin_name .. "-" .. self._group_name)
  local lines = { tag, "" }
  if self._body then
    local ctx = { plugin_name = plugin_name, width = width }
    table.insert(lines, self._body(ctx))
    return table.concat(lines, "\n")
  end

  local last = #self._nodes
  for i, node in ipairs(self._nodes) do
    if node.declaration ~= nil then
      vim.list_extend(lines, Declaration.new(node.declaration):build(node.lines, width))
    else
      vim.list_extend(
        lines,
        vim.tbl_map(function(line)
          return ("  %s"):format(line)
        end, node.lines)
      )
    end
    if i ~= last then
      table.insert(lines, "")
    end
  end
  return table.concat(lines, "\n")
end

return M
