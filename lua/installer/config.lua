local log = require("installer/utils/log")
local M = {}

--- @alias install_script fun(os: "windows"|"mac"|"linux"):string Function to return shell script to install
--
--- @alias module {install_script: install_script}
--- @alias module_name string Installer module name.
--- @alias module_category "ls"|"null_ls"|"da"|string Category of module
--- @alias module_category_content table<module_name, module>
--- @alias categories table<module_category, module_category_content>

--- @alias hook fun(category:string, name:string):nil[]
--- @alias hooks {install: {pre: hook, post:hook}, uninstall: {pre: hook, post:hook}}

--- @alias post_install_hook fun(category:module_category, name:string):nil
--- @alias pre_install_hook fun(category:module_category, name:string):nil
--- @alias ensure_install tbl<module_category, module_name[]>

--- @alias config {ensure_install: ensure_install, custom_modules: categories[], hooks: hooks, debug: boolean}

local default_config = {
  debug = false,
  custom_modules = {},
  hooks = {
    install = {
      pre = {},
      post = {},
    },
    uninstall = {
      pre = {},
      post = {},
    },
  },
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
--- @param keys string[]
--- @param value table|fun(old_config:any):any
M.set_key = function(keys, value)
  local c = config
  for _, key in ipairs(keys) do
    if not c[key] then
      c[key] = {}
    end
    c = c[key]
  end
  if type(value) == "function" then
    c = value(config[c])
  elseif type(value) == "table" then
    c = value
  else
    log.error("Invalid config!")
  end
end

M.get = function()
  return config
end

return M
