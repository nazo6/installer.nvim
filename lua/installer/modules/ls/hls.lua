local cmd_win = { "./hls" }
local cmd = { "./hls" }

local script_win = [[
    $json = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/haskell/haskell-language-server/releases/latest
    $object = ConvertFrom-JSON $json
    $object.assets | ForEach-Object {
      if ($_.browser_download_url.Contains("wrapper-Windows")) {
        $url = $_.browser_download_url
      }
    }
    Invoke-WebRequest -UseBasicParsing $url -OutFile "hls.zip"
    Expand-Archive .\hls.zip -DestinationPath .\
    Remove-Item hls.zip
    Write-Output "set PATH=%PATH%;$Pwd & $Pwd/haskell-language-server-wrapper --lsp" |
    Out-File -Encoding "Ascii" "hls.cmd"
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
  
    curl -L -o hls.tar.gz $(curl -s https://api.github.com/repos/haskell/haskell-language-server/releases/latest | grep 'browser_' | cut -d\" -f4 | grep "$platform" | grep '.tar.gz')
    tar -xzf hls.tar.gz
    rm -f hls.tar.gz
    chmod +x haskell-language-server-*
  
    echo "#!/usr/bin/env bash" > hls
    echo "PATH=\$PATH:$(pwd) $(pwd)/haskell-language-server-wrapper --lsp" >> hls
    chmod +x hls
  ]]

return require("installer/helpers").common.builder {
  lang = "hls",
  inherit_lspconfig = true,
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = cmd_win,
    other = cmd,
  },
}
