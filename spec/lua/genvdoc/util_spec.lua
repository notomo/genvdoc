local helper = require("genvdoc.test.helper")
local util = helper.require("genvdoc.util")

describe("genvdoc.util", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("help_tagged", function()
    local ctx = { width = 20 }
    local got = util.help_tagged(ctx, "name", "tag_name")
    local want = [[name      *tag_name*
]]
    assert.equal(want, got)
  end)

  it("help_code_block with no opts", function()
    local got = util.help_code_block("test")
    local want = [[
>
  test
<]]
    assert.equal(want, got)
  end)

  it("help_code_block with language", function()
    local got = util.help_code_block("test", { language = "lua" })
    local want = [[
>lua
  test
<]]
    assert.equal(want, got)
  end)

  it("can extract variable as text", function()
    local file_path = helper.test_data:create_file(
      "lua/genvdoc/other.lua",
      [[
local other = {}

local default_option = {
  test1 = "a",
  test2 = "b",
}
]]
    )

    local got = util.extract_variable_as_text(file_path, "default_option")
    local want = [[
local default_option = {
  test1 = "a",
  test2 = "b",
}]]
    assert.equal(want, got)
  end)

  it("can execute chunk", function()
    local got = util.execute("return 'str'")
    local want = "str"
    assert.equal(want, got)
  end)
end)
