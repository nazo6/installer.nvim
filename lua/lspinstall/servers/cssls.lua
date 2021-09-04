return {
  install_script = function()
    local npm = require("lspinstall/helpers").npm
    npm.install_script "vscode-langservers-extracted"
  end,
  lsp_config = function()
    local npm = require("lspinstall/helpers").npm
    local config = require("lspinstall/util").extract_config "cssls"
    config.default_config.cmd[1] = npm.bin_path(config.default_config.cmd[1])
    return config
  end,
}
