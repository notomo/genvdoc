local M = {}

function M.help_code_block_from_file(file_path)
  local f = io.open(file_path, "r")
  local lines = {}
  for line in f:lines() do
    if line == "" then
      table.insert(lines, line)
    else
      table.insert(lines, ("  %s"):format(line))
    end
  end
  f:close()
  return (">\n%s\n<"):format(table.concat(lines, "\n"))
end

return M
