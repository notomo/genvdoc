local M = {}

function M.add_indent(lines)
  return vim.tbl_map(function(line)
    if line == "" then
      return line
    end
    return ("  %s"):format(line)
  end, lines)
end

return M
