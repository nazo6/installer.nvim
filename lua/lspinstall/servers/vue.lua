local config = require"lspinstall/util".extract_config("vuels")
local npm = require "lspinstall/helpers".npm

local package_name = "vls"
config.default_config.cmd[1] = npm.bin_path(package_name)
return vim.tbl_extend("error", config, {
  install_script = npm.install_script(package_name),
})
