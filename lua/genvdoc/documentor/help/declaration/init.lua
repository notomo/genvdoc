local add_indent = require("genvdoc.documentor.indent").add_indent

local Declaration = {}
Declaration.__index = Declaration

function Declaration.new(declaration)
  local tbl = { _declaration = declaration }
  return setmetatable(tbl, Declaration)
end

function Declaration.build(self, description_lines, width)
  if self._declaration.type == "command" then
    local tagged_line = require("genvdoc.documentor.help.declaration.command").tagged(self._declaration, width)
    return {
      tagged_line,
      unpack(add_indent(description_lines)),
    }
  end

  if self._declaration.type == "method" then
    local parameters = require("genvdoc.documentor.help.declaration.function_parameter").new(self._declaration)

    local declaration_lines = {}
    vim.list_extend(declaration_lines, parameters:build_lines(description_lines))
    vim.list_extend(
      declaration_lines,
      require("genvdoc.documentor.help.declaration.function_return").build_lines(self._declaration)
    )

    local tagged_line = parameters:tagged(width)
    return {
      tagged_line,
      unpack(add_indent(declaration_lines)),
    }
  end

  return {}
end

return Declaration
