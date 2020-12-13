local helper = require("genvdoc/lib/testlib/helper")
local genvdoc = require("genvdoc")

describe("genvdoc", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can generate a document", function()
    local output_dir = helper.test_data_dir

    helper.new_file("plugin.vim", [[
"" test command
" echo `ok` message
command! GenvdocTestCommand echo 'ok'
]])

    helper.new_directory("lua")
    helper.new_file("lua/genvdoc.lua", [[
local M = {}

--- Inspect a tbl.
--- @param a target table
function M.inspect(tbl)
  return vim.inspect(tbl)
end

--- Inspect2.
function M.inspect2()
  return vim.inspect()
end

return M
]])

    genvdoc.generate("genvdoc", {
      output_dir = helper.test_data_dir,
      chapters = {
        {
          name = "COMMANDS",
          filter = function(node)
            return node.declaration ~= nil and node.declaration.type == "command"
          end,
        },
        {
          name = "LUA-MODULE",
          filter = function(node)
            return node.declaration ~= nil and node.declaration.module ~= nil
          end,
        },
      },
    })

    local file_path = output_dir .. "genvdoc.txt"
    assert.content(file_path, "\n" .. [[
*genvdoc.txt*

==============================================================================
COMMANDS                                                    *genvdoc-COMMANDS*

:GenvdocTestCommand                                      *:GenvdocTestCommand*
  test command
  echo `ok` message

==============================================================================
LUA-MODULE                                                *genvdoc-LUA-MODULE*

genvdoc.inspect({tbl})                                     *genvdoc.inspect()*
  Inspect a tbl.

  Parameters: ~
    {tbl} a target table

genvdoc.inspect2()                                        *genvdoc.inspect2()*
  Inspect2.

==============================================================================
vim:tw=78:ts=8:ft=help
]])
  end)
end)
