local config = require("lspinstall/util").extract_config "solargraph"
local lsp_util = require "lspinstall/util"

local script_to_use = nil

if lsp_util.is_windows() then
  config.default_config.cmd[1] = "./solargraph/solargraph"
  script_to_use = [[
    $json = Invoke-WebRequest https://api.github.com/repos/castwide/solargraph/tags
    $object = ConvertFrom-JSON $json
    $url = $object[1].zipball_url
    Invoke-WebRequest $url -OutFile "solargraph.zip"
    Expand-Archive .\solargraph.zip -DestinationPath .\solargraph
    Remove-Item solargraph.zip
    
    cd solargraph
    bundle install --without development --path vendor/bundle

    Write-Output "bundle exec solargprah" |
    Out-File -Encoding "UTF8" "solargraph.cmd"
  ]]
else
  config.default_config.cmd[1] = "./solargraph/solargraph"
  script_to_use = [[
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
end

return vim.tbl_extend("error", config, {
  -- adjusted from https://github.com/mattn/vim-lsp-settings/blob/master/installer/install-solargraph.sh
  install_script = script_to_use,
})
