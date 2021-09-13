local user_modules = require("installer/config").get().custom_modules

local builtins = {
  ls = require("installer/builtins/ls"),
}

local M = {}

--- Get all installed modules table
--- Warn: This function access fs synchronously
--- @return tbl<string, category_modules>
M.get_modules = function()
  local m = builtins

  for category, _ in pairs(user_modules) do
    if not m[category] then
      m[category] = {}
    end
    for module_name, _ in pairs(user_modules[category]) do
      m[category][module_name] = true
    end
  end

  return m
end

--- Get all categories
--- Warn: This function access fs synchronously
--- @return tbl<string,boolean>
M.get_categories = function()
  local c = {}
  for category, _ in pairs(M.get_modules()) do
    c[category] = true
  end
  return c
end

--- Get modules of category
--- Warn: This function access fs synchronously
--- @param category string
--- @return category_modules
M.get_category_modules = function(category)
  return M.get_modules()[category]
end

return M
