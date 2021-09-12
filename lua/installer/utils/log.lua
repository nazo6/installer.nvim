local Path = require("plenary/path")
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

M.log = function(message, type)
  if log then
    local log_path = Path.joinpath(vim.fn.stdpath("cache"), "installer.log")
    local datetime = vim.fn.strftime("%F %T")
    log_path:write("[" .. datetime .. "][" .. type or "log" .. "] " .. message)
  end
end

return M
