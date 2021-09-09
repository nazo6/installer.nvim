
--return vim.tbl_extend("error", config, {
--  install_script = script_to_use,
--})
return require("lspinstall/helpers").pip.builder {
  lang = "cmake",
  inherit_lspconfig = true,
  install_package = "cmake-language-server",
}
