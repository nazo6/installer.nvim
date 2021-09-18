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
    log.debug_log("[exec_display]", id, type, data)
    display.update(id, nil, { "  [" .. type .. "] " .. data })
  end, function(_, code)
    display.update(id, title .. " - completed", { "Exit code: " .. tostring(code) })
    on_exit(_, code)
  end)
end, 4)

local exec_hooks = function(type, timing, category, name)
  local hooks = config.get().hooks[type][timing]
  if hooks then
    for _, hook in ipairs(hooks) do
      hook(category, name)
    end
  end
end

--- Install module
--- @param category module_category
--- @param name module_name
local install = function(category, name)
  if not status.get_module(category, name) then
    error("[installer.nvim] Such module is not available")
  end
  local path = fs.module_path(category, name)
  if vim.fn.isdirectory(path) ~= 0 then
    local choice = vim.fn.confirm(
      "[installer.nvim] It seems like module '" .. category .. "/" .. name .. "' already exists. Do you reinstall it? ",
      "Yes\nNo"
    )
    if choice ~= 0 then
      M.reinstall(category, name)
    end
    return
  end

  exec_hooks("install", "pre", category, name)

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

  log.debug_log("[install]", "Successfully installed ", category, "/", name)
  exec_hooks("install", "post", category, name)
end
M.install = void(install)

local uninstall = function(category, name)
  local path = fs.module_path(category, name)
  if vim.fn.isdirectory(path) ~= 1 then
    error("[installer.nvim] Specified module is not installed")
  end

  exec_hooks("uninstall", "pre", category, name)

  local uninstall_script = status.get_module(category, name).uninstall_script
  if uninstall_script ~= nil then
    uninstall_script = uninstall_script()
  else
    local is_win = require("installer/utils/os").is_windows
    if is_win then
      uninstall_script = "cd ../ && rm -Force " .. name
    else
      uninstall_script = "cd ../ && rm -rf " .. name
    end
  end

  local _, code = exec_display(category .. "/" .. name, uninstall_script, path)

  if code ~= 0 then
    log.error("Failed to uninstall", category, name)
  end

  exec_hooks("uninstall", "post", category, name)
end
M.uninstall = void(uninstall)

local reinstall = function(category, name)
  uninstall(category, name)
  install(category, name)
end
M.reinstall = void(reinstall)

local update = function(category, name)
  local path = fs.module_path(category, name)
  if vim.fn.isdirectory(path) ~= 1 then
    error("[installer.nvim] Specified module is not installed")
  end

  exec_hooks("update", "pre", category, name)

  local update_script = status.get_module(category, name).update_script
  if update_script ~= nil then
    update_script = update_script()
    local _, code = exec_display(category .. "/" .. name, path, update_script)

    if code ~= 0 then
      log.error("Failed to update", category, name)
    end
  else
    M.reinstall(category, name)
  end

  exec_hooks("update", "post", category, name)
end
M.update = void(update)

M.update_all = function()
  local installed = require("installer/status/installed").get_modules()
  for category, modules in pairs(installed) do
    for module, _ in pairs(modules) do
      M.update(category, module)
    end
  end
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
