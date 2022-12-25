local Declaration = {}
Declaration.__index = Declaration

function Declaration.new(declaration)
  local tbl = { _declaration = declaration }
  return setmetatable(tbl, Declaration)
end

function Declaration.build(self, description_lines, width)
  local title
  local lines = {}
  if self._declaration.type == "command" then
    vim.list_extend(lines, description_lines)

    title = require("genvdoc.documentor.help.declaration.command").tagged(self._declaration, width)
  elseif self._declaration.type == "method" then
    local parameters = require("genvdoc.documentor.help.declaration.function_parameter").new(self._declaration)
    vim.list_extend(lines, parameters:build_lines(description_lines))
    vim.list_extend(
      lines,
      require("genvdoc.documentor.help.declaration.function_return").build_lines(self._declaration)
    )

    title = parameters:tagged(width)
  end

  local indented_lines = vim.tbl_map(function(line)
    if line == "" then
      return line
    end
    return ("  %s"):format(line)
  end, lines)
  table.insert(indented_lines, 1, title)

  return indented_lines
end

return Declaration
