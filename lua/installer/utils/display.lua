local api = vim.api

local log = require("installer/utils/log")

local M = {}

--- Display
--- @alias disp_content {title:string, message:string, lines:number}
--- @alias content_id number
--- @type {disp: {win:nil|number, buf:nil|number}, contents: tbl<content_id, disp_content>}
local display = {
  contents = {},
  disp = {
    win = nil,
    buf = nil,
    ns = nil,
  },
}

local update_lines = function(line_start, line_end, message)
  api.nvim_buf_set_option(display.disp.buf, "modifiable", true)
  api.nvim_buf_call(display.disp.buf, function()
    for i = 0, line_end - line_start + 1 do
      if message[i + 1] then
        vim.fn.setline(line_start + i, message[i + 1])
      end
    end
  end)
  api.nvim_buf_set_option(display.disp.buf, "modifiable", false)
end

local get_title_line = function(id)
  local start = 3
  for i = 1, id - 1 do
    start = start + display.contents[i].lines
  end
  return start
end
local get_message_lines = function(id)
  local start = 3
  for i = 1, id - 1 do
    start = start + display.contents[i].lines
  end
  return start + 1, (start + display.contents[id].lines - 1) + 1
end

M.open = function(title, initial_message, lines)
  local new_id = #display.contents + 1

  local create_new_buf = true
  if display.disp.win and display.disp.buf and display.disp.buf then
    if api.nvim_win_is_valid(display.disp.win) then
      api.nvim_set_current_buf(display.disp.buf)
      api.nvim_set_current_win(display.disp.win)
      create_new_buf = false
    end
  end
  if create_new_buf then
    vim.cmd([[65vnew]])
    display.disp.win = api.nvim_get_current_win()
    display.disp.buf = api.nvim_get_current_buf()

    display.disp.ns = api.nvim_create_namespace("")

    local width = api.nvim_win_get_width(0)
    local pad_width = math.floor((width - string.len("installer.nvim")) / 2.0)
    api.nvim_buf_set_lines(display.disp.buf, 0, 1, true, {
      string.rep(" ", pad_width) .. "installer.nvim",
      " " .. string.rep("━", width - 2),
    })
    api.nvim_buf_set_option(display.disp.buf, "filetype", "installer")
    api.nvim_buf_set_name(display.disp.buf, "[installer.nvim]")

    api.nvim_buf_set_option(display.disp.buf, "buftype", "nofile")
    api.nvim_buf_set_option(display.disp.buf, "bufhidden", "hide")
    api.nvim_buf_set_option(display.disp.buf, "swapfile", false)
  end

  display.contents[new_id] = { lines = lines }
  M.update(new_id, title, initial_message)

  return new_id
end

M.update = function(id, title, message)
  display.contents[id].message = message
  local s, e = get_message_lines(id)
  update_lines(s, e, message)
  if title then
    display.contents[id].title = title
    local t = get_title_line(id)
    update_lines(t, t, title)
  end
end

return M
