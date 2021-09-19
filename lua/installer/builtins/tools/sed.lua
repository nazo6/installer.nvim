local script_win = [[
  Invoke-WebRequest -o sed.exe https://github.com/mbuilov/sed-windows/raw/master/sed-4.8-x64.exe -UserAgent "NativeHost"
  Invoke-WebRequest -o dep.zip https://sourceforge.net/projects/gnuwin32/files/sed/4.2.1/sed-4.2.1-dep.zip/download -UserAgent "NativeHost"
  Expand-Archive dep.zip -DestinationPath ./sed
  Move-Item sed.exe ./sed/bin/
  Remove-Item dep.zip
]]
return {
  install_script = function()
    local is_windows = require("installer/utils/os").is_windows
    if is_windows then
      return script_win
    else
      return ""
    end
  end,
  cmd = function()
    local is_windows = require("installer/utils/os").is_windows
    local resolve = require("installer/utils/fs").resolve
    local server_path = require("installer/utils/fs").module_path("tools", "sed")

    if is_windows then
      return resolve(server_path, "sed/bin/sed.exe")
    else
      return "sed"
    end
  end,
}
