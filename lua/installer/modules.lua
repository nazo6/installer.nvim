local M = {}

--- @type table<module_type, module_type_content>
local user_modules = {}

--- Register user-defined installer.
--- @param type module_type
--- @param name module_name
--- @param module module
M.register = function(type, name, module)
  if user_modules[type] == nil then
    user_modules[type] = {}
  end
  user_modules[type][name] = module
end

--- Get module.
--- @param type module_type
--- @param name module_name
M.get_module = function(type, name)
  local data
  if user_modules[type] then
    data = user_modules[type][name]
  end
  if data == nil then
    data = require("installer/modules/" .. type .. "/" .. name)
  end
  return data
end

--- Get module list of specified type.
--- @param type module_type
M.get_module_list = function(type)
  local data = {}
  if type(user_modules[type]) == "table" then
    table.insert(data, user_modules[type])
  end
end

return M
