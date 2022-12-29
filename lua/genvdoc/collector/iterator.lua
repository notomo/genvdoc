local M = {}
M.__index = M

function M.new(iterator)
  local tbl = {
    _iterator = iterator,
    _will_be_back = false,
    _before = nil,
  }
  return setmetatable(tbl, M)
end

function M.next(self)
  if self._will_be_back then
    self._will_be_back = false
    return unpack(self._before)
  end
  self._before = { self._iterator() }
  return unpack(self._before)
end

function M.back(self)
  self._will_be_back = true
end

return M
