local Tag = require("genvdoc.documentor.help.tag")

local M = {}

function M.tagged(declaration, width)
  local name = ":" .. declaration.name

  local str = name
  if #declaration.params > 0 then
    str = ("%s %s"):format(name, table.concat(declaration.params, " "))
  end

  return Tag.add(str, width, name)
end

return M
