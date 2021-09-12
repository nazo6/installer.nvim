local uv = vim.loop

local M = {}

--- Prints message with warning highlights
function M.print_warning(msg)
  vim.api.nvim_echo({ { msg, "WarningMsg" } }, true, {})
end

--- Gets module install directory
--@returns string
function M.install_path(category, name)
  return vim.fn.stdpath("data") .. "/installer.nvim/" .. category .. "/" .. name
end

--- Get absolute path of server
function M.absolute_path(lang, path)
  return M.install_path("ls", lang) .. "/" .. path
end

--- Combine commands to single string
--@return string
function M.concat(t, autoseparate)
  local separator = " "
  if autoseparate == true then
    if M.is_windows() then
      separator = " &"
    else
      separator = "; "
    end
  end
  return table.concat(t, separator)
end

return M
