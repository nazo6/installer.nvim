local builder = require("installer/integrations/null_ls/helpers").npm.builder

return builder({
  name = "prettierd",
  install_package = "@fsouza/prettierd",
  bin_name = "prettierd",
  type = { "formatting" },
})
