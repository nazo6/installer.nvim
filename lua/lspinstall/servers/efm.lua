local config = require("lspinstall/util").extract_config "efm"
local lsp_util = require "lspinstall/util"

local script_to_use = nil

if lsp_util.is_windows() then
  config.default_config.cmd[1] = "./efm-langserver.exe"
  script_to_use = [[
    $json = Invoke-WebRequest https://api.github.com/repos/mattn/efm-langserver/releases/latest
    $object = ConvertFrom-JSON $json
    $object.assets | ForEach-Object {
      if ($_.browser_download_url.Contains("windows")) {
        $url = $_.browser_download_url
      }
    }
    Invoke-WebRequest $url -OutFile "efm.zip"
    Expand-Archive .\efm.zip -DestinationPath efm
    Get-ChildItem -R -Path .\efm -Include *.exe | Move-Item -Destination .\
    Remove-Item efm.zip
    Remove-Item -r -Force .\efm
  ]]
else
  config.default_config.cmd[1] = "./efm-langserver"
  script_to_use = [[
  GOPATH=$(pwd) GOBIN=$(pwd) GO111MODULE=on go get -v github.com/mattn/efm-langserver
  GOPATH=$(pwd) GO111MODULE=on go clean -modcache
  ]]
end

return vim.tbl_extend("error", config, {
  install_script = script_to_use,
})
