local get_module = require("installer/status").get_module

local M = {}

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
