local builder = require("installer/integrations/null_ls/helpers").npm.builder

return builder({
  install_package = "prettier",
  type = { "formatting", "code_actions", "diagnostics" },
})
