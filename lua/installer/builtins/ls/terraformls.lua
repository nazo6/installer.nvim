local script_win = [[
    $json = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/hashicorp/terraform-ls/releases/latest
    $object = ConvertFrom-JSON $json
    $object.assets | ForEach-Object {
      if ($_.browser_download_url.Contains("windows_amd64")) {
        $url = $_.browser_download_url
      }
    }
    Invoke-WebRequest -UseBasicParsing $url -OutFile "ls.zip"
    Expand-Archive .\ls.zip -DestinationPath ./
    Remove-Item ls.zip
]]

local script = [[
  os=$(uname -s | tr "[:upper:]" "[:lower:]")
  arch=$(uname -m | tr "[:upper:]" "[:lower:]")

  case $os in
  linux)
  platform="linux"
  ;;
  darwin)
  platform="darwin"
  ;;
  esac

  case $arch in 
  i386)
  architecture=386
  ;;
  i586)
  architecture=386
  ;;
  i686)
  architecture=386
  ;;
  x86_64)
  architecture=amd64
  ;;
  arm64)
  architecture=arm64
  ;;
  aarch64)
  architecture=arm64
  ;;
  esac

  DOWNLOAD_URL=$(curl -s https://api.github.com/repos/hashicorp/terraform-ls/releases/latest | grep 'browser_' | cut -d\" -f4 | grep "$platform" | grep "$architecture")
  curl -L -o terraform.zip "$DOWNLOAD_URL"
  rm -f terraform-ls
  unzip terraform.zip
  rm terraform.zip
]]

return require("installer/integrations/ls/helpers").common.builder({
  lang = "terraformls",
  inherit_lspconfig = true,
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = "./terraform-ls.exe",
    other = "./terraform-ls",
  },
})
