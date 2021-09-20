local get_module = require("installer/status").get_module

local M = {}

--- Get path path
M.get = function(name)
  local config = get_module("da", name)
  return config.path()
end

return M
