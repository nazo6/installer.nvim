local config = require("lspinstall/util").extract_config "sqlls"
local npm = require("lspinstall/helpers").npm

-- sqlls's path is not provided by lspconfig
config.default_config.cmd = {npm.bin_path("sql-language-server")}
return vim.tbl_extend("error", config, {
  install_script = npm.install_script "sql-language-server",
})
