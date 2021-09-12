return {
  install_script = function()
    local npm = require("installer/helpers").npm
    return npm.install_script("@angular/language-server")
      .. [[
    ]]
      .. npm.install_script("@angular/language-service")
  end,
  lsp_config = function()
    local npm = require("installer/helpers").npm
    local util = require("installer/util")
    local config = require("installer/util").extract_config("angularls")

    local cmd_name = config.default_config.cmd[1]
    local node_module_path = util.install_path("angularls") .. "/node_modules/"

    local prefix = ""
    if util.is_windows() then
      prefix = ".cmd"
    end

    config.default_config.cmd[1] = npm.bin_path(cmd_name)
    config.default_config.cmd[6] = node_module_path

    return vim.tbl_extend("force", config, {
      on_new_config = function(new_config)
        new_config.cmd[1] = node_module_path .. ".bin/" .. cmd_name .. prefix
        new_config.cmd[6] = node_module_path
      end,
    })
  end,
}
