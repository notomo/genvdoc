local add_indent = require("genvdoc.documentor.indent").add_indent

local Declaration = {}

function Declaration.build_lines(declaration, description_lines, width)
  if declaration.type == "function" then
    local parameters = require("genvdoc.documentor.help.declaration.function_parameter").new(declaration)

    local declaration_lines = {}
    vim.list_extend(declaration_lines, parameters:build_lines(description_lines))
    vim.list_extend(
      declaration_lines,
      require("genvdoc.documentor.help.declaration.function_return").build_lines(declaration)
    )

    return {
      parameters:tagged_line(width),
      unpack(add_indent(declaration_lines, 2)),
    }
  end

  if declaration.type == "class" then
    local class = require("genvdoc.documentor.help.declaration.class").new(declaration)
    return {
      class:tagged_line(width),
      unpack(class:build_lines()),
    }
  end

  return {}
end

return Declaration
