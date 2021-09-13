local user_modules = require("installer/config").get().custom_modules

local M = {}

--- Get module. Modules registered by the user will take precedence
--- @param category module_category
--- @param name module_name
M.get_module = function(category, name)
  local data
  local success
  if user_modules[category] then
    data = user_modules[category][name]
  end
  if data == nil then
    success, data = pcall(require, "installer/builtins/" .. category .. "/" .. name)
  end
  if success then
    return data
  else
    return false, data
  end
end

return M
