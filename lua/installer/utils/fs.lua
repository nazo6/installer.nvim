local M = {}

--- Resolve path
--- @vararg string
--- @return string
M.resolve = function(...)
  local res = ""
  for index, value in ipairs({ ... }) do
    if index >= 2 and value:sub(1, 1) == "/" then
      value = value:sub(2)
    elseif value:sub(1, 2) == "./" or value:sub(1, 2) == ".\\" then
      value = value:sub(3)
    end
    if value:sub(-1) == "/" or value:sub(-1) == "\\" then
      value = value:sub(1, -2)
    end
    res = res .. "/" .. value
  end
  if require("installer/utils/os").is_windows then
    res = res:gsub("/", "\\")
  else
    res = res:gsub("\\", "/")
  end

  res = res:sub(2)

  return res
end

--- Base path for installer.nvim
--- @type string
M.base_path = M.resolve(vim.fn.stdpath("data"), "installer.nvim")

--- Get path of category
--- @param category string
--- @return string
M.category_path = function(category)
  return M.resolve(vim.fn.stdpath("data"), "installer.nvim", category)
end

--- Get installation path of module
--- @param category string
--- @param name string
--- @return string
M.module_path = function(category, name)
  return M.resolve(vim.fn.stdpath("data"), "installer.nvim", category, name)
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
