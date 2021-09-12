return require("installer/integrations/ls/helpers").npm.builder({
  install_package = "diagnostic-languageserver",
  lang = "diagnosticls",
  inherit_lspconfig = true,
})
