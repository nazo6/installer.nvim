local wrap = require("plenary.async.async").wrap
local void = require("plenary.async.async").void

local config = require("installer/config")
local status = require("installer/status")

local fs = require("installer/utils/fs")
local jobs = require("installer/utils/jobs")
local display = require("installer/utils/display")
local log = require("installer/utils/log")

local M = {}

local exec_display = wrap(function(title, script, cwd, on_exit)
  local id = display.open(title .. " - installing", { "Installing..." }, 1)
  jobs.exec_script(script, cwd, function(type, data)
    display.update(id, nil, { "  [" .. type .. "] " .. data })
  end, function(_, code)
    display.update(id, title .. " - completed", { "Exit code: " .. tostring(code) })
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

    if config.get().pre_install_hook then
      config.get().pre_install_hook(category, name)
    end

    vim.fn.mkdir(path, "p")

    local install_script = status.get_module(category, name).install_script()

    local _, code = exec_display("Install: " .. category .. "/" .. name, install_script, path)

    if code ~= 0 then
      local mes = ""
      if vim.fn.isdirectory(path) ~= 1 then
        mes = "Something is wrong."
      end
      if vim.fn.delete(path, "rf") ~= 0 then
        mes = "Couldn't delete directory. Please delete it manually. Path is: " .. path
      end
      log.error("Install failed!: " .. mes)
    end

    if config.get().post_install_hook then
      config.get().post_install_hook(category, name)
    end
  end)()
end

M.uninstall = function(category, name)
  void(function()
    local path = fs.module_path(category, name)
    if vim.fn.isdirectory(path) ~= 1 then
      error("[installer.nvim] Specified module is not installed")
    end
    if vim.fn.delete(path, "rf") ~= 0 then
      error("Couldn't delete directory. Please delete it manually. Path is: " .. path)
    end

    local uninstall_script = status.get_module(category, name).uninstall_script
    if uninstall_script ~= nil then
      uninstall_script = uninstall_script()
      local _, code = exec_display(category .. "/" .. name, path, uninstall_script)

      if code ~= 0 then
        log.error("Uninstall failed!")
      end

      if config.get().post_install_hook then
        config.get().post_install_hook(category, name)
      end
    end
  end)()
end

M.reinstall = function(category, name)
  M.uninstall(category, name)
  M.install(category, name)
end

M.module_path = fs.module_path

--- Register user-defined module.
--- @param category module_category
--- @param name module_name
--- @param module module
M.register = function(category, name, module)
  local user_modules = require("installer/config").get().custom_modules
  if user_modules[category] == nil then
    user_modules[category] = {}
  end
  user_modules[category][name] = module
end

--- Setup installer.nvim with options.
--- @param opts config|fun(old_config:config):config
M.setup = function(opts)
  if vim.fn.isdirectory(fs.base_path) ~= 1 then
    vim.fn.mkdir(fs.base_path, "p")
  end
  if opts then
    config.set(opts)
  end

  local ensure_install = config.get().ensure_install
  if ensure_install then
    local installed = require("installer/status/installed").get_modules()
    for category, modules_name in pairs(ensure_install) do
      for _, module_name in ipairs(modules_name) do
        if installed[category] == nil then
          M.install(category, module_name)
        elseif installed[category][module_name] == nil then
          M.install(category, module_name)
        end
      end
    end
  end
end

return M
