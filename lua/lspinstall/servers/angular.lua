local config = require("lspinstall/util").extract_config "angularls"
local npm = require("lspinstall/helpers").npm

local package_name = "@angular/language-server"
config.default_config.cmd[1] = npm.bin_path(package_name)
return vim.tbl_extend("error", config, {
  install_script = npm.install_script(package_name),
})
