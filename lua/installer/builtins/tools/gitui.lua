local builder = require("installer/integrations/tools/helpers").common.builder

local script_win = [[
  $json = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/extrawurst/gitui/releases/latest
  $object = ConvertFrom-JSON $json
  $object.assets | ForEach-Object {
    if ($_.browser_download_url.Contains("win")) {
      $url = $_.browser_download_url
    }
  }
  Invoke-WebRequest -UseBasicParsing $url -OutFile "a.zip"
  tar.exe -xf .\a.zip
  Remove-Item a.zip
]]

local script = [[
  os=$(uname -s | tr "[:upper:]" "[:lower:]")

  case $os in
  linux)
  platform="linux-musl"
  ;;
  darwin)
  platform="mac"
  ;;
  esac

  curl -L -o "gitui.tar.gz" $(curl -s https://api.github.com/repos/extrawurst/gitui/releases/latest | grep 'browser_' | cut -d\" -f4 | grep "$platform")
  tar -xf gitui.tar.gz
  rm gitui.tar.gz
]]

return builder({
  name = "gitui",
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = "gitui.exe",
    other = "gitui",
  },
})
