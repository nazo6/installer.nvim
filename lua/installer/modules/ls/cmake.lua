return require("installer/helpers").pip.builder {
  lang = "cmake",
  inherit_lspconfig = true,
  install_package = "cmake-language-server",
}
