local util = require "lspinstall/util"
local M = {}
M.npm = {
  --- Install or update npm package
  install_script = function(package_name)
    if util.is_windows() then
      return [[
        if (-not (Test-Path package.json)) {
          npm init -y --scope=lspinstall
        }
        npm install ]] .. package_name .. [[@latest
      ]]
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
  --- Build npm module settings
  --- @alias option_type {install_package: string, bin_name:string, lang:string, inherit_lspconfig:boolean, config:table|function }
  --- @param options option_type
  builder = function(options)
    return {
      install_script = function()
        return M.npm.install_script(options.install_package)
      end,
      lsp_config = function()
        local config = {}
        if type(options.config) == "table" then
          config = options.config
        end
        if options.inherit_lspconfig then
          config = util.extract_config(options.lang)
        end

        if options.bin_name == nil then
          options.bin_name = config.default_config.cmd[1]
        end
        local server_path = util.install_path(options.lang)
        config.default_config.cmd[1] = server_path .. "/" .. M.npm.bin_path(options.bin_name)

        if type(options.config) == "function" then
          config = options.config(config)
        end

        return config
      end,
    }
  end,
}

return M
