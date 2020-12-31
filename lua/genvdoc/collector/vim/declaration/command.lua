local M = {}

local CommandParser = {}
CommandParser.__index = CommandParser
M.CommandParser = CommandParser

function CommandParser.parse(_, tokens)
  if not vim.startswith(tokens[1], "com") then
    return nil
  end

  local params = {}
  for _, token in ipairs({unpack(tokens, 2)}) do
    if token == "-nargs=?" then
      table.insert(params, "[{arg}]")
    end
    if not vim.startswith(token, "-") then
      return {name = token, type = "command", params = params}
    end
  end

  error("parse command: " .. vim.inspect(tokens))
end

return M
