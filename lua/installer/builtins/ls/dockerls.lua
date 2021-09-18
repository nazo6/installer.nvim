return require("installer/integrations/ls/helpers").npm.builder({
  install_package = "dockerfile-language-server-nodejs",
  lang = "dockerls",
  inherit_lspconfig = true,
})
