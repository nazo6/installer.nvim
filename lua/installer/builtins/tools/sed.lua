local script_win = [[
  Invoke-WebRequest -o a.zip https://sourceforge.net/projects/gnuwin32/files/sed/4.2.1/sed-4.2.1-bin.zip/download -UserAgent "NativeHost"
  Expand-Archive a.zip -DestinationPath ./sed
  Move-Item ./sed/bin/sed.exe ./sed.exe
  Remove-Item -r -Force ./sed
  Remove-Item a.zip
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
      return resolve(server_path, "sed.exe")
    else
      return "sed"
    end
  end,
}
