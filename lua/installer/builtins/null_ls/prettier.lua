local npm = require("installer/helpers/npm")

return {
  install_script = function()
    return npm.install_script("prettier")
  end,
  cmd = function()
    return npm.bin_path("prettier")
  end,
  null_ls_config = function()
    return {
      type = { "formatting" },
    }
  end,
}
