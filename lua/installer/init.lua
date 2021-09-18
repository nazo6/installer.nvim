local wrap = require("plenary.async.async").wrap
local void = require("plenary.async.async").void

local config = require("installer/config")
local status = require("installer/status")

local fs = require("installer/utils/fs")
local jobs = require("installer/utils/jobs")
local display = require("installer/utils/display")
local log = require("installer/utils/log")

local check = "✓"
local error = "✗"

local M = {}

local exec = wrap(function(title, content, script, cwd, on_update, on_exit)
  local id = display.open(title, { content }, 1)
  local updater = function(new_title, new_message)
    display.update(id, new_title, { new_message })
  end
  jobs.exec_script(script, cwd, function(type, data)
    on_update(type, data, updater)
  end, function(a, b)
    on_exit(a, b, updater)
  end)
  return updater
end, 6)

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

  local _, code, update = exec(
    "Installing " .. category .. "/" .. name,
    "",
    install_script,
    path,
    function(_, data, update)
      update(nil, data)
    end
  )

  if code ~= 0 then
    local mes = ""
    if vim.fn.isdirectory(path) ~= 1 then
      mes = "Something is wrong."
    end
    if vim.fn.delete(path, "rf") ~= 0 then
      mes = "Couldn't delete directory. Please delete it manually. Path is: " .. path
    end
    update(error .. "Failed to uninstall " .. category .. "/" .. name, "code: " .. code .. " mes:" .. mes)
    return
  end

  update(check .. "Installed " .. category .. "/" .. name, "")
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

  local _, code, update = exec(
    "Uninstalling " .. category .. "/" .. name,
    "",
    uninstall_script,
    path,
    function(_, data, update)
      update(nil, data)
    end
  )

  if code ~= 0 then
    return
  end

  if code ~= 0 then
    update(error .. "Failed to uninstall " .. category .. "/" .. name, "code: " .. code)
    log.error("Failed to uninstall", category, name)
    return
  end

  update(check .. "Uninstalled " .. category .. "/" .. name, "")
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

    local _, code, update = exec(
      "Updating " .. category .. "/" .. name,
      "",
      update_script,
      path,
      function(_, data, update)
        update(nil, data)
      end
    )
    if code ~= 0 then
      update(error .. "Failed to update " .. category .. "/" .. name, "code: " .. code .. " Falling back to reinstall.")
      log.error("Failed to update", category, name)
      M.reinstall(category, name)
      return
    end

    update(check .. "Updated " .. category .. "/" .. name, "")
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
