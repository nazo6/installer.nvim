local wrap = require("plenary.async.async").wrap
local void = require("plenary.async.async").void
local schedule = require("plenary.async.util").schedule

local util = require "installer/util"
local fs = require "installer/utils/fs"
local modules = require "installer/modules"
local jobs = require "installer/utils/jobs"
local display = require "installer/display"

local M = {}

local config = {}

--- @alias module_category "ls"|"da"|"other"|string Installer module type.
--- @alias module_name string Installer module name. "installer/builtins/<category>/name" or installer registerd by user will be loaded.
--- @alias install_script fun(os: "windows"|"mac"|"linux"):string Function to return shell script to install
--- @alias module {install_script: install_script}

--- @alias module_category_content table<module_name, module>

local exec_display = wrap(function(title, script, cwd, on_exit)
  display.open()
  local display_id = display.add(title)
  jobs.exec_script(script, cwd, function(type, data)
    display.update(display_id, "", data)
  end, function(_, code)
    display.update(display_id, "", tostring(code))
    on_exit(_, code)
  end)
end, 4)

--- Install module
--- @param category module_category
--- @param name module_name
M.install = function(category, name)
  void(function()
    local path = fs.module_path(category, name)
    if vim.fn.isdirectory(path) ~= 0 then
      local choice = vim.fn.confirm(
        "[installer.nvim] It seems like specified module already exists. Do you reinstall it? ",
        "Yes\nNo"
      )
      if choice ~= 0 then
        M.reinstall(category, name)
      end
      return
    end
    vim.fn.mkdir(path, "p")

    local install_script = modules.get_module(category, name).install_script()

    local _, code = exec_display(category .. "/" .. name, install_script, path)
  end)()
end

M.uninstall = function(category, name)
  local path = fs.module_path(category, name)
  if vim.fn.isdirectory(path) ~= 1 then
    error "[installer.nvim] Specified module is not installed"
  end
  if vim.fn.delete(path, "rf") ~= 0 then
    error("[nvim-lspinstall] Couldn't delete directory. Please delete it manually. Path is: " .. path)
  end

  local uninstall_script = modules.get_module(category, name).uninstall_script
  if uninstall_script ~= nil then
    local _, code = a.await(exec_display(category .. "/" .. name, path, uninstall_script))
  end
end

M.reinstall = function(category, name)
  M.uninstall(category, name)
  M.install(category, name)
end

M.setup = function(opts)
  config = opts
end

return M
