local M = {}

M.find_root = function(pattern)
  local file = vim.api.nvim_get_runtime_file("lua/" .. pattern, false)[1]
  if file == nil then
    return nil, "project root directory not found by pattern: " .. pattern
  end
  return vim.split(M.adjust_sep(file), "/lua/", true)[1], nil
end

if vim.fn.has("win32") == 1 then
  M.adjust_sep = function(path)
    return path:gsub("\\", "/")
  end
else
  M.adjust_sep = function(path)
    return path
  end
end

local Path = {}
Path.__index = Path
M.Path = Path

function Path.new(path)
  local p = vim.fn.fnamemodify(path, ":p")
  if not vim.endswith(path, "/") and vim.endswith(p, "/") then
    p = p:sub(1, #p - 1)
  end
  local tbl = {path = p}
  return setmetatable(tbl, Path)
end

function Path.__tostring(self)
  return self.path
end

function Path.get(self)
  return self.path
end

function Path.join(self, ...)
  local items = {}
  local slash = false
  for _, item in ipairs({self.path, ...}) do
    if vim.endswith(item, "/") then
      item = item:sub(1, #item - 1)
      slash = true
    else
      slash = false
    end
    table.insert(items, item)
  end

  local path = table.concat(items, "/")
  if slash then
    path = path .. "/"
  end

  return self.new(path)
end

function Path.head(self)
  if not vim.endswith(self.path, "/") or self.path == "/" then
    return vim.fn.fnamemodify(self.path, ":t")
  end
  return vim.fn.fnamemodify(self.path, ":h:t") .. "/"
end

function Path.parent(self)
  if vim.endswith(self.path, "/") then
    return self.new(vim.fn.fnamemodify(self.path, ":h:h"))
  end
  return self.new(vim.fn.fnamemodify(self.path, ":h"))
end

function Path.trim_slash(self)
  if not vim.endswith(self.path, "/") or self.path == "/" then
    return self.new(self.path)
  end
  return self.new(self.path:sub(1, #self.path - 1))
end

function Path.delete(self)
  return vim.fn.delete(self.path, "rf")
end

function Path.mkdir(self)
  vim.fn.mkdir(self.path, "p")
end

function Path.create(self)
  if vim.endswith(self.path, "/") then
    self:mkdir()
    return
  end
  io.open(self.path, "w"):close()
end

function Path.write(self, content)
  self.new(self:parent():get()):mkdir()
  local f = io.open(self.path, "w")
  f:write(content)
  f:close()
end

function Path.iter_lines(self)
  local f = io.open(self.path, "r")
  local get = f:lines()
  return function()
    local line = get()
    if line ~= nil then
      return line
    end
    f:close()
  end
end

function Path.relative(self, path)
  local pattern = "^" .. M.adjust_sep(self.path):gsub("([^%w])", "%%%1")
  return M.adjust_sep(path):gsub(pattern, "", 1)
end

function Path.without_ext(self)
  return vim.fn.fnamemodify(self.path, ":r")
end

function Path.glob(self, pattern)
  local full_pattern = self:join(pattern):get()
  return vim.fn.glob(full_pattern, true, true)
end

return M
