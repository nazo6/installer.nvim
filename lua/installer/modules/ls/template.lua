-- npm template
--
-- install_package: package name to install
-- lang: Language server name (install folder name)
-- inherit_lspconfig: Use lspconfig's config. Default is true.
-- bin_name: Binary name in `node_modules/.bin`. Can be omitted if inherit_lspconfig is true.
-- config: config to overwrite. Or, you can provide function to modify.
require("installer/helpers").npm.builder {
  install_package = "",
  lang = "",
  inherit_lspconfig = true,
  bin_name = "",
  config = {},
}

-- common template
--
-- lang: Same as above
-- inherit_lspconfig: Same as above
-- install_script: script used to install.
-- cmd: string or table. If string provided, first element of cmd is replaced with it. If table, all elements is replaced.
-- Path will be converted to absolute path in either.
require("installer/helpers").common.builder {
  lang = "",
  inherit_lspconfig = true,
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = cmd_win,
    other = cmd,
  },
}
