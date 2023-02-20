local helper = require("genvdoc.test.helper")
local genvdoc = helper.require("genvdoc")

local default_chapters = {
  {
    name = function(group)
      return "Lua module: " .. group
    end,
    group = function(node)
      if node.declaration == nil or node.declaration.type ~= "function" then
        return nil
      end
      return node.declaration.module
    end,
  },
}

describe("genvdoc", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can generate a help document", function()
    helper.test_data:create_file(
      "lua/genvdoc/init.lua",
      [[
local ignored = {}

function ignored.inspect()
end

local M = {}

--- @class genvdoc_test_class
--- @field field1 string field1 description
--- @field field2 number field2 description

--- Ignored comment
--- Ignored comment

--- Inspect a tbl.
--- @param tbl table: a target table
---   param1 description
--- @vararg any: variadic
---   variadic description
--- @return string: inspected
---   return description
function M.inspect(tbl, ...)
  return vim.inspect(tbl)
end

--- Inspect2.
--- @param arg1 table: the first argument
---   param1 description
function M.inspect2(self, arg1)
  return vim.inspect()
end

--- Ignored comment
--- Ignored comment

function M.inspect3(_param)
  return vim.inspect()
end

--- Ignored comment
--- Ignored comment

--- Inspect4.
--- @param tbl table: a target table
function M.inspect4(tbl)
  return vim.inspect()
end

--- Ignored comment
--- Ignored comment

return M
]]
    )
    helper.test_data:create_file(
      "lua/genvdoc/other.lua",
      [[
local M = {}

--- Other.
function M.other()
  return
end

return M
]]
    )

    local chapters = vim.deepcopy(default_chapters)
    table.insert(chapters, {
      name = "STRUCTURE",
      group = function(node)
        if node.declaration == nil or node.declaration.type ~= "class" then
          return nil
        end
        return "STRUCTURE"
      end,
    })
    local err = genvdoc.generate("genvdoc", {
      output_dir = helper.test_data.full_path,
      chapters = chapters,
    })
    assert.is_nil(err)

    local file_path = helper.test_data.full_path .. "genvdoc.txt"
    assert.content(
      file_path,
      [[
*genvdoc.txt*

==============================================================================
Lua module: genvdoc                                          *genvdoc-genvdoc*

inspect({tbl}, {...})                                      *genvdoc.inspect()*
  Inspect a tbl.

  Parameters: ~
    {tbl} (table) a target table
        param1 description
    {...} (any) variadic
        variadic description

  Return: ~
    (string) inspected
        return description

inspect2({arg1})                                          *genvdoc:inspect2()*
  Inspect2.

  Parameters: ~
    {arg1} (table) the first argument
        param1 description

inspect4({tbl})                                           *genvdoc.inspect4()*
  Inspect4.

  Parameters: ~
    {tbl} (table) a target table

==============================================================================
Lua module: genvdoc.other                              *genvdoc-genvdoc.other*

other()                                                *genvdoc.other.other()*
  Other.

==============================================================================
STRUCTURE                                                  *genvdoc-STRUCTURE*

genvdoc_test_class                                        *genvdoc_test_class*

- {field1} (string) field1 description
- {field2} (number) field2 description

==============================================================================
vim:tw=78:ts=8:ft=help
]]
    )
  end)

  it("can select source files by pattern", function()
    helper.test_data:create_file(
      "lua/test1.lua",
      [[
local M = {}
--- Test1.
function M.f1()
end
return M
]]
    )
    helper.test_data:create_file(
      "lua/test2.lua",
      [[
local M = {}
--- Test2.
function M.f2()
end
return M
]]
    )

    local err = genvdoc.generate("genvdoc", {
      output_dir = helper.test_data.full_path,
      source = {
        patterns = { "lua/test1\\.lua" },
      },
      chapters = default_chapters,
    })
    assert.is_nil(err)

    local file_path = helper.test_data.full_path .. "genvdoc.txt"

    assert.content(
      file_path,
      [[
*genvdoc.txt*

==============================================================================
Lua module: test1                                              *genvdoc-test1*

f1()                                                              *test1.f1()*
  Test1.

==============================================================================
vim:tw=78:ts=8:ft=help
]]
    )
  end)

  it("can add examples to the doc", function()
    helper.test_data:create_file(
      "example.vim",
      [[
nnoremap <Leader>h <Cmd>Genvdoc hoge<CR>
nnoremap <Leader>f <Cmd>Genvdoc foo<CR>]]
    )

    local err = genvdoc.generate("genvdoc", {
      output_dir = helper.test_data.full_path,
      chapters = {
        {
          name = "EXAMPLES",
          body = function()
            return require("genvdoc.util").help_code_block_from_file("./example.vim", { language = "vim" })
          end,
        },
      },
    })

    assert.is_nil(err)

    local file_path = helper.test_data.full_path .. "genvdoc.txt"
    assert.content(
      file_path,
      [[
*genvdoc.txt*

==============================================================================
EXAMPLES                                                    *genvdoc-EXAMPLES*

>vim
  nnoremap <Leader>h <Cmd>Genvdoc hoge<CR>
  nnoremap <Leader>f <Cmd>Genvdoc foo<CR>
<

==============================================================================
vim:tw=78:ts=8:ft=help
]]
    )
  end)

  it("can generate a document with no chapters", function()
    local err = genvdoc.generate("genvdoc", {
      output_dir = helper.test_data.full_path,
      chapters = default_chapters,
    })
    assert.is_nil(err)

    local file_path = helper.test_data.full_path .. "genvdoc.txt"
    assert.content(
      file_path,
      [[
*genvdoc.txt*


==============================================================================
vim:tw=78:ts=8:ft=help
]]
    )
  end)
end)
