$types = Get-ChildItem -Directory -Path (Join-Path $PSScriptRoot  "../lua/installer/builtins")
foreach ($type in $types)
{
  $modules = Get-ChildItem -Path $type
  $write_text = "local modules = {`n"
  foreach ($module in $modules)
  {
    $module_name = Split-Path (Convert-Path $module) -LeafBase
    $write_text += "  $module_name = true,`n" 
  }
  $write_text += "}`n`nreturn modules"
  Write-Output $write_text | Out-File ((Convert-Path $type) + ".lua") -encoding ascii -NoNewline
}
