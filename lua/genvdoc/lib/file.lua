local pathlib = require("genvdoc.vendor.misclib.path")

local M = {}

function M.write(path, str)
  vim.fn.mkdir(pathlib.parent(path), "p")
  local f = io.open(path, "w")
  f:write(str)
  f:close()
end

function M.read_all(path)
  local f = io.open(path, "r")
  if not f then
    return nil, "cannot read: " .. path
  end
  if vim.fn.isdirectory(path) == 1 then
    return nil, "directory: " .. path
  end
  local str = f:read("*a")
  f:close()
  return str, nil
end

return M
