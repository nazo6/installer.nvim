return require("installer/integrations/ls/helpers").npm.builder({
  install_package = "emmet-ls",
  lang = "emmet_ls",
  bin_name = "emmet-ls",
  inherit_lspconfig = false,
  config = {
    default_config = {
      cmd = { "emmet-ls", "--stdio" },
      filetypes = { "html", "css" },
      root_dir = function(fname)
        return vim.loop.cwd()
      end,
      settings = {},
    },
  },
})
