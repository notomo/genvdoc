local M = {}

function M.grouping(raw_setting, nodes)
  vim.validate({
    raw_setting = { raw_setting, "table" },
    nodes = { nodes, "table" },
  })

  local group = raw_setting.group or function(_)
    return nil
  end

  local to_chapter_name
  if type(raw_setting.name) == "function" then
    to_chapter_name = raw_setting.name
  else
    to_chapter_name = function(_)
      return raw_setting.name
    end
  end

  local groups = {}
  for _, node in ipairs(nodes) do
    local group_name = group(node)
    if group_name == nil then
      goto continue
    end

    local group_nodes = groups[group_name] or {}
    table.insert(group_nodes, node)
    groups[group_name] = group_nodes

    ::continue::
  end

  local group_names = vim.tbl_keys(groups)
  if #group_names == 0 and type(raw_setting.name) == "string" then
    table.insert(group_names, raw_setting.name)
  end
  table.sort(group_names, function(a, b)
    return a < b
  end)

  return vim.tbl_map(function(group_name)
    local name = to_chapter_name(group_name)
    return require("genvdoc.documentor.help.chapter").new(name, group_name, groups[group_name], raw_setting.body)
  end, group_names)
end

return M
