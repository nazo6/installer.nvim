local resolve = require("installer/utils/fs").resolve
local is_windows = require("installer/utils/os").is_windows

return {
  --- Install or update npm package
  install_script = function(package_name)
    if is_windows then
      return [[
        if (-not (Test-Path package.json)) {
          npm init -y --scope=installer
        }
        npm install ]] .. package_name .. [[@latest
      ]]
    else
      return [[npm init -y --scope=installer; npm install ]] .. package_name .. "@latest"
    end
  end,
  --- Add ".cmd" on windows
  bin_path = function(bin_name)
    local path = nil
    if is_windows then
      if string.sub(bin_name, -4) == ".cmd" then
        path = resolve("./node_modules/.bin", bin_name)
      else
        path = resolve("./node_modules/.bin", bin_name .. ".cmd")
      end
    else
      path = resolve("./node_modules/.bin", bin_name)
    end
    return path
  end,
}
