local util = require "lspinstall/util"
local config = require("lspinstall/util").extract_config "angularls"
local npm = require("lspinstall/helpers").npm

local cmd_name = config.default_config.cmd[1]
local node_module_path = util.install_path "angularls" .. "/node_modules/"

local prefix = ""
if util.is_windows() then
  prefix = ".cmd"
end

config.default_config.cmd[1] = npm.bin_path(cmd_name)
config.default_config.cmd[6] = node_module_path

return vim.tbl_extend("force", config, {
  install_script = function()
    return npm.install_script "@angular/language-server" .. [[
    ]] .. npm.install_script "@angular/language-service"
  end,
  on_new_config = function(new_config)
    new_config.cmd[1] = node_module_path .. ".bin/" .. cmd_name .. prefix
    new_config.cmd[6] = node_module_path
  end,
})
