local configs = require("lspconfig/configs")

local config = require("installer/config")
local path = require("installer").module_path
local installed = require("installer/status/installed")
local get_module = require("installer/status").get_module

local servers = {}

local M = {}

M.setup_server = function(name, settings)
  local server_config = get_module("ls", name).lsp_config()
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
M.setup = function(opts)
  local lsp_user_configs = opts.configs or {}
  servers = installed.get_category_modules("ls")
  for name in pairs(servers) do
    if not configs[name] then
      M.setup_server(name, lsp_user_configs[name])
    end
  end

  if opts.enable_install_hook then
    local user_hook = config.get().post_install_hook
    config.set_key("post_install_hook", function(category, name)
      if category == "ls" then
        M.setup_server(name, lsp_user_configs[name])
        vim.cmd("bufdo e")
      end
      if user_hook then
        user_hook(category, name)
      end
    end)
  end
end

return M
