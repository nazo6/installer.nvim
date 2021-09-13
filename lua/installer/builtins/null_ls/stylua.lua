local is_windows = require("installer/utils/os").is_windows
local resolve = require("installer/utils/fs").resolve

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

return {
  install_script = function()
    if is_windows then
      return script_win
    else
      return script
    end
  end,
  cmd = function()
    local server_path = require("installer/utils/fs").module_path("null_ls", "stylua")
    if is_windows then
      return resolve(server_path, "stylua/stylua.exe")
    else
      return resolve(server_path, "stylua/stylua")
    end
  end,
  null_ls_config = function()
    return {
      type = { "formatting" },
    }
  end,
}
