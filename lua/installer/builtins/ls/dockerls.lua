return require("installer/integrations/ls/helpers").npm.builder({
  install_package = "dockerfile-language-server",
  lang = "dockerls",
  inherit_lspconfig = true,
})
