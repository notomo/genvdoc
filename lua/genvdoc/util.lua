local M = {}

function M.help_code_block_from_file(file_path)
  local f = io.open(file_path, "r")
  local strs = {}
  for line in f:lines() do
    table.insert(strs, line)
  end
  f:close()
  local indented = M.indent(table.concat(strs, "\n"), 2)
  return (">\n%s\n<"):format(indented)
end

function M.indent(strs, count)
  local indent = (" "):rep(count)
  local lines = {}
  for _, str in ipairs(vim.split(strs, "\n", true)) do
    if str == "" then
      table.insert(lines, str)
    else
      table.insert(lines, ("%s%s"):format(indent, str))
    end
  end
  return table.concat(lines, "\n")
end

function M.help_tagged(ctx, name, tag_name)
  return require("genvdoc.documentor.help.tag").Tag.add(name, ctx.width, tag_name) .. "\n"
end

return M
