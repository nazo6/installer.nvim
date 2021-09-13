local log = require("installer.utils.log")
local M = {}

--- @alias install_script fun(os: "windows"|"mac"|"linux"):string Function to return shell script to install
--
--- @alias module {install_script: install_script}
--- @alias module_name string Installer module name.
--- @alias module_category "ls"|"null-ls"|"da"|string Category of module
--- @alias module_category_content table<module_name, module>
--- @alias categories table<module_category, module_category_content>

--- @alias post_install_hook fun(category:module_category, name:string):nil
--- @alias pre_install_hook fun(category:module_category, name:string):nil
--- @alias ensure_install tbl<module_category, module_name[]>

--- @alias config {ensure_install: ensure_install, custom_modules: categories[], post_install_hook: post_install_hook, pre_install_hook: pre_install_hook, debug: boolean}

local default_config = {
  debug = false,
  custom_modules = {},
}

--- @type config
local config = default_config

--- Set config
M.set = function(opts)
  if type(opts) == "function" then
    config = opts(config)
  elseif type(opts) == "table" then
    config = vim.tbl_deep_extend("force", config, opts)
  else
    log.error("Invalid config!")
  end
end

--- Set config of specified key of config table
M.set_key = function(key, opts)
  if type(opts) == "function" then
    config[key] = opts(config[key])
  elseif type(opts) == "table" then
    config[key] = opts
  else
    log.error("Invalid config!")
  end
end

M.get = function()
  return config
end

return M
