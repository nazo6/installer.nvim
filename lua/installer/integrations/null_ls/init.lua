local config = require("installer/config")
local get_module = require("installer/status").get_module

local M = {}

M.setup = function(opts)
  local nullls = require("null-ls")

  local sources = require("installer/integrations/null_ls").get_all()
  local nullls_opts = opts.configs

  nullls.config(opts.configs)

  if opts.enable_install_hook then
    local user_hook = config.get().post_install_hook
    config.set_key("post_install_hook", function(category, name)
      if category == "null_ls" then
        nullls.config(opts.configs)
      end
      if user_hook then
        user_hook(category, name)
      end
    end)
  end
end

M.get_all = function()
  local res = {}
  local modules = require("installer/status/installed").get_modules()
  for module, _ in pairs(modules["null_ls"]) do
    local a = M.get(module)
    for _, value in ipairs(a) do
      table.insert(res, value)
    end
  end

  return res
end

M.get = function(name, opts)
  local config = get_module("null_ls", name)

  local options = opts or {}
  options.command = config.cmd()

  local res = {}

  local types = config.null_ls_config().type
  for index, type in ipairs(types) do
    res[index] = require("null-ls").builtins[type][name].with(options)
  end

  return res
end

return M
