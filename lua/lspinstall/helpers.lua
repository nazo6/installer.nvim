local util = require ("lspinstall/util")
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
      return [[
      if \[\[ -f package.json \]\]; then
        npm init -y --scope=lspinstall
        npm install ]] .. package_name .. [[
      else
        npm update ]] .. package_name .. [[
      fi
    ]]
    end
  end,
  --- Add ".cmd" on windows
  bin_path = function(bin_name)
    if util.is_windows() then
      return "./node_modules/.bin/" .. bin_name .. ".cmd"
    else
      return "./node_modules/.bin/" .. bin_name
    end
  end,
}

return M
