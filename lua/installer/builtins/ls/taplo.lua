local cmd_win = "./taplo-lsp.exe"
local script_win = [[
  Invoke-WebRequest -UseBasicParsing "https://github.com/tamasfe/taplo/releases/latest/download/taplo-lsp-windows-x86_64.zip" -OutFile "taplo.zip"
  Expand-Archive .\taplo.zip -DestinationPath .\
  Remove-Item taplo.zip
]]
local cmd = "./taplo-lsp"
local script = [[
  os=$(uname -s | tr "[:upper:]" "[:lower:]")
  arch=$(uname -m | tr "[:upper:]" "[:lower:]")

  case $os in
  darwin)
  platform="x86_64-apple-darwin-gnu"
  ;;
  linux)
  platform="x86_64-unknown-linux-gnu"
  ;;
  esac

  curl -L -o taplo.tar.gz $(curl -s https://api.github.com/repos/tamasfe/taplo/releases/latest | grep 'browser_' | cut -d\" -f4 | grep "$platform")
  tar -xzf taplo.tar.gz
  rm taplo.tar.gz
  ]]

return require("installer/integrations/ls/helpers").common.builder({
  lang = "taplo",
  inherit_lspconfig = true,
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = cmd_win,
    other = cmd,
  },
})
