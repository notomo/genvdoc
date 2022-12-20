local pathlib = require("genvdoc.vendor.misclib.path")

local Modules = {}
Modules.__index = Modules

function Modules.new(dir)
  local full_path = vim.fn.fnamemodify(dir, ":p")
  local lua_dir = pathlib.join(full_path, "lua/")
  local tbl = {
    _dir_path = lua_dir,
  }
  return setmetatable(tbl, Modules)
end

function Modules.from_path(self, path)
  local module_path
  if pathlib.tail(path) == "init.lua" then
    local dir = pathlib.parent(path)
    module_path = pathlib.trim_slash(dir)
  else
    module_path = vim.fn.fnamemodify(path, ":r")
  end

  local pattern = "^" .. pathlib.normalize(self._dir_path):gsub("([^%w])", "%%%1")
  local relative_path = pathlib.normalize(module_path):gsub(pattern, "", 1)

  return table.concat(vim.split(relative_path, "/", true), ".")
end

return Modules
