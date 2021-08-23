local config = require("lspinstall/util").extract_config "hls"
local lsp_util = require "lspinstall/util"
config.default_config.cmd = { "./hls" }

local install_script = nil

if lsp_util.is_windows() then
  install_script = [[
    $json = Invoke-WebRequest https://api.github.com/repos/haskell/haskell-language-server/releases/latest
    $object = ConvertFrom-JSON $json
    $object.assets | ForEach-Object {
      if ($_.browser_download_url.Contains("wrapper-Windows")) {
        $url = $_.browser_download_url
      }
    }
    Invoke-WebRequest $url -OutFile "hls.zip"
    Expand-Archive .\hls.zip -DestinationPath .\
    Remove-Item hls.zip
    Write-Output "set PATH=%PATH%;$Pwd & $Pwd/haskell-language-server-wrapper --lsp" |
    Out-File -Encoding "UTF8" "hls.cmd"
  ]]
else
  install_script = [[
    os=$(uname -s | tr "[:upper:]" "[:lower:]")
  
    case $os in
    linux)
    platform="Linux"
    ;;
    darwin)
    platform="macOS"
    ;;
    esac
  
    curl -L -o hls.tar.gz $(curl -s https://api.github.com/repos/haskell/haskell-language-server/releases/latest | grep 'browser_' | cut -d\" -f4 | grep "$platform" | grep '.tar.gz')
    tar -xzf hls.tar.gz
    rm -f hls.tar.gz
    chmod +x haskell-language-server-*
  
    echo "#!/usr/bin/env bash" > hls
    echo "PATH=\$PATH:$(pwd) $(pwd)/haskell-language-server-wrapper --lsp" >> hls
    chmod +x hls
  ]]
end

return vim.tbl_extend("error", config, {
  install_script = install_script,
})
