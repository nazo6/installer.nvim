local npm = require("lspinstall/helpers").npm

return {
  install_script = npm.install_script "vscode-langservers-extracted",
  default_config = {
    cmd = { "node", npm.bin_path "vscode-json-language-server", "--stdio" },
    filetypes = { "json" },
    root_dir = require("lspconfig").util.root_pattern(".git", vim.fn.getcwd()),
    init_options = {
      provideFormatter = true,
    },
  },
}
