local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local helper = require("vusted.helper")

helper.root = helper.find_plugin_root(plugin_name)

function helper.before_each()
  helper.test_data = require("genvdoc.vendor.misclib.test.data_dir").setup(helper.root)
  helper.test_data:cd("")
end

function helper.after_each()
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
  helper.test_data:teardown()
  print(" ")
end

local asserts = require("vusted.assert").asserts

asserts.create("content"):register_eq(function(file_path)
  local f = io.open(file_path, "r")
  local expected = f:read("*a")
  f:close()
  return "\n" .. expected
end)

return helper
