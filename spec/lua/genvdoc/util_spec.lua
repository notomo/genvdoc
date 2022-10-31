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
end)
