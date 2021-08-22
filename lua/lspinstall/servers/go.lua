local config = require("lspinstall/util").extract_config "gopls"
local lsp_util = require "lspinstall/util"

local script_to_use = nil

if lsp_util.is_windows() then
  config.default_config.cmd[1] = "./gopls"
  script_to_use = [[
    $pwd = pwd
    $Env:GOPATH = pwd
    $Env:GOBIN = pwd
    $Env:GO111MODULE = on
    go get -v golang.org/x/tools/gopls
    go clean -modcache
  ]]
else
  config.default_config.cmd[1] = "./gopls"
  script_to_use = [[
  GOPATH=$(pwd) GOBIN=$(pwd) GO111MODULE=on go get -v golang.org/x/tools/gopls
  GOPATH=$(pwd) GO111MODULE=on go clean -modcache
  ]]
end

return vim.tbl_extend("error", config, {
  install_script = script_to_use,
})
