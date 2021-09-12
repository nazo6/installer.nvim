local script_win = [[
  $json = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/sumneko/vscode-lua/releases/latest
  $object = ConvertFrom-JSON $json
  $url = $object.assets[0].browser_download_url
  Invoke-WebRequest -UseBasicParsing $url -OutFile "sumneko-lua.zip"
  Expand-Archive .\sumneko-lua.zip -DestinationPath sumneko-lua
  rm sumneko-lua.zip
  Write-Output "sumneko-lua\extension\server\bin\Windows\lua-language-server -E -e LANG=en sumneko-lua\extension\server\main.lua" |
  Out-File -Encoding "Ascii" "sumneko-lua-language-server.cmd"
]]

local script = [[
  os=$(uname -s | tr "[:upper:]" "[:lower:]")

  case $os in
  linux)
  platform="Linux"
  ;;
  darwin)
  platform="macOS"
  ;;
  esac

  curl -L -o sumneko-lua.vsix $(curl -s https://api.github.com/repos/sumneko/vscode-lua/releases/latest | grep 'browser_' | cut -d\" -f4)
  rm -rf sumneko-lua
  unzip sumneko-lua.vsix -d sumneko-lua
  rm sumneko-lua.vsix

  chmod +x sumneko-lua/extension/server/bin/$platform/lua-language-server

  echo "#!/usr/bin/env bash" > sumneko-lua-language-server
  echo "\$(dirname \$0)/sumneko-lua/extension/server/bin/$platform/lua-language-server -E -e LANG=en \$(dirname \$0)/sumneko-lua/extension/server/main.lua \$*" >> sumneko-lua-language-server

  chmod +x sumneko-lua-language-server
]]

return require("installer/integrations/ls/helpers").common.builder({
  lang = "sumneko_lua",
  inherit_lspconfig = true,
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = "./sumneko-lua-language-server.cmd",
    other = "./sumneko-lua-language-server",
  },
})
