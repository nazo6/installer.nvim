local config = require("lspinstall/util").extract_config "rust_analyzer"
local lsp_util = require "lspinstall/util"

local script_to_use = nil

if lsp_util.is_windows() then
  config.default_config.cmd[1] = "./rust-analyzer"
  local arch = vim.fn.getenv "PROCESSOR_ARCHITECTURE"
  local url = nil
  if arch == "ARM64" then
    url =
      "https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-aarch64-pc-windows-msvc.gz"
  else
    url =
      "https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-pc-windows-msvc.gz"
  end

  script_to_use = [[
    Invoke-WebRequest ]] .. url .. [[ -OutFile "rust-analyzer.gz"
    Function DeGZip-File{
        Param(
            $infile,
            $outfile = ($infile -replace '\.gz$','')
            )
        $input = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
        $output = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
        $gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)
        $buffer = New-Object byte[](1024)
        while($true){
            $read = $gzipstream.Read($buffer, 0, 1024)
            if ($read -le 0){break}
            $output.Write($buffer, 0, $read)
            }
        $gzipStream.Close()
        $output.Close()
        $input.Close()
    }
    $infile='rust-analyzer.gz'
    $outfile='rust-analyzer.exe'
    DeGZip-File $infile $outfile
    rm rust-analyzer.gz
    ]]
else
  config.default_config.cmd[1] = "./rust-analyzer"
  script_to_use = [[
  os=$(uname -s | tr "[:upper:]" "[:lower:]")
  mchn=$(uname -m | tr "[:upper:]" "[:lower:]")

  if [ $mchn = "arm64" ]; then
    mchn="aarch64"
    fi

    case $os in
    linux)
    platform="unknown-linux-gnu"
    ;;
    darwin)
    platform="apple-darwin"
    ;;
    esac

    curl -L -o "rust-analyzer-$mchn-$platform.gz" "https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-$mchn-$platform.gz"
    gzip -d rust-analyzer-$mchn-$platform.gz

    mv rust-analyzer-$mchn-$platform rust-analyzer

    chmod +x rust-analyzer
    ]]
end

return vim.tbl_extend("error", config, {
  -- adjusted from https://github.com/mattn/vim-lsp-settings/blob/master/installer/install-rust-analyzer.sh
  install_script = script_to_use,
})
