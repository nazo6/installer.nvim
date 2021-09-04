local cmd_win = "./gopls"
local script_win = [[
    $pwd = pwd
    $Env:GOPATH = pwd
    $Env:GOBIN = pwd
    $Env:GO111MODULE = on
    go get -v golang.org/x/tools/gopls
    go clean -modcache
  ]]
local cmd = "./gopls"
local script = [[
  GOPATH=$(pwd) GOBIN=$(pwd) GO111MODULE=on go get -v golang.org/x/tools/gopls
  GOPATH=$(pwd) GO111MODULE=on go clean -modcache
  ]]

return require("lspinstall/helpers").common.builder {
  lang = "gopls",
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
