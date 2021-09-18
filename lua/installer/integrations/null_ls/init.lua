local log = require("installer/utils/log")
local get_module = require("installer/status").get_module

local M = {}

M.setup = function(opts)
  local nullls = require("null-ls")

  local sources = require("installer/integrations/null_ls").get_all()
  local nullls_opts = opts.configs or {}
  if not nullls_opts.sources then
    nullls_opts.sources = {}
  end

  for _, source in ipairs(sources) do
    table.insert(nullls_opts.sources, source)
  end

  nullls.config(nullls_opts)

  if opts.enable_hook then
    table.insert(require("installer/config").get().hooks.install.post, function(category, name)
      if category == "null_ls" then
        local a = M.get(name)
        for _, value in ipairs(a) do
          if nullls.is_registered(name) then
            log.debug_log("[integ/null_ls/hook]", name .. " is already registered.")
            return
          end
          nullls.register(value)

          log.debug_log("[integ/null_ls/hook]", "Registerd " .. name, "\n")
        end
        -- pcall(vim.cmd, "bufdo e")
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
