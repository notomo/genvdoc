local tablelib = require("genvdoc.vendor.misclib.collection.table")

local M = {}

--- @param raw_setting table
local new_setting = function(raw_setting)
  local name = function(_)
    return raw_setting.name
  end
  local raw_name
  if type(raw_setting.name) == "function" then
    name = raw_setting.name
  elseif type(raw_setting.name) == "string" then
    raw_name = raw_setting.name
  end

  return {
    group = raw_setting.group or function(_) end,
    name = name,
    body = raw_setting.body,
    raw_name = raw_name,
  }
end

--- @param nodes table
function M.grouping(new_chapter, raw_setting, nodes)
  local chapter_setting = new_setting(raw_setting)
  local groups = tablelib.group_by(nodes, chapter_setting.group)

  local group_names = vim.tbl_keys(groups)
  if #group_names == 0 and chapter_setting.raw_name then
    table.insert(group_names, chapter_setting.raw_name)
  end
  table.sort(group_names, function(a, b)
    return a < b
  end)

  return vim
    .iter(group_names)
    :map(function(group_name)
      local name = chapter_setting.name(group_name)
      return new_chapter(name, group_name, groups[group_name], chapter_setting.body)
    end)
    :totable()
end

return M
