local script_win = [[
  $url = "https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip"
  Invoke-WebRequest -UseBasicParsing $url -OutFile "deno.zip"
  Expand-Archive .\deno.zip -DestinationPath .\
  Remove-Item deno.zip
]]
local script = [[
  case $(uname -sm) in
  "Darwin x86_64") target="x86_64-apple-darwin" ;;
  "Darwin arm64") target="aarch64-apple-darwin" ;;
  *) target="x86_64-unknown-linux-gnu" ;;
  esac

  curl --fail --location --progress-bar --output "deno.zip" "https://github.com/denoland/deno/releases/latest/download/deno-${target}.zip"
  unzip deno.zip
  rm "deno.zip"
]]

return require("installer/integrations/ls/helpers").common.builder({
  lang = "denols",
  inherit_lspconfig = true,
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = "deno.exe",
    other = "deno",
  },
})
