local M = {}

function M.write(path, str)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local f = io.open(path, "w")
  if not f then
    error("failed to open: " .. path)
  end
  f:write(str)
  f:close()
end

function M.read_all(path)
  local f = io.open(path, "r")
  if not f then
    return { message = "cannot read: " .. path }
  end
  if vim.fn.isdirectory(path) == 1 then
    return { message = "directory: " .. path }
  end
  local str = f:read("*a")
  f:close()
  return str
end

return M
