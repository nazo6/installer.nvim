return require("installer/integrations/ls/helpers").npm.builder({
  install_package = "vscode-langservers-extracted",
  lang = "cssls",
  inherit_lspconfig = true,
})
