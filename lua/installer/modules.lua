local M = {}

--- @type table<module_category, module_category_content>
local user_modules = {}

--- Register user-defined installer.
--- @param category module_category
--- @param name module_name
--- @param module module
M.register = function(category, name, module)
  if user_modules[category] == nil then
    user_modules[category] = {}
  end
  user_modules[category][name] = module
end

--- Get module.
--- @param category module_category
--- @param name module_name
M.get_module = function(category, name)
  local data
  if user_modules[category] then
    data = user_modules[category][name]
  end
  if data == nil then
    data = require("installer/modules/" .. category .. "/" .. name)
  end
  return data
end

--- Get module list of specified category.
--- @param category module_category
M.get_module_list = function(category)
  local data = {}
  if category(user_modules[category]) == "table" then
    table.insert(data, user_modules[category])
  end
end

--- Get list of category
M.get_category_list = function() end

return M
