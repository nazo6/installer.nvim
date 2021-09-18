return {
  install_script = function()
    if require("installer/utils/os").is_windows then
      return [[
        if (Test-Path PowerShellEditorServices) {
          Remove-Item -Force -Recurse PowerShellEditorServices
        }
        Invoke-WebRequest -UseBasicParsing https://github.com/PowerShell/PowerShellEditorServices/releases/latest/download/PowerShellEditorServices.zip -OutFile "pses.zip"
        Expand-Archive .\pses.zip -DestinationPath .\PowerShellEditorServices
        Remove-Item pses.zip
      ]]
    else
      return [[
        curl -L -o "pses.zip" https://github.com/PowerShell/PowerShellEditorServices/releases/latest/download/PowerShellEditorServices.zip
        rm -rf PowerShellEditorServices
        unzip pses.zip -d PowerShellEditorServices
        rm pses.zip
      ]]
    end
  end,
  lsp_config = function()
    local fs = require("installer/utils/fs")
    local config = require("installer/integrations/ls/utils").extract_config("powershell_es")

    local temp_path = vim.fn.stdpath("cache")
    local bundle_path = fs.module_path("ls", "powershell_es") .. "/PowerShellEditorServices"
    local command_fmt =
      [[%s/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath %s -LogPath %s/powershell_es.log -SessionDetailsPath %s/powershell_es.session.json -FeatureFlags @() -AdditionalModules @() -HostName nvim -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal]]
    local command = command_fmt:format(bundle_path, bundle_path, temp_path, temp_path)
    local cmd = { "pwsh", "-NoLogo", "-NoProfile", "-Command", command }

    config.default_config.cmd = cmd
    config.default_config.on_new_config = function(new_config)
      new_config.cmd = cmd
    end

    return config
  end,
}
