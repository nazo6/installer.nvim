local script_win = [[
$object = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/clojure-lsp/clojure-lsp/releases/latest | ConvertFrom-JSON 
$object.assets | ForEach-Object {
  if ($_.browser_download_url.Contains("windows")) {
    $url = $_.browser_download_url
  }
}
Invoke-WebRequest -UseBasicParsing $url -OutFile "clojure.zip"
Expand-Archive .\clojure.zip -DestinationPath .\
Remove-Item clojure.zip
]]

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

curl -L -o "clojure-lsp.zip" $(curl -s https://api.github.com/repos/clojure-lsp/clojure-lsp/releases/latest | grep 'browser_' | cut -d\" -f4 | grep "clojure-lsp-native-${platform}-amd64.zip")
unzip -o clojure-lsp.zip
rm clojure-lsp.zip
chmod +x clojure-lsp
]]

return require("installer/helpers").common.builder {
  lang = "clojure_lsp",
  inherit_lspconfig = true,
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = "./clojure-lsp.exe",
    other = "./clojure-lsp",
  },
}
