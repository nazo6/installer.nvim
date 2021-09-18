return require("installer/integrations/ls/helpers").npm.builder({
  install_package = "vscode-langservers-extracted",
  lang = "html",
  inherit_lspconfig = true,
})
