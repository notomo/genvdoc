local M = {}

local ChapterSetting = {}
ChapterSetting.__index = ChapterSetting
M.ChapterSetting = ChapterSetting

function ChapterSetting.new(cls, setting)
  vim.validate({cls = {cls, "table"}, setting = {setting, "table"}})

  local group = setting.group or function(_)
    return nil
  end

  local name
  if type(setting.name) == "function" then
    name = setting.name
  else
    name = function(_)
      return setting.name
    end
  end

  local tbl = {_group = group, _name = name, _cls = cls, _setting = setting}
  return setmetatable(tbl, ChapterSetting)
end

function ChapterSetting.group(self, nodes)
  vim.validate({nodes = {nodes, "table"}})

  local groups = {}
  for _, node in ipairs(nodes) do
    local group_name = self._group(node)
    if group_name == nil then
      goto continue
    end

    local group_nodes = groups[group_name] or {}
    table.insert(group_nodes, node)
    groups[group_name] = group_nodes

    ::continue::
  end

  local group_names = vim.tbl_keys(groups)
  if #group_names == 0 then
    table.insert(group_names, self._setting.name)
  end
  table.sort(group_names, function(a, b)
    return a < b
  end)

  return vim.tbl_map(function(group_name)
    local name = self._name(group_name)
    return self._cls.new(name, group_name, groups[group_name], self._setting.body)
  end, group_names)
end

return M
