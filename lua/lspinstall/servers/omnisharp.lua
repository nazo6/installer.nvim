local cmd_win = {
  "./omnisharp/OmniSharp.exe",
  "--languageserver",
  "--hostPID",
  tostring(vim.fn.getpid()),
}
local script_win = [[
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

local cmd = { "./omnisharp/run", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) }
local script = [[
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

return require("lspinstall/helpers").common.builder {
  lang = "omnisharp",
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
