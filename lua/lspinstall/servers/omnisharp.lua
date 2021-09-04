local config = require("lspinstall/util").extract_config "omnisharp"
local lsp_util = require "lspinstall/util"

local script_to_use = nil

if lsp_util.is_windows() then
  config.default_config.cmd = {
    "./omnisharp/OmniSharp.exe",
    "--languageserver",
    "--hostPID",
    tostring(vim.fn.getpid()),
  }
  script_to_use = [[
  $object = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/OmniSharp/omnisharp-roslyn/releases/latest | ConvertFrom-JSON 
  $object.assets | ForEach-Object {
    if ($_.browser_download_url.Contains("omnisharp-win-x64")) {
      $url = $_.browser_download_url
    }
  }
  Invoke-WebRequest -UseBasicParsing $url -OutFile "omnisharp.zip"
  Expand-Archive .\omnisharp.zip -DestinationPath .\omnisharp
  Remove-Item omnisharp.zip
  ]]
else
  config.default_config.cmd = { "./omnisharp/run", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) }
  script_to_use = [[
  os=$(uname -s | tr "[:upper:]" "[:lower:]")

  case $os in
  linux)
  platform="linux-x64"
  ;;
  darwin)
  platform="osx"
  ;;
  esac

  curl -L -o "omnisharp.zip" $(curl -s https://api.github.com/repos/OmniSharp/omnisharp-roslyn/releases/latest | grep 'browser_' | cut -d\" -f4 | grep "omnisharp-$platform.zip")
  rm -rf omnisharp
  unzip omnisharp.zip -d omnisharp
  rm omnisharp.zip
  chmod +x omnisharp/run
  ]]
end

return vim.tbl_extend("error", config, {
  install_script = script_to_use,
})
