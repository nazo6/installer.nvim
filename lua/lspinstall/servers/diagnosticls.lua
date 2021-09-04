return require("lspinstall/helpers").npm.builder {
  install_package = "diagnostic-languageserver",
  lang = "diagnosticls",
  inherit_lspconfig = true,
}
