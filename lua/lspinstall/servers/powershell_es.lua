local config = require("lspinstall/util").extract_config "powershell_es"
local lsp_util = require "lspinstall/util"

local script_to_use = nil

local temp_path = vim.fn.stdpath "cache"
local bundle_path = lsp_util.install_path "powershell_es" .. "/PowerShellEditorServices"
local command_fmt =
  [[%s/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath %s -LogPath %s/powershell_es.log -SessionDetailsPath %s/powershell_es.session.json -FeatureFlags @() -AdditionalModules @() -HostName nvim -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal]]
local command = command_fmt:format(bundle_path, bundle_path, temp_path, temp_path)
local cmd = { "pwsh", "-NoLogo", "-NoProfile", "-Command", command }
config.default_config.cmd = cmd

if lsp_util.is_windows() then
  script_to_use = [[
    Remove-Item -Force -Recursive PowerShellEditorServices
    Invoke-WebRequest -UseBasicParsing https://github.com/PowerShell/PowerShellEditorServices/releases/latest/download/PowerShellEditorServices.zip -OutFile "pses.zip"
    Expand-Archive .\pses.zip -DestinationPath .\PowerShellEditorServices
    Remove-Item pses.zip
  ]]
else
  script_to_use = [[
    curl -L -o "pses.zip" https://github.com/PowerShell/PowerShellEditorServices/releases/latest/download/PowerShellEditorServices.zip
    rm -rf PowerShellEditorServices
    unzip pses.zip -d PowerShellEditorServices
    rm pses.zip
  ]]
end

config.default_config.on_new_config = function(new_config)
  new_config.cmd = cmd
end

return vim.tbl_extend("error", config, {
  install_script = script_to_use,
})
