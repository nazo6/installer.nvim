local M = {}

--- @type table<module_category, module_category_content>
M._user_modules = {}

--- Register user-defined module.
--- @param category module_category
--- @param name module_name
--- @param module module
M.register = function(category, name, module)
  if M._user_modules[category] == nil then
    M._user_modules[category] = {}
  end
  M._user_modules[category][name] = module
end

--- Get module. Modules registered by the user will take precedence
--- @param category module_category
--- @param name module_name
M.get_module = function(category, name)
  local data
  if M._user_modules[category] then
    data = M._user_modules[category][name]
  end
  if data == nil then
    data = require("installer/builtins/" .. category .. "/" .. name)
  end
  return data
end

return M
