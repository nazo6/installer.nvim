local config = require("lspinstall/util").extract_config "clangd"
local lsp_util = require "lspinstall/util"

local script_to_use = nil

if lsp_util.is_windows() then
  config.default_config.cmd[1] = "./clangd/bin/clangd.exe"
  script_to_use = [[
    $json = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/clangd/clangd/releases/latest
    $object = ConvertFrom-JSON $json
    $object.assets | ForEach-Object {
      if ($_.browser_download_url.Contains("clangd-windows")) {
        $url = $_.browser_download_url
      }
    }
    Invoke-WebRequest -UseBasicParsing $url -OutFile "clangd.zip"
    Expand-Archive .\clangd.zip -DestinationPath clangd
    Get-ChildItem .\clangd | Move-Item -Destination .\
    rm clangd.zip
    rm -r -Force clangd
    Get-ChildItem . | Rename-Item -NewName { "clangd" }
  ]]
else
  config.default_config.cmd[1] = "./clangd/bin/clangd"
  script_to_use = [[
  os=$(uname -s | tr "[:upper:]" "[:lower:]")

  case $os in
  linux)
  platform="linux"
  ;;
  darwin)
  platform="mac"
  ;;
  esac

  curl -L -o "clangd.zip" $(curl -s https://api.github.com/repos/clangd/clangd/releases/latest | grep 'browser_' | cut -d\" -f4 | grep "clangd-$platform")
  rm -rf clangd
  unzip clangd.zip
  rm clangd.zip
  mv clangd_* clangd
  ]]
end

return vim.tbl_extend("error", config, {
  install_script = script_to_use,
})
