local util = require "lspinstall/util"
local M = {}
M.npm = {
  --- Install or update npm package
  install_script = function(package_name)
    if util.is_windows() then
      return util.concat {
        [[if not exist package.json]],
        [[npm init -y --scope=lspinstall]],
        [[&& npm install ]] .. package_name,
        [[else]],
        [[npm update ]] .. package_name,
      }
    else
      return util.concat {
        [[npm init -y --scope=lspinstall]],
        ";npm install " .. package_name .. "@latest",
      }
    end
  end,
  --- Add ".cmd" on windows
  bin_path = function(bin_name)
    local path = nil
    if util.is_windows() then
      if string.sub(bin_name, -4) == ".cmd" then
        path = "./node_modules/.bin/" .. bin_name
      else
        path = "./node_modules/.bin/" .. bin_name .. ".cmd"
      end
    else
      path = "./node_modules/.bin/" .. bin_name
    end
    return path
  end,
}

return M
