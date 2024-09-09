local helper = require("vusted.helper")
local plugin_name = helper.get_module_root(...)

helper.root = helper.find_plugin_root(plugin_name)
vim.opt.packpath:prepend(vim.fs.joinpath(helper.root, "spec/.shared/packages"))
require("assertlib").register(require("vusted.assert").register)

function helper.before_each()
  helper.test_data = require("genvdoc.vendor.misclib.test.data_dir").setup(helper.root)
  helper.test_data:cd("")
end

function helper.after_each()
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
  helper.test_data:teardown()
end

local asserts = require("vusted.assert").asserts

asserts.create("content"):register(function(self)
  return function(_, args)
    local file_path = args[1]
    local f = io.open(file_path, "r")
    if not f then
      error("can't open file: " .. file_path)
    end
    local expected = f:read("*a")
    f:close()

    local actual = args[2]

    local diff = vim.diff(actual, expected, {})

    self:set_positive(("diff exists: actual(+), expected(-)\n%s"):format(diff))
    self:set_negative("diff does not exists")

    return diff == ""
  end
end)

return helper
