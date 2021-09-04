return {
  install_script = function()
    local lsp_util = require "lspinstall/util"

    if lsp_util.is_windows() then
      return [[
        $json = Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/sumneko/vscode-lua/releases/latest
        $object = ConvertFrom-JSON $json
        $url = $object.assets[0].browser_download_url
        Invoke-WebRequest -UseBasicParsing $url -OutFile "sumneko-lua.zip"
        Expand-Archive .\sumneko-lua.zip -DestinationPath sumneko-lua
        rm sumneko-lua.zip
        Write-Output "sumneko-lua\extension\server\bin\Windows\lua-language-server -E -e LANG=en sumneko-lua\extension\server\main.lua" |
        Out-File -Encoding "Ascii" "sumneko-lua-language-server.cmd"
      ]]
    else
      return [[
        os=$(uname -s | tr "[:upper:]" "[:lower:]")

        case $os in
        linux)
        platform="Linux"
        ;;
        darwin)
        platform="macOS"
        ;;
        esac

        curl -L -o sumneko-lua.vsix $(curl -s https://api.github.com/repos/sumneko/vscode-lua/releases/latest | grep 'browser_' | cut -d\" -f4)
        rm -rf sumneko-lua
        unzip sumneko-lua.vsix -d sumneko-lua
        rm sumneko-lua.vsix

        chmod +x sumneko-lua/extension/server/bin/$platform/lua-language-server

        echo "#!/usr/bin/env bash" > sumneko-lua-language-server
        echo "\$(dirname \$0)/sumneko-lua/extension/server/bin/$platform/lua-language-server -E -e LANG=en \$(dirname \$0)/sumneko-lua/extension/server/main.lua \$*" >> sumneko-lua-language-server

        chmod +x sumneko-lua-language-server
    ]]
    end
  end,
  lsp_config = function()
    local lsp_util = require "lspinstall/util"
    local config = require("lspinstall/util").extract_config "sumneko_lua"

    if lsp_util.is_windows() then
      config.default_config.cmd = { lsp_util.absolute_path("sumneko_lua", "./sumneko-lua-language-server.cmd") }
    else
      config.default_config.cmd = { lsp_util.absolute_path("sumneko_lua", "./sumneko-lua-language-server") }
    end
    return config
  end,
}
