local config = require("lspinstall/util").extract_config "intelephense"
local npm = require("lspinstall/helpers").npm

local package_name = "intelephense"
config.default_config.cmd[1] = npm.bin_path(config.default_config.cmd[1])
return vim.tbl_extend("error", config, {
  install_script = npm.install_script(package_name),
})
