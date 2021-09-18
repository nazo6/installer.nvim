local builder = require("installer/integrations/tools/helpers").common.builder

local script_win = [[
  $json = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/BurntSushi/ripgrep/releases/latest
  $object = ConvertFrom-JSON $json
  $object.assets | ForEach-Object {
    if ($_.browser_download_url.Contains("x86_64-pc-windows-msvc")) {
      $url = $_.browser_download_url
    }
  }
  Invoke-WebRequest -UseBasicParsing $url -OutFile "rg.zip"
  Expand-Archive .\rg.zip -DestinationPath  ./
  Move-Item rip*/rg.exe rg.exe
  Remove-Item rg.zip
  Remove-Item -r -Force ./ripgrep*
]]

local script = [[
  os=$(uname -s | tr "[:upper:]" "[:lower:]")

  case $os in
  linux)
  platform="linux-musl"
  ;;
  darwin)
  platform="darwin"
  ;;
  esac

  curl -L -o "rg.tar.gz" $(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep 'browser_' | cut -d\" -f4 | grep "$platform")
  tar -xzf rg.tar.gz --strip-components 1
  rm rg.tar.gz
]]

return builder({
  name = "ripgrep",
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = "rg.exe",
    other = "rg",
  },
})
