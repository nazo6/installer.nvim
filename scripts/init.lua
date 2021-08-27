local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

fn.system { "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path }
execute "packadd packer.nvim"

local packer = require "packer"

packer.startup {
  function(use)
    use { "wbthomason/packer.nvim" }
    use { "neovim/nvim-lspconfig" }
    use { "nazo6/lspinstall.nvim" }
  end,
}
vim.cmd [[autocmd User PackerComplete quitall]]
vim.cmd "PackerSync"
