return require("installer/helpers").npm.builder({
  install_package = "vscode-langservers-extracted",
  lang = "cssls",
  inherit_lspconfig = true,
})
