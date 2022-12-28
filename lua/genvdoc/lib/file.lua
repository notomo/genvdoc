local pathlib = require("genvdoc.vendor.misclib.path")

local M = {}

function M.write(path, str)
  vim.fn.mkdir(pathlib.parent(path), "p")
  local f = io.open(path, "w")
  f:write(str)
  f:close()
end

return M
