local builder = require("installer/integrations/null_ls/helpers").common.builder

local script_win = [[
  $json = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest
  $object = ConvertFrom-JSON $json
  $object.assets | ForEach-Object {
    if ($_.browser_download_url.Contains("win64")) {
      $url = $_.browser_download_url
    }
  }
  Invoke-WebRequest -UseBasicParsing $url -OutFile "stylua.zip"
  Expand-Archive .\stylua.zip -DestinationPath stylua
  rm stylua.zip
]]

local script = [[
  os=$(uname -s | tr "[:upper:]" "[:lower:]")

  case $os in
  linux)
  platform="linux"
  ;;
  darwin)
  platform="macos"
  ;;
  esac

  curl -L -o "stylua.zip" $(curl -s https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest | grep 'browser_' | cut -d\" -f4 | grep "$platform")
  rm -rf clangd
  unzip stylua.zip -d stylua
  chmod +x stylua/stylua
  rm stylua.zip
]]

return builder({
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = "stylua/stylua.exe",
    other = "stylua/stylua",
  },
  null_ls_type = { "formatting" },
  name = "stylua",
})
