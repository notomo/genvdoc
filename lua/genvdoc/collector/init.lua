local M = {}

function M.collect(raw_source)
  local all_nodes = {}
  for _, pattern in ipairs(raw_source.patterns) do
    local nodes = require("genvdoc.collector.lua").collect(pattern)
    vim.list_extend(all_nodes, nodes)
  end
  return all_nodes
end

return M
