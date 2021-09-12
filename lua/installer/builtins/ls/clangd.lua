return {
  install_script = function()
    if require("installer/utils/os").is_windows then
      return [[
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
      return [[
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
  end,
  lsp_config = function()
    local config = require("installer/integrations/ls/utils").extract_config("clangd")
    local module_path = require("installer/utils/fs").module_path

    if require("installer/utils/os").is_windows then
      config.default_config.cmd[1] = module_path(clang) .. "./clangd/bin/clangd.exe"
    else
      config.default_config.cmd[1] = module_path(clang) .. "./clangd/bin/clangd"
    end

    return config
  end,
}
