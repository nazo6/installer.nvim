local cmd_win = "./venv/Scripts/fortls"
local script_win = [[
  python3 -m venv ./venv
  ./venv/Scripts/pip3 install -U pip
  ./venv/Scripts/pip3 install -U fortran-language-server
  ]]
local cmd = "./venv/bin/fortls"
local script = [[
  python3 -m venv ./venv
  ./venv/bin/pip3 install -U pip
  ./venv/bin/pip3 install -U fortran-language-server
  ]]

return require("installer/integrations/ls/helpers").common.builder({
  lang = "fortls",
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
