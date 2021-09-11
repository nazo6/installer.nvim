local Job = require "plenary.job"
local util = require "installer/util"

local M = {}

M.exec_script = function(script, cwd, pipe, on_exit)
  local cmd = ""
  local args = ""

  local os = util.detect_os()
  if os == "windows" then
    cmd = "powershell.exe"
    args = { "-NoProfile", "-c", [[$ErrorActionPreference = "Stop"
      ]] .. script }
  else
    cmd = "/bin/bash"
    args = { "set -e \n" .. script }
  end
  Job
    :new({
      command = cmd,
      args = args,
      cwd = cwd,
      on_exit = vim.schedule_wrap(on_exit),
      on_stdout = function(_, data)
        vim.schedule(function()
          pipe("stdout", data)
        end)
      end,
      on_stderr = function(_, data)
        vim.schedule(function()
          pipe("stderr", data)
        end)
      end,
    })
    :start()
end

return M
