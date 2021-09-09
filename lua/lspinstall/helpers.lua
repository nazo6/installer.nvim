local M = {}
M.npm = {
  --- Install or update npm package
  install_script = function(package_name)
    local util = require "lspinstall/util"
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
    local util = require "lspinstall/util"
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
  --- @alias npm_option_type {install_package: string, bin_name:string, lang:string, inherit_lspconfig:boolean, config:table|function }
  --- @param options npm_option_type
  builder = function(options)
    return {
      install_script = function()
        return M.npm.install_script(options.install_package)
      end,
      lsp_config = function()
        local util = require "lspinstall/util"
        local config = {}
        if type(options.config) == "table" then
          config = options.config
        end
        if options.inherit_lspconfig ~= false then
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

M.pip = {
  install_script = function(package_to_install)
    local util = require "lspinstall/util"
    local python_to_use = ""
    if vim.fn.executable("python3") == 1 then
      python_to_use = "python3"
    else
      python_to_use = "python"
    end
    local is_python3 = false


    local version_line =
      io.popen(python_to_use..' -c "import sys; print(sys.version_info.major)"'):read("l")
    if version_line == "3" then
      is_python3 = true
    end

    if is_python3 == false then
      util.print_warning("Sorry couldn't find valid python of version 3")
      return 'echo "Couldn\'t find python 3"'
    end

    if util.is_windows() then
      return python_to_use .. [[ -m venv ./venv
      ./venv/Scripts/pip3 install -U pip
      ./venv/Scripts/pip3 install -U ]]..package_to_install
    else
      return python_to_use .. [[ -m venv ./venv
      ./venv/bin/pip3 install -U pip
      ./venv/bin/pip3 install -U ]]..package_to_install
    end
  end,
  builder = function(options)
    return {
      install_script = function()
        return M.pip.install_script(options.install_package)
      end,
      lsp_config = function()
        local util = require "lspinstall/util"
        local config = {}
        if type(options.config) == "table" then
          config = options.config
        end
        if options.inherit_lspconfig ~= false then
          config = util.extract_config(options.lang)
        end

        if options.bin_name == nil then
          options.bin_name = config.default_config.cmd[1]
        end
        local server_path = util.install_path(options.lang)
        --config.default_config.cmd[1] = server_path .. "/" .. M.npm.bin_path(options.bin_name)

        if type(options.config) == "function" then
          config = options.config(config)
        end

        return config
      end
    }
  end
}

M.common = {
  --- Build config
  --- @alias script_type {win:string, other:string}
  --- @alias option_type {install_script: script_type,cmd: script_type, lang:string, inherit_lspconfig:boolean, config:table|function}
  --- @param options option_type
  builder = function(options)
    return {
      install_script = function()
        local util = require "lspinstall/util"
        if util.is_windows() then
          return options.install_script.win
        else
          return options.install_script.other
        end
      end,
      lsp_config = function()
        local util = require "lspinstall/util"
        local config = {}

        if type(options.config) == "table" then
          config = options.config
        end
        if options.inherit_lspconfig ~= false then
          config = util.extract_config(options.lang)
        end

        if options.cmd ~= nil then
          local cmd
          if util.is_windows() then
            cmd = options.cmd.win
          else
            cmd = options.cmd.other
          end
          if type(cmd) == "table" then
            cmd[1] = util.absolute_path(options.lang, cmd[1])
            config.default_config.cmd = cmd
          else
            if config.default_config.cmd == nil then
              config.default_config.cmd = {}
            end
            config.default_config.cmd[1] = util.absolute_path(options.lang, cmd)
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
