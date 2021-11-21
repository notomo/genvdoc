vim.o.runtimepath = vim.fn.getcwd() .. "," .. vim.o.runtimepath
vim.o.runtimepath = vim.fn.getcwd() .. "/script/nvim-treesitter," .. vim.o.runtimepath

local gen = function()
  require("genvdoc").generate("genvdoc", {
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
