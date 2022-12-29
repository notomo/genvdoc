local util = require("genvdoc.util")
require("genvdoc").generate("example.nvim", {
  output_dir = vim.fn.tempname(),
  source = { patterns = { "lua/genvdoc/test/example_source.lua" } },
  chapters = {
    {
      name = function(group)
        return "Lua module: " .. group
      end,
      group = function(node)
        if not node.declaration then
          return nil
        end
        return node.declaration.module
      end,
    },
    {
      name = "EXAMPLES",
      body = function()
        return util.help_code_block_from_file("lua/genvdoc/test/example.lua", { language = "lua" })
      end,
    },
  },
})
