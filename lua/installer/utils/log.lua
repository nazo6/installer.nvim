local M = {}

local logger = require("plenary.log").new({
  plugin = "installer",
  level = "debug",
  use_console = false,
})

M.error = function(...)
  logger.error(...)
  error("[installer.nvim] ".. table.concat({...}, " "))
end

M.print = function(...)
  logger.info(...)
  print("[installer.nvim]", ...)
end

M.debug_log = function(...)
  if not require("installer/config").get().debug then
    return
  end

  logger.debug(...)
end
M.log = function(message, type)
  logger[type](message)
end

return M
