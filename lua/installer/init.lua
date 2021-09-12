local wrap = require("plenary.async.async").wrap
local void = require("plenary.async.async").void

local modules = require("installer/modules")

local fs = require("installer/utils/fs")
local jobs = require("installer/utils/jobs")
local display = require("installer/utils/display")
local log = require("installer/utils/log")

local M = {}

M.config = {}

--- @alias module_name string Installer module name. "installer/builtins/<category>/name" or installer registerd by user will be loaded.
--- @alias install_script fun(os: "windows"|"mac"|"linux"):string Function to return shell script to install
--- @alias module {install_script: install_script}

--- @alias module_category_content table<module_name, module>

local exec_display = wrap(function(title, script, cwd, on_exit)
  local id = display.open(title, { "installing..." }, 1)
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

    if M.config.pre_install_hook then
      M.config.pre_install_hook(category, name)
    end

    vim.fn.mkdir(path, "p")

    local install_script = modules.get_module(category, name).install_script()

    local _, code = exec_display("Install: " .. category .. "/" .. name, install_script, path)

    if code ~= 0 then
      local mes = ""
      if vim.fn.isdirectory(path) ~= 1 then
        mes = "Something is wrong."
      end
      if vim.fn.delete(path, "rf") ~= 0 then
        mes = "Couldn't delete directory. Please delete it manually. Path is: " .. path
      end
      log.error("[nvim-lspinstall] Install failed!: " .. mes)
    end

    if M.config.post_install_hook then
      M.config.post_install_hook(category, name)
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
      error("[nvim-lspinstall] Couldn't delete directory. Please delete it manually. Path is: " .. path)
    end

    local uninstall_script = modules.get_module(category, name).uninstall_script
    if uninstall_script ~= nil then
      uninstall_script = uninstall_script()
      local _, code = exec_display(category .. "/" .. name, path, uninstall_script)
    end
  end)()
end

M.update = function(category, name)
  void(function()
    local update_script = modules.get_module(category, name).update_script
    if update_script ~= nil then
      local path = fs.module_path(category, name)
      update_script = update_script()
      local _, code = exec_display(category .. "/" .. name, path, update_script)
    else
      M.reinstall(category, name)
    end
  end)()
end

M.reinstall = function(category, name)
  M.uninstall(category, name)
  M.install(category, name)
end

M.module_path = fs.module_path

--- Setup installer.nvim.
--- @param opts {custom_modules: tbl<string, {install_script: function, uninstall_script:function, lsp_config:function}[]>, post_install_hook: function, pre_install_hook: function}
M.setup = function(opts)
  M.config = opts or {}
end

return M
