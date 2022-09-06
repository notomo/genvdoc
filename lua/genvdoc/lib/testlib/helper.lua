local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local helper = require("vusted.helper")

helper.root = helper.find_plugin_root(plugin_name)
helper.test_data_path = "spec/test_data/"
helper.test_data_dir = helper.root .. "/" .. helper.test_data_path

function helper.before_each()
  helper.new_directory("")
  vim.api.nvim_set_current_dir(helper.test_data_dir)
end

function helper.after_each()
  vim.api.nvim_set_current_dir(helper.root)
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
  helper.delete("")
  print(" ")
end

function helper.new_file(path, ...)
  local f = io.open(helper.test_data_dir .. path, "w")
  for _, line in ipairs({ ... }) do
    f:write(line .. "\n")
  end
  f:close()
end

function helper.new_directory(path)
  vim.fn.mkdir(helper.test_data_dir .. path, "p")
end

function helper.delete(path)
  vim.fn.delete(helper.test_data_dir .. path, "rf")
end

local asserts = require("vusted.assert").asserts

asserts.create("content"):register_eq(function(file_path)
  local f = io.open(file_path, "r")
  local expected = f:read("*a")
  f:close()
  return "\n" .. expected
end)

return helper
