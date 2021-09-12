local helpers = require("installer/helpers")
local is_windows = require("installer/utils/os").is_windows
local extract_config = require("installer/integrations/ls/utils").extract_config
local module_path = require("installer/utils/fs").module_path
local resolve = require("installer/utils/fs").resolve

local M = {}

M.npm = {
  --- Build npm module settings
  --- @alias npm_option_type {install_package: string, bin_name:string, lang:string, inherit_lspconfig:boolean, config:table|function }
  --- @param options npm_option_type
  builder = function(options)
    return {
      install_script = function()
        return helpers.npm.install_script(options.install_package)
      end,
      lsp_config = function()
        local config = {}
        if type(options.config) == "table" then
          config = options.config
        end
        if options.inherit_lspconfig ~= false then
          config = extract_config(options.lang)
        end

        if options.bin_name == nil then
          options.bin_name = config.default_config.cmd[1]
        end
        local server_path = require("installer/utils/fs").module_path("ls", options.lang)
        config.default_config.cmd[1] = resolve(server_path, helpers.npm.bin_path(options.bin_name))

        if type(options.config) == "function" then
          config = options.config(config)
        end

        return config
      end,
    }
  end,
}

M.pip = {
  builder = function(options)
    return {
      install_script = function()
        return helpers.pip.install_script(options.install_package)
      end,
      lsp_config = function()
        local config = {}
        if type(options.config) == "table" then
          config = options.config
        end
        if options.inherit_lspconfig ~= false then
          config = extract_config(options.lang)
        end

        if options.bin_name == nil then
          options.bin_name = config.default_config.cmd[1]
        end
        local server_path = require("installer/utils/fs").module_path("ls", options.lang)
        config.default_config.cmd[1] = resolve(server_path, helpers.pip.bin_path(options.bin_name))

        if type(options.config) == "function" then
          config = options.config(config)
        end

        return config
      end,
    }
  end,
}

M.common = {
  --- Build config
  --- @alias script_type {win:string, other:string}
  --- @alias option_type {install_script: script_type,cmd: script_type, lang:string, inherit_lspconfig:boolean, config:table|function}
  --- @param options option_type
  builder = function(options)
    return {
      install_script = function()
        if is_windows then
          return options.install_script.win
        else
          return options.install_script.other
        end
      end,
      lsp_config = function()
        local config = {}

        if type(options.config) == "table" then
          config = options.config
        end
        if options.inherit_lspconfig ~= false then
          config = extract_config(options.lang)
        end

        if options.cmd ~= nil then
          local cmd
          if is_windows then
            cmd = options.cmd.win
          else
            cmd = options.cmd.other
          end
          if type(cmd) == "table" then
            cmd[1] = resolve(module_path("ls", options.lang), cmd[1])
            config.default_config.cmd = cmd
          else
            if config.default_config.cmd == nil then
              config.default_config.cmd = {}
            end
            config.default_config.cmd[1] = resolve(module_path("ls", options.lang), cmd)
          end
        end

        if type(options.config) == "function" then
          config = options.config(config)
        end
        return config
      end,
    }
  end,
}

return M
