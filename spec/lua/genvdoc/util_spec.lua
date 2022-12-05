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
end)
