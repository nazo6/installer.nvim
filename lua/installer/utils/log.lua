local M = {}

local log = true

M.error = function(message, level)
  M.log(message, "error")
  error("[installer.nvim] " .. message, level)
end

M.print = function(message)
  M.log(message, "print")
  print("[installer.nvim]  " .. message)
end

local logger = require("plenary.log").new({ plugin = "installer.nvim", use_console = false, level = "debug" })
M.log = function(message, type)
  if log then
    require("null-ls.logger").debug("[" .. type .. "] " .. message)
  end
end

return M
