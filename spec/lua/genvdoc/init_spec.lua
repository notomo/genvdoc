local helper = require("genvdoc.lib.testlib.helper")
local genvdoc = helper.require("genvdoc")

describe("genvdoc", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can generate a help document", function()
    helper.new_directory("lua")
    helper.new_directory("lua/genvdoc")
    helper.new_file("lua/genvdoc/init.lua", [[
local M = {}

--- Inspect a tbl.
--- @param tbl table: a target table
function M.inspect(tbl)
  return vim.inspect(tbl)
end

--- Inspect2.
function M.inspect2()
  return vim.inspect()
end

function M.inspect3(_param)
  return vim.inspect()
end

--- Inspect4.
--- @param tbl table: a target table
function M.inspect4(tbl)
  return vim.inspect()
end

return M
]])
    helper.new_file("lua/genvdoc/other.lua", [[
local M = {}

--- Other.
function M.other()
  return
end

return M
]])

    local err = genvdoc.generate("genvdoc", {
      output_dir = helper.test_data_dir,
      chapters = {
        {
          name = function(group)
            return "Lua module: " .. group
          end,
          group = function(node)
            if node.declaration == nil then
              return nil
            end
            return node.declaration.module
          end,
        },
      },
    })
    assert.is_nil(err)

    local file_path = helper.test_data_dir .. "genvdoc.txt"
    assert.content(file_path, "\n" .. [[
*genvdoc.txt*

==============================================================================
Lua module: genvdoc                                          *genvdoc-genvdoc*

inspect({tbl})                                             *genvdoc.inspect()*
  Inspect a tbl.

  Parameters: ~
    {tbl} (table) a target table

inspect2()                                                *genvdoc.inspect2()*
  Inspect2.

inspect4({tbl})                                           *genvdoc.inspect4()*
  Inspect4.

  Parameters: ~
    {tbl} (table) a target table

==============================================================================
Lua module: genvdoc.other                              *genvdoc-genvdoc.other*

other()                                                *genvdoc.other.other()*
  Other.

==============================================================================
vim:tw=78:ts=8:ft=help
]])
  end)

  it("can add examples to the doc", function()
    helper.new_file("example.vim", [[
nnoremap <Leader>h <Cmd>Genvdoc hoge<CR>
nnoremap <Leader>f <Cmd>Genvdoc foo<CR>]])

    local err = genvdoc.generate("genvdoc", {
      output_dir = helper.test_data_dir,
      chapters = {
        {
          name = "EXAMPLES",
          body = function()
            local f = io.open("./example.vim", "r")
            local lines = {}
            for line in f:lines() do
              if line == "" then
                table.insert(lines, line)
              else
                table.insert(lines, ("  %s"):format(line))
              end
            end
            f:close()
            return (">\n%s\n<"):format(table.concat(lines, "\n"))
          end,
        },
      },
    })

    assert.is_nil(err)

    local file_path = helper.test_data_dir .. "genvdoc.txt"
    assert.content(file_path, "\n" .. [[
*genvdoc.txt*

==============================================================================
EXAMPLES                                                    *genvdoc-EXAMPLES*

>
  nnoremap <Leader>h <Cmd>Genvdoc hoge<CR>
  nnoremap <Leader>f <Cmd>Genvdoc foo<CR>
<

==============================================================================
vim:tw=78:ts=8:ft=help
]])

  end)
end)
