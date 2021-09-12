local cmd_win = { "./elixir-ls/language_server.bat" }
local script_win = [[
    Invoke-WebRequest -UseBasicParsing "https://github.com/elixir-lsp/elixir-ls/releases/latest/download/elixir-ls.zip" -OutFile "elixir.zip"
    Expand-Archive .\elixir.zip -DestinationPath elixir-ls
    Remove-Item elixir.zip
  ]]
local cmd = { "./elixir-ls/language_server.sh" }
local script = [[
  curl -fLO https://github.com/elixir-lsp/elixir-ls/releases/latest/download/elixir-ls.zip
  rm -rf elixir-ls
  unzip elixir-ls.zip -d elixir-ls
  rm elixir-ls.zip
  chmod +x elixir-ls/language_server.sh
  ]]

return require("installer/helpers").common.builder({
  lang = "elixirls",
  inherit_lspconfig = true,
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = cmd_win,
    other = cmd,
  },
})
