local cmd_win = "./texlab"
local script_win = [[
    $object = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/latex-lsp/texlab/releases/latest | ConvertFrom-JSON 
    $object.assets | ForEach-Object {
      if ($_.browser_download_url.Contains("windows")) {
        $url = $_.browser_download_url
      }
    }
    Invoke-WebRequest -UseBasicParsing $url -OutFile "latex.zip"
    Expand-Archive .\latex.zip -DestinationPath .\
    Remove-Item latex.zip
  ]]
local cmd = "./texlab"
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
  
    curl -L -o texlab.tar.gz $(curl -s https://api.github.com/repos/latex-lsp/texlab/releases/latest | grep 'browser_' | cut -d\" -f4 | grep "$platform")
    tar -xzf texlab.tar.gz
    rm texlab.tar.gz
    ]]

return require("installer/integrations/ls/helpers").common.builder({
  lang = "texlab",
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
