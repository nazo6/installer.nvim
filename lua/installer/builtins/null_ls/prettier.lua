local builder = require("installer/integrations/null_ls/helpers").npm.builder

return builder({
  name = "prettier",
  install_package = "prettier",
  type = { "formatting" },
})
