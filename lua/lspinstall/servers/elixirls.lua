local config = require("lspinstall/util").extract_config "elixirls"
local lsp_util = require "lspinstall/util"

local script_to_use = nil

if lsp_util.is_windows() then
  config.default_config.cmd = { "./elixir-ls/language_server.bat" }
  script_to_use = [[
    Invoke-WebRequest -UseBasicParsing "https://github.com/elixir-lsp/elixir-ls/releases/latest/download/elixir-ls.zip" -OutFile "elixir.zip"
    Expand-Archive .\elixir.zip -DestinationPath elixir-ls
    Remove-Item elixir.zip
  ]]
else
  config.default_config.cmd = { "./elixir-ls/language_server.sh" }
  script_to_use = [[
  curl -fLO https://github.com/elixir-lsp/elixir-ls/releases/latest/download/elixir-ls.zip
  rm -rf elixir-ls
  unzip elixir-ls.zip -d elixir-ls
  rm elixir-ls.zip
  chmod +x elixir-ls/language_server.sh
  ]]
end

return vim.tbl_extend("error", config, {
  install_script = script_to_use,
})
