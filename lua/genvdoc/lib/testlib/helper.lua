local M = {}

local root, err = require("genvdoc/lib/path").find_root("genvdoc/*.lua")
if err ~= nil then
  error(err)
end
M.root = root
M.test_data_path = "spec/test_data/"
M.test_data_dir = M.root .. "/" .. M.test_data_path

M.command = function(cmd)
  local _, cmderr = pcall(vim.api.nvim_command, cmd)
  if cmderr then
    local info = debug.getinfo(2)
    local pos = ("%s:%d"):format(info.source, info.currentline)
    local msg = ("on %s: failed excmd `%s`\n%s"):format(pos, cmd, cmderr)
    error(msg)
  end
end

M.before_each = function()
  M.new_directory("")
  vim.api.nvim_set_current_dir(M.test_data_dir)
end

M.after_each = function()
  M.command("tabedit")
  M.command("tabonly!")
  M.command("silent! %bwipeout!")
  print(" ")

  vim.api.nvim_set_current_dir(M.root)

  require("genvdoc/lib/cleanup")()
  M.delete("")
end

M.new_file = function(path, ...)
  local f = io.open(M.test_data_dir .. path, "w")
  for _, line in ipairs({...}) do
    f:write(line .. "\n")
  end
  f:close()
end

M.new_directory = function(path)
  vim.fn.mkdir(M.test_data_dir .. path, "p")
end

M.delete = function(path)
  vim.fn.delete(M.test_data_dir .. path, "rf")
end

local vassert = require("vusted.assert")
local asserts = vassert.asserts
M.assert = vassert.assert

asserts.create("content"):register_eq(function(file_path)
  local expected = io.open(file_path, "r"):read("*a")
  return "\n" .. expected .. "\n"
end)

return M
