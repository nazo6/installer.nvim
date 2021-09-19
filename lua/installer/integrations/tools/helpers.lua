local M = {}

local is_windows = require("installer/utils/os").is_windows
local resolve = require("installer/utils/fs").resolve

M.common = {
  --- Build config
  --- @alias os_type {win:string, other:string}
  --- @alias nullls_builder_option_type {name:string, install_script: os_type,cmd: os_type, null_ls_type: string[] }
  --- @param opts nullls_builder_option_type
  builder = function(opts)
    return {
      install_script = function()
        if is_windows then
          return opts.install_script.win
        else
          return opts.install_script.other
        end
      end,
      cmd = function()
        local server_path = require("installer/utils/fs").module_path("tools", opts.name)
        if is_windows then
          return resolve(server_path, opts.cmd.win)
        else
          return resolve(server_path, opts.cmd.other)
        end
      end,
    }
  end,
}

return M
