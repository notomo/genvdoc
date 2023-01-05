local M = {}

function M.add_indent(lines, count)
  local indent = (" "):rep(count)
  return vim.tbl_map(function(line)
    if line == "" then
      return line
    end
    return ("%s%s"):format(indent, line)
  end, lines)
end

return M
