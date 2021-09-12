local log = require("installer/utils/log")

local M = {}

M.config = nil

M.setup = function(opts)
  M.config = opts or {}
end

M.ensure_setup = function()
  if M.config == nil then
    log.error("Please setup first.")
  end
end

return M
