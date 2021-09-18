local log = require("installer/utils/log")
local Job = require("plenary.job")
local is_windows = require("installer/utils/os").is_windows

local M = {}

M.exec_script = function(script, cwd, pipe, on_exit)
  log.debug_log("[jobs/exec_script] Starting job. Script:\n", script)
  local cmd = ""
  local args = ""

  if is_windows then
    cmd = "powershell.exe"
    args = {
      "-NoProfile",
      "-c",
      [[$ErrorActionPreference = "Stop"
      $ProgressPreference = 'SilentlyContinue'
      ]] .. script,
    }
  else
    cmd = "/bin/bash"
    args = { "-e", "-c", script }
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
