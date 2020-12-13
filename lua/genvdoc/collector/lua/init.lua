local Path = require("genvdoc/lib/path").Path

local M = {}

local Parser = {}
Parser.__index = Parser

function Parser.new(lua_dir)
  local tbl = {_lua_dir = lua_dir, _comment_parsing = false, _results = {}, _result = {}}
  return setmetatable(tbl, Parser)
end

function Parser.parse(self, path)
  local f = io.open(path, "r")
  local str = f:read("*a")
  f:close()

  local module_path
  if Path.new(path):head() == "init.lua" then
    module_path = Path.new(path):parent():trim_slash():get()
  else
    module_path = Path.new(path):without_ext()
  end
  local relative_path = self._lua_dir:relative(module_path)
  local module_name = table.concat(vim.split(relative_path, "/", true), ".")

  local bufnr = vim.api.nvim_create_buf(false, true)
  local lines = vim.split(str, "\n", true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  local parser = vim.treesitter.get_parser(bufnr, "lua")
  local trees, _ = parser:parse()
  local query = vim.treesitter.parse_query("lua", [[
((comment) @comment (match? @comment "^---"))
(function
  (function_name (function_name_field (property_identifier) @method))
  (parameters (identifier) @param)?
)
  ]])

  local ok, result = pcall(function()
    return {query:iter_captures(trees[1]:root(), bufnr, 0, -1)}
  end)
  if not ok then
    vim.api.nvim_err_writeln(result .. "\n")
    return {}
  end

  for i, node in unpack(result) do
    local name = query.captures[i]
    if not self._comment_parsing and name == "comment" then
      self._comment_parsing = true
      self._result = {
        lines = {},
        declaration = {param_lines = {}, params = {}, module = module_name},
      }
      table.insert(self._results, self._result)
    end

    local row, start_col, _, end_col = unpack({node:range()})
    local text = lines[row + 1]:sub(start_col + 1, end_col)
    if self._comment_parsing and name == "method" then
      self._result.declaration.name = text
      self._result.declaration.type = "method"
      self._comment_parsing = false
    elseif not self._comment_parsing and self._result.declaration ~= nil and name == "param" then
      table.insert(self._result.declaration.params, text)
    elseif name == "comment" then
      local _, e = text:find([[^%s*%-%-%-%s?]])
      local comment = text:sub(e + 1)
      if vim.startswith(comment, "@param ") then
        local _, pe = comment:find([[^@param%s+]])
        table.insert(self._result.declaration.param_lines, comment:sub(pe + 1))
      else
        table.insert(self._result.lines, comment)
      end
    end
  end
  return self._results
end

function M.collect(self)
  local pattern = Path.new(self.target_dir):join("**/*.lua"):get()
  local paths = vim.fn.glob(pattern, true, true)
  local lua_dir = Path.new(self.target_dir):join("lua/")

  local results = {}
  for _, path in ipairs(paths) do
    vim.list_extend(results, Parser.new(lua_dir):parse(path))
  end
  return results
end

return M
