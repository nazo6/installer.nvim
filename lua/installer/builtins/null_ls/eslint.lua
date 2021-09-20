local builder = require("installer/integrations/null_ls/helpers").npm.builder

return builder({
  name = "eslint",
  install_package = "eslint",
  type = { "formatting", "diagnostics" },
})
