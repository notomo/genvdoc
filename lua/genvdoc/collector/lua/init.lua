local Path = require("genvdoc.lib.path").Path
local Parser = require("genvdoc.collector.parser").Parser
local Modules = require("genvdoc.collector.lua.module").Modules

local M = {}

local Processor = {}
Processor.__index = Processor
Processor.STAGE = {
  PARSE_COMMENT = "PARSE_COMMENT",
  SEARCH_DECLARATION = "SEARCH_DECLARATION",
  PARSE_DECLARATION = "PARSE_DECLARATION",
}
Processor.FIRST_STAGE = Processor.STAGE.PARSE_COMMENT
Processor.COMPLETE_STAGE = {Processor.STAGE.PARSE_DECLARATION}

function Processor.new(modules, path)
  local query = vim.treesitter.parse_query("lua", [[
((comment) @comment (match? @comment "^---"))
(function
  (function_name (function_name_field (property_identifier) @method))
  (parameters (identifier) @param)?
  (parameters (self) @param)?
)
]])
  local tbl = {
    _module_name = modules:from_path(path),
    _query = query,
    _lines = Path.new(path):read_lines(),
    _row = nil,
    _joined = true,
  }
  return setmetatable(tbl, Processor)
end

function Processor._matched(self, i, node)
  local row, start_col, _, end_col = unpack({node:range()})
  self._joined = self._row == nil or (self._joined and (row == self._row or row - 1 == self._row))
  self._row = row
  return self._query.captures[i], self._lines[row + 1]:sub(start_col + 1, end_col)
end

function Processor.iter(self)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, self._lines)
  local parser = vim.treesitter.get_parser(bufnr, "lua")
  local trees, _ = parser:parse()
  return self._query:iter_captures(trees[1]:root(), bufnr, 0, -1)
end

function Processor._parse_comment(_, text)
  local _, e = text:find([[^%s*%-%-%-%s?]])
  return text:sub(e + 1)
end

function Processor.parse_comment(self, i, node)
  local name, text = self:_matched(i, node)
  if name == "comment" then
    local comment = self:_parse_comment(text)
    return {lines = comment}, self.STAGE.SEARCH_DECLARATION
  end
  self._row = nil
end

function Processor.search_declaration(self, i, node)
  local name, text = self:_matched(i, node)
  if name == "method" then
    return {declaration = {name = text, type = "method", module = self._module_name}}, self.STAGE.PARSE_DECLARATION
  elseif name == "comment" then
    local comment = self:_parse_comment(text)
    if vim.startswith(comment, "@param ") then
      local _, e = comment:find([[^@param%s+]])
      return {declaration = {param_lines = comment:sub(e + 1)}}
    elseif vim.startswith(comment, "@vararg ") then
      local _, e = comment:find([[^@vararg%s+]])
      return {declaration = {has_variadic = true, param_lines = comment:sub(e + 1)}}
    elseif vim.startswith(comment, "@return ") then
      local _, e = comment:find([[^@return%s+]])
      return {declaration = {returns = comment:sub(e + 1)}}
    else
      return {lines = comment}
    end
  end
end

function Processor.parse_declaration(self, i, node)
  local name, text = self:_matched(i, node)
  if name == "param" and self._joined then
    return {declaration = {params = text}}
  elseif name == "comment" then
    self._joined = true
    return nil, self.STAGE.PARSE_COMMENT, true
  end
end

Processor.STAGES = {
  [Processor.STAGE.PARSE_COMMENT] = Processor.parse_comment,
  [Processor.STAGE.SEARCH_DECLARATION] = Processor.search_declaration,
  [Processor.STAGE.PARSE_DECLARATION] = Processor.parse_declaration,
}

function M.collect(self)
  local all_nodes = {}

  local modules = Modules.new(self.target_dir)
  local paths = Path.new(self.target_dir):glob(self.pattern)
  for _, path in ipairs(paths) do
    local processor = Processor.new(modules, path)
    local iter = processor:iter()
    local nodes = Parser.new(processor, iter):parse()
    vim.list_extend(all_nodes, nodes)
  end

  return all_nodes
end

return M
