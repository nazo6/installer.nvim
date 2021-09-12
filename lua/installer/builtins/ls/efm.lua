local script_win = [[
    $json = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/mattn/efm-langserver/releases/latest
    $object = ConvertFrom-JSON $json
    $object.assets | ForEach-Object {
      if ($_.browser_download_url.Contains("windows")) {
        $url = $_.browser_download_url
      }
    }
    Invoke-WebRequest -UseBasicParsing $url -OutFile "efm.zip"
    Expand-Archive .\efm.zip -DestinationPath efm
    Get-ChildItem -R -Path .\efm -Include *.exe | Move-Item -Destination .\
    Remove-Item efm.zip
    Remove-Item -r -Force .\efm
  ]]

local script = [[
  GOPATH=$(pwd) GOBIN=$(pwd) GO111MODULE=on go get -v github.com/mattn/efm-langserver
  GOPATH=$(pwd) GO111MODULE=on go clean -modcache
  ]]

return require("installer/integrations/ls/helpers").common.builder({
  lang = "efm",
  inherit_lspconfig = true,
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = "./efm-langserver.exe",
    other = "./efm-langserver",
  },
})
