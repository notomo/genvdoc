local M = {}

local CommandParser = {}
CommandParser.__index = CommandParser
M.CommandParser = CommandParser

function CommandParser.eat(_, tokens)
  if not vim.startswith(tokens[1], "com") then
    return nil
  end

  for _, token in ipairs({unpack(tokens, 2)}) do
    if not vim.startswith(token, "-") then
      return {name = token, type = "command"}
    end
  end

  error("parse command: " .. vim.inspect(tokens))
end

return M
