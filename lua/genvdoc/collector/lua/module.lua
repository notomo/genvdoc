local Modules = {}
Modules.__index = Modules

function Modules.new(dir)
  local full_path = vim.fn.fnamemodify(dir, ":p")
  local lua_dir = vim.fs.joinpath(full_path, "lua/")
  local tbl = {
    _dir_path = lua_dir,
  }
  return setmetatable(tbl, Modules)
end

function Modules.from_path(self, path)
  local module_path
  if vim.fs.basename(path) == "init.lua" then
    local dir = vim.fs.dirname(path)
    module_path = vim.fs.normalize(dir)
  else
    module_path = vim.fn.fnamemodify(path, ":r")
  end

  local relative_path = vim.fs.relpath(self._dir_path, module_path) or module_path
  return table.concat(vim.split(relative_path, "/", { plain = true }), ".")
end

return Modules
