-- Display utils

local api = vim.api

local M = {}

local display = {
  buf = nil,
  contents = {},
}

local set_line = function(line, content)
  api.nvim_buf_set_option(display.buf, "modifiable", true)
  api.nvim_buf_set_lines(display.buf, line, line, true, { content })
  api.nvim_buf_set_option(display.buf, "modifiable", false)
end

local update_display = function(id)
  local line = #display.contents * 2 + 1
  set_line(line, display.contents[id].title)
  set_line(line + 1, display.contents[id].content)
end

M.open = function()
  if display.buf == nil then
    display.buf = api.nvim_create_buf(false, true)

    set_line(0, "installer.nvim installer")
    set_line(1, "----")
  end
  api.nvim_buf_set_option(display.buf, "modifiable", false)
  api.nvim_buf_set_name(display.buf, "installer.nvim dashboard")

  api.nvim_set_current_buf(display.buf)
end

M.add = function(title, content)
  if display[content] then
    return false
  end
  local id = #display.contents + 1
  display.contents[id] = {
    title = title,
    content = content,
  }
  update_display(id)
  return id
end

M.update = function(id, status, content)
  display.contents[id] = {
    status = status,
    content = content,
  }
  update_display(id)
end

return M
