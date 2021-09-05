local cmd_win = "./solargraph/solargraph"
local script_win = [[
    $json = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/castwide/solargraph/tags
    $object = ConvertFrom-JSON $json
    $url = $object[1].zipball_url
    Invoke-WebRequest -UseBasicParsing $url -OutFile "solargraph.zip"
    Expand-Archive .\solargraph.zip -DestinationPath .\solargraph
    Remove-Item solargraph.zip
    
    cd solargraph
    bundle install --without development --path vendor/bundle

    Write-Output "bundle exec solargprah" |
    Out-File -Encoding "Ascii" "solargraph.cmd"
  ]]
local cmd = "./solargraph/solargraph"
local script = [[
    curl -L -o solargraph.tar $(curl -s https://api.github.com/repos/castwide/solargraph/tags | grep 'tarball_url' | cut -d\" -f4 | head -n1)
    rm -rf solargraph
    mkdir solargraph
    tar -xzf solargraph.tar -C solargraph --strip-components 1
    rm solargraph.tar
    cd solargraph
  
    bundle install --without development --path vendor/bundle
  
    echo '#!/usr/bin/env bash' > solargraph
    echo 'cd "$(dirname "$0")" || exit' >> solargraph
    echo 'bundle exec solargraph $*' >> solargraph
  
    chmod +x solargraph
  ]]

return require("lspinstall/helpers").common.builder {
  lang = "solargraph",
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
