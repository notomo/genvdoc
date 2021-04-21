local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local M = require("vusted.helper")

M.root = M.find_plugin_root(plugin_name)
M.test_data_path = "spec/test_data/"
M.test_data_dir = M.root .. "/" .. M.test_data_path

function M.before_each()
  M.new_directory("")
  vim.api.nvim_set_current_dir(M.test_data_dir)
end

function M.after_each()
  vim.cmd("tabedit")
  vim.cmd("tabonly!")
  vim.cmd("silent! %bwipeout!")
  print(" ")

  vim.api.nvim_set_current_dir(M.root)

  M.cleanup_loaded_modules(plugin_name)
  M.delete("")
end

function M.new_file(path, ...)
  local f = io.open(M.test_data_dir .. path, "w")
  for _, line in ipairs({...}) do
    f:write(line .. "\n")
  end
  f:close()
end

function M.new_directory(path)
  vim.fn.mkdir(M.test_data_dir .. path, "p")
end

function M.delete(path)
  vim.fn.delete(M.test_data_dir .. path, "rf")
end

local asserts = require("vusted.assert").asserts

asserts.create("content"):register_eq(function(file_path)
  local f = io.open(file_path, "r")
  local expected = f:read("*a")
  f:close()
  return "\n" .. expected
end)

return M
