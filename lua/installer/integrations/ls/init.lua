local configs = require("lspconfig/configs")

local path = require("installer").module_path
local ensure_setup = require("installer/config").ensure_setup
local modules = require("installer/modules")
local installed = require("installer/status/installed")
local servers = {}

local M = {}

--- Setup lsp
--- @param opts {configs: tbl<string, fun(config:any):any>}
function M.setup(opts)
  ensure_setup()
  local lsp_user_configs = opts.configs or {}
  servers = installed.get_category_modules("ls")
  for name in pairs(servers) do
    if not configs[name] then
      local server_config = modules.get_module("ls", name).lsp_config()
      local config = vim.tbl_deep_extend("keep", server_config, {
        default_config = {
          cmd_cwd = path("ls", name),
        },
      })
      configs[name] = config
      require("lspconfig")[name].setup(lsp_user_configs[name] or {})
    end
  end
end

return M
