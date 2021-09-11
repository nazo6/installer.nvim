local util = require "installer/util"
local modules = require "installer/modules"
local jobs = require "installer/jobs"
local display = require "installer/display"

local M = {}

local config = {}

--- @alias module_category "ls"|"da"|"other"|string Installer module type.
--- @alias module_name string Installer module name. "installer/builtins/<category>/name" or installer registerd by user will be loaded.
--- @alias install_script fun(os: "windows"|"mac"|"linux"):string Function to return shell script to install
--- @alias module {install_script: install_script}

--- @alias module_category_content table<module_name, module>

--- Install module
--- @param category module_category
--- @param name module_name
M.install = function(category, name)
  local path = util.install_path(category, name)
  if vim.fn.isdirectory(path) ~= 0 then
    local choice = vim.fn.confirm(
      "[installer.nvim] It seems like specified module already exists. Do you reinstall it? ",
      "Yes\nNo"
    )
    if choice ~= 0 then
      M.reinstall(category, name)
    else
      return
    end
  end
  vim.fn.mkdir(path, "p")

  local install_script = modules.get_module(category, name).install_script()

  if config.pre_install_hook then
    config.pre_install_hook()
  end

  display.open()
  local display_id = display.add(category .. "/" .. name, "")
  jobs.exec_script(install_script, path, function(type, data)
    display.update(display_id, "", data)
  end, function(_, code)
    if code ~= 0 then
      if vim.fn.delete(path, "rf") ~= 0 then -- here 0: success, -1: fail
      end
    end
    display.update(display_id, "", code)

    if M.post_install_hook then
      M.post_install_hook()
    end
  end)
end

M.uninstall = function(category, name)
  local path = util.install_path(category, name)
  if vim.fn.isdirectory(path) ~= 1 then
    error "[installer.nvim] Specified module is not installed"
  end
  if vim.fn.delete(path, "rf") ~= 0 then
    error("[nvim-lspinstall] Couldn't delete directory. Please delete it manually. Path is: " .. path)
  end
  local uninstall_script = modules.get_module(category, name).uninstall_script
end

M.reinstall = function(category, name)
  local path = util.install_path(category, name)
end

M.setup = function(opts)
  config = opts
end

return M
