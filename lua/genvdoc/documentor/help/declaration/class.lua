local Tag = require("genvdoc.documentor.help.tag")
local add_indent = require("genvdoc.documentor.indent").add_indent

local M = {}
M.__index = M

function M.new(declaration)
  local tbl = {
    _declaration = declaration,
  }
  return setmetatable(tbl, M)
end

function M.tagged_line(self, width)
  local name = self._declaration.name
  return Tag.add(name, width, name)
end

function M.build_lines(self, description_lines)
  local lines = add_indent(vim.deepcopy(description_lines), 2)
  table.insert(lines, "")

  local public_fields = vim
    .iter(self._declaration.fields)
    :filter(function(field)
      return field.scope == "public"
    end)
    :totable()

  for _, field in ipairs(public_fields) do
    local line = ("- {%s} (%s)"):format(field.name, field.type)
    if field.descriptions[1] then
      line = line .. " " .. field.descriptions[1]
    end
    table.insert(lines, line)
    vim.list_extend(lines, add_indent(vim.list_slice(field.descriptions, 2), 2))
  end
  return lines
end

return M
