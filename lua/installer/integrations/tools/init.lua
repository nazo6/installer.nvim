local log = require("installer/utils/log")
local get_module = require("installer/status").get_module

local M = {}

M.get_all = function()
  local res = {}
  local modules = require("installer/status/installed").get_modules()
  for module, _ in pairs(modules["tools"]) do
    local a = M.get(module)
    for _, value in ipairs(a) do
      table.insert(res, value)
    end
  end

  return res
end

--- Get bin path
M.get = function(name)
  local config = get_module("tools", name)
  return config.cmd()
end

return M
