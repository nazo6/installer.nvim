local fs = require("installer/utils/fs")

local M = {}

--- @alias category_modules tbl<string,boolean>

--- Get all installed modules table
--- Warn: This function access fs synchronously
--- @return tbl<string, category_modules>
M.get_modules = function()
  local res = {}

  local dirs = fs.read_dir(fs.base_path)
  for _, dir in ipairs(dirs) do
    if dir.type == "directory" then
      local category = M.category_installed(dir.name)
      res[dir.name] = category
    end
  end
  return res
end

--- Get all categories
--- Warn: This function access fs synchronously
--- @return tbl<string,boolean>
M.get_categories = function()
  local res = {}

  local dirs = fs.read_dir(fs.base_path)
  for _, dir in ipairs(dirs) do
    if dir.type == "directory" then
      res[dir.name] = true
    end
  end
  return res
end

--- Get modules of category
--- Warn: This function access fs synchronously
--- @param category string
--- @return category_modules
M.get_category_modules = function(category)
  local res = {}

  local path = fs.category_path(category)

  if vim.fn.isdirectory(path) == 1 then
    local dirs = fs.read_dir(path)
    for _, dir in ipairs(dirs) do
      if dir.type == "directory" then
        res[dir.name] = true
      end
    end
  end
  inspect(res)
  return res
end

return M
