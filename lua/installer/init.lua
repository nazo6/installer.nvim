local util = require "installer/util"
local modules = require "installer/modules"

local M = {}

local config = {}

--- @alias module_type "ls"|"da"|"other"|string Installer module type.
--- @alias module_name string Installer module name. "installer/builtins/<type>/name" or installer registerd by user will be loaded.
--- @alias install_script fun(os: "windows"|"mac"|"linux"):string Function to return shell script to install
--- @alias module {install_script: install_script}

--- @alias module_type_content table<module_name, module>

local get_onexit = function(type, name)
  local path = util.install_path(type, name)
  return function(_, code)
    if code ~= 0 then
      if vim.fn.delete(path, "rf") ~= 0 then -- here 0: success, -1: fail
        error("[installer.nvim] Install failed. Could not delete directory: " .. type .. "/" .. name)
      end
      error("[installer.nvim] Could not install language server for " .. type .. "/" .. name)
    end
    vim.notify("[installer.nvim] Successfully installed language server for " .. type .. "/" .. name)
    if M.post_install_hook then
      M.post_install_hook()
    end
  end
end

--- Install module
--- @param type module_type
--- @param name module_name
M.install = function(type, name)
  local path = util.install_path(type, name)
  if vim.fn.isdirectory(path) ~= 0 then
    local choice = vim.fn.confirm(
      "[installer.nvim] It seems like specified module already exists. Do you reinstall it? ",
      "Yes\nNo"
    )
    if choice ~= 0 then
      M.reinstall(type, name)
    else
      return
    end
  end
  vim.fn.mkdir(path, "p")

  local install_script = modules.get_module(type, name).install_script()
  if config.pre_install_hook then
    config.pre_install_hook()
  end
  util.do_term_open(install_script, { ["cwd"] = path, ["on_exit"] = get_onexit(type, name) })
end

M.uninstall = function(type, name)
  local path = util.install_path(type, name)
  if vim.fn.isdirectory(path) ~= 1 then
    error "[installer.nvim] Specified module is not installed"
  end
  if vim.fn.delete(path, "rf") ~= 0 then
    error("[nvim-lspinstall] Couldn't delete directory. Please delete it manually. Path is: " .. path)
  end
  local uninstall_script = modules.get_module(type, name).uninstall_script
  if uninstall_script ~= nil then
    util.do_term_open(uninstall_script, { cwd = path, on_exit = get_onexit(type, name) })
  end
end

M.reinstall = function(type, name)
  local path = util.install_path(type, name)
end

M.setup = function(opts)
  config = opts
end
