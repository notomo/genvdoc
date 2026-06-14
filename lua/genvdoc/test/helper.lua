local helper = require("ntf.helper")
local plugin_name = helper.get_module_root(...)

helper.root = helper.find_plugin_root(plugin_name)
vim.opt.packpath:prepend(vim.fs.joinpath(helper.root, "spec/.shared/packages"))
require("assertlib").register(require("ntf.assert").register)

function helper.before_each()
  helper.test_data = require("genvdoc.vendor.misclib.test.data_dir").setup(
    helper.root,
    { base_dir = ("test_data_%d/"):format(vim.fn.getpid()) }
  )
  helper.test_data:cd("")
end

function helper.after_each()
  helper.test_data:teardown()
end

local assert = require("ntf.assert")

assert.register("content", function(self)
  return function(_, args)
    local file_path = args[1]
    local f = io.open(file_path, "r")
    if not f then
      error("can't open file: " .. file_path)
    end
    local expected = f:read("*a")
    f:close()

    local actual = args[2]

    local diff = vim.text.diff(actual, expected, {})

    self:set_positive(("diff exists: actual(+), expected(-)\n%s"):format(diff))
    self:set_negative("diff does not exists")

    return diff == ""
  end
end)

function helper.typed_assert(assert)
  local x = require("assertlib").typed(assert)
  ---@cast x +{content:fun(path,want)}
  return x
end

return helper
