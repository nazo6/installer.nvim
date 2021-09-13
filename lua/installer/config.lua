local log = require("installer.utils.log")
local M = {}

--- @alias install_script fun(os: "windows"|"mac"|"linux"):string Function to return shell script to install
--
--- @alias module {install_script: install_script}
--- @alias module_name string Installer module name.
--- @alias module_category "ls"|"null-ls"|"da"|string Category of module
--- @alias module_category_content table<module_name, module>
--- @alias user_module table<module_category, module_category_content>

--- @alias post_install_hook fun(category:module_category, name:string):nil
--- @alias pre_install_hook fun(category:module_category, name:string):nil

--- @alias config {custom_modules: user_module[], post_install_hook: post_install_hook, pre_install_hook: pre_install_hook, debug: boolean}

local default_config = {
  debug = true,
}

--- @type config
local config = { default_config }

M.set_config = function(opts)
  if type(opts) == "function" then
    config = opts(config)
  elseif type(opts) == "table" then
    config = opts
  else
    log.error("Invalid config!")
  end
end

M.get_config = function()
  return config
end

return M
