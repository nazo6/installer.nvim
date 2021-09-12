return require("installer/helpers").npm.builder({
  install_package = "elm-language-server",
  lang = "elmls",
  inherit_lspconfig = true,
  config = function(config)
    -- we don't install these globally, their location will be resolved automatically form node_modules
    config.default_config.init_options.elmPath = nil
    config.default_config.init_options.elmFormatPath = nil
    config.default_config.init_options.elmTestPath = nil

    return config

    -- elm, elm-test and elm-format are also installed so they can be used instead of the local versions
    -- in ./node_modules/.bin/ if needed. e.g. with
    -- ```
    -- init_options = {
    --  elmPath = require'installer/util'.install_path('elm') .. "/node_modules/.bin/elm"
    --  elmFormatPath = require'installer/util'.install_path('elm') .. "/node_modules/.bin/elm-format"
    --  elmTestPath = require'installer/util'.install_path('elm') .. "/node_modules/.bin/elm-test"
    -- }
    -- ```
  end,
})
