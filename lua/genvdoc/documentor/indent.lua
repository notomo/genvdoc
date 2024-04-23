local M = {}

function M.add_indent(lines, count)
  local indent = (" "):rep(count)
  return vim
    .iter(lines)
    :map(function(line)
      if line == "" then
        return line
      end
      return ("%s%s"):format(indent, line)
    end)
    :totable()
end

return M
