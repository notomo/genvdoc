local M = {}

function M.find(path)
  local ok, module = pcall(require, path)
  if not ok then
    return nil, "not found: " .. path
  end
  return module, nil
end

return M
