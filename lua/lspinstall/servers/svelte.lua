local config = require"lspinstall/util".extract_config("svelte")
local npm = require "lspinstall/helpers".npm

config.default_config.cmd[1] = npm.bin_path("svelteserver")
return vim.tbl_extend("error", config, {
  install_script = npm.install_script("svelte-language-server"),
})
