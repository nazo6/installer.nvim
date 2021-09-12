local cmd_win = "./server/bin/kotlin-language-server"
local script_win = [[
  if (Test-Path PowerShellEditorServices) {
    Remove-Item -Force -Recurse PowerShellEditorServices
  }
  $url = https://github.com/fwcd/kotlin-language-server/releases/latest/download/server.zip
  Invoke-WebRequest -UseBasicParsing $url -OutFile "ls.zip"
  Expand-Archive .\ls.zip -DestinationPath .\
  Remove-Item ls.zip
  ]]

local cmd = "./server/bin/kotlin-language-server"
local script = [[
  curl -fLO https://github.com/fwcd/kotlin-language-server/releases/latest/download/server.zip
  rm -rf server
  unzip server.zip
  rm server.zip
  chmod +x server/bin/kotlin-language-server
]]

return require("installer/integrations/ls/helpers").common.builder({
  lang = "kotlin_language_server",
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
