local Path = require("genvdoc.lib.path").Path

local Modules = {}
Modules.__index = Modules

function Modules.new(dir)
  local lua_dir = Path.new(dir):join("lua/")
  local tbl = { _dir = lua_dir }
  return setmetatable(tbl, Modules)
end

function Modules.from_path(self, path)
  local module_path
  if Path.new(path):head() == "init.lua" then
    module_path = Path.new(path):parent():trim_slash():get()
  else
    module_path = Path.new(path):without_ext()
  end
  local relative_path = self._dir:relative(module_path)
  return table.concat(vim.split(relative_path, "/", true), ".")
end

return Modules
