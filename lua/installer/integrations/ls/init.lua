local configs = require("lspconfig/configs")

local config = require("installer").config
local path = require("installer").module_path
local modules = require("installer/modules")
local installed = require("installer/status/installed")
local servers = {}

local M = {}

local setup_server = function(name, settings)
  local server_config = modules.get_module("ls", name).lsp_config()
  local lsp_config = vim.tbl_deep_extend("keep", server_config, {
    default_config = {
      cmd_cwd = path("ls", name),
    },
  })
  configs[name] = lsp_config
  require("lspconfig")[name].setup(settings or {})
end

--- Setup lsp
--- @param opts {configs: tbl<string, fun(config:any):any>, enable_install_hook: boolean}
function M.setup(opts)
  local lsp_user_configs = opts.configs or {}
  servers = installed.get_category_modules("ls")
  for name in pairs(servers) do
    if not configs[name] then
      setup_server(name, lsp_user_configs[name])
    end
  end

  if opts.enable_install_hook then
    local user_hook = config.post_install_hook
    config.post_install_hook = function(category, name)
      if category == "ls" then
        setup_server(name, lsp_user_configs[name])
        vim.cmd("bufdo e")
      end
      if user_hook then
        user_hook(category, name)
      end
    end
  end
end

return M
