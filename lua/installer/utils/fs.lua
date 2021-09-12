local M = {}

--- Base path for installer.nvim
--- @type string
M.base_path = vim.fn.stdpath("data") .. "/installer.nvim/"

--- Get path of category
--- @param category string
--- @return string
M.category_path = function(category)
  return vim.fn.stdpath("data") .. "/installer.nvim/" .. category
end

--- Get installation path of module
--- @param category string
--- @param name string
--- @return string
M.module_path = function(category, name)
  return vim.fn.stdpath("data") .. "/installer.nvim/" .. category .. "/" .. name
end

--- Get directory info
--- Warn: This function access fs synchronously
--- @param path string
--- @return {type:string, name:string}[]
M.read_dir = function(path)
  local handle = vim.loop.fs_opendir(path, nil, 10000)
  local dirs = vim.loop.fs_readdir(handle)
  vim.loop.fs_closedir(handle)

  return dirs
end

return M
