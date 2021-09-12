local M = {}

--- Is windows
M.is_windows = false
if vim.fn.has("win32") == 1 then
  M.is_windows = true
end

return M
