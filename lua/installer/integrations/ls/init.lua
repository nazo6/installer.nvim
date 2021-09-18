local lspconfig = require("lspconfig")
local lspconfigs = require("lspconfig/configs")

local config = require("installer/config")
local path = require("installer").module_path
local installed = require("installer/status/installed")
local get_module = require("installer/status").get_module
local log = require("installer/utils/log")

local servers = {}

local M = {}

M.setup_server = function(name, settings)
  local server_config = get_module("ls", name).lsp_config()
  local lsp_config = vim.tbl_deep_extend("keep", server_config, {
    default_config = {
      cmd_cwd = path("ls", name),
    },
  })
  if not lspconfigs[name] then
    lspconfigs[name] = lsp_config
  end

  lspconfig[name].setup(settings or {})
end

--- Setup lsp
--- @param opts {configs: tbl<string, fun(config:any):any>, enable_hook: boolean}
M.setup = function(opts)
  local lsp_user_configs = opts.configs or {}
  servers = installed.get_category_modules("ls")
  for name in pairs(servers) do
    M.setup_server(name, lsp_user_configs[name])
  end

  if opts.enable_hook then
    table.insert(config.get().hooks.install.post, function(category, name)
      if category == "ls" then
        M.setup_server(name, lsp_user_configs[name])
        -- pcall(vim.cmd, "bufdo e")
      end
    end)
  end
end

return M
