local M = {}

function M.help_code_block_from_file(file_path)
  vim.validate({file_path = {file_path, "string"}})
  local f = io.open(file_path, "r")
  local lines = {}
  for line in f:lines() do
    table.insert(lines, line)
  end
  f:close()
  local indented = M.indent(table.concat(lines, "\n"), 2)
  return (">\n%s\n<"):format(indented)
end

function M.indent(str, count)
  vim.validate({str = {str, "string"}, count = {count, "number"}})
  local indent = (" "):rep(count)
  local lines = {}
  for _, line in ipairs(vim.split(str, "\n", true)) do
    if line == "" then
      table.insert(lines, line)
    else
      table.insert(lines, ("%s%s"):format(indent, line))
    end
  end
  return table.concat(lines, "\n")
end

function M.help_tagged(ctx, name, tag_name)
  return require("genvdoc.documentor.help.tag").Tag.add(name, ctx.width, tag_name) .. "\n"
end

return M
