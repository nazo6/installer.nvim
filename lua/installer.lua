local servers = require "installer/servers"
local configs = require "lspconfig/configs"
local install_path = require("installer/util").install_path
local lsp_util = require "installer/util"

local user_configs = {}

local get_config = function(lang)
  local res, config = pcall(require, "installer/servers/" .. lang)
  if res ~= true then
    local mes = config
    config = user_configs[lang]
    if config == nil then
      error(mes)
    end
  end
  return config
end

local M = {}

-- INSTALL

function M.install_server(lang)
  if not servers[lang] then
    error("Could not find language server for " .. lang)
  end

  local path = install_path(lang)
  if vim.fn.isdirectory(path) ~= 0 then
    local choice = vim.fn.confirm(
      "[installer.nvim] It seems like specified LS already exists. Do you reinstall server? ",
      "Yes\nNo"
    )
    if choice ~= 0 then
      M.reinstall_server(lang)
    else
      return
    end
  end
  vim.fn.mkdir(path, "p") -- fail: throws

  local function onExit(_, code)
    if code ~= 0 then
      if vim.fn.delete(path, "rf") ~= 0 then -- here 0: success, -1: fail
        error("[installer.nvim] Install failed. Could not delete directory " .. lang)
      end
      error("[installer.nvim] Could not install language server for " .. lang)
    end
    vim.notify("[installer.nvim] Successfully installed language server for " .. lang)
    if M.post_install_hook then
      M.post_install_hook()
    end
  end

  local config = get_config(lang)
  if config.pre_install_hook then
    config.pre_install_hook()
  end
  local install_script = config.install_script
  if install_script == nil then
    lsp_util.print_warning("sorry no installation for your particular OS", "WarningMsg")
    return
  end
  if type(install_script) == "function" then
    install_script = install_script()
  end
  lsp_util.do_term_open(install_script, { ["cwd"] = path, ["on_exit"] = onExit })
end

function M.reinstall_server(lang)
  local path = install_path(lang)
  if vim.fn.delete(path, "rf") ~= 0 then
    error("[installer.nvim] Couldn't delete directory. Please delete it manually. Path is: " .. path)
  end
end

-- UNINSTALL

function M.uninstall_server(lang)
  if not servers[lang] then
    error("Could not find language server for " .. lang)
  end

  local path = install_path(lang)

  if vim.fn.isdirectory(path) ~= 1 then -- 0: false, 1: true
    error "Language server is not installed"
  end

  local function onExit(_, code)
    if code ~= 0 then
      error("[installer.nvim] Could not uninstall language server for " .. lang)
    end
    if vim.fn.delete(path, "rf") ~= 0 then -- here 0: success, -1: fail
      error("[installer.nvim] Could not delete directory " .. lang)
    end
    vim.notify("[installer.nvim] Successfully uninstalled language server for " .. lang)
    if M.post_uninstall_hook then
      M.post_uninstall_hook()
    end
  end

  lsp_util.do_term_open((get_config(lang).uninstall_script or ""), { cwd = path, on_exit = onExit })
end

-- UTILITY

function M.is_server_installed(lang)
  return vim.fn.isdirectory(install_path(lang)) == 1 -- 0: false, 1: true
end

function M.available_servers()
  local languages = {}
  for k in pairs(servers) do
    table.insert(languages, k)
  end
  return languages
end

function M.installed_servers()
  return vim.tbl_filter(function(key)
    return M.is_server_installed(key)
  end, M.available_servers())
end

function M.not_installed_servers()
  return vim.tbl_filter(function(key)
    return not M.is_server_installed(key)
  end, M.available_servers())
end

--- Sets the configs in lspconfig for all installed servers
function M.setup()
  for lang in pairs(servers) do
    if M.is_server_installed(lang) and not configs[lang] then -- don't overwrite existing config, leads to problems
      local server_config = get_config(lang).lsp_config()
      local config = vim.tbl_deep_extend("keep", server_config, {
        default_config = {
          cmd_cwd = install_path(lang),
        },
      })
      configs[lang] = config
    end
  end
end

function M.register_server(name, config)
  user_configs[name] = config
  servers[name] = true
end

return M
