vim.o.runtimepath = vim.fn.getcwd() .. "," .. vim.o.runtimepath
local plugin_name = vim.env.PLUGIN_NAME

local gen = function()
  require("genvdoc").generate(plugin_name, {
    source = { patterns = { ("lua/%s/init.lua"):format(plugin_name) } },
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
end

gen()
