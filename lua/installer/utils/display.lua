local api = vim.api

local log = require("installer/utils/log")

local M = {}

local display = {
  status = {},
}

local display_mt = {}

local function make_header(disp)
  local width = api.nvim_win_get_width(0)
  local pad_width = math.floor((width - string.len(config.title)) / 2.0)
  api.nvim_buf_set_lines(disp.buf, 0, 1, true, {
    string.rep(" ", pad_width) .. config.title,
    " " .. string.rep("━", width - 2),
  })
end

--- Initialize options, settings, and keymaps for display windows
local function setup_window(disp)
  api.nvim_buf_set_option(disp.buf, "filetype", "installer")
  api.nvim_buf_set_name(disp.buf, "[installer.nvim]")
end

M.open = function()
  if display.status.disp then
    if api.nvim_win_is_valid(display.status.disp.win) then
      api.nvim_win_close(display.status.disp.win, true)
    end

    display.status.disp = nil
  end

  local disp = setmetatable({}, display_mt)

  vim.cmd([[65vnew]])
  disp.win = api.nvim_get_current_win()
  disp.buf = api.nvim_get_current_buf()

  disp.ns = api.nvim_create_namespace("")
  make_header(disp)
  setup_window(disp)
  display.status.disp = disp

  return disp
end

return M
