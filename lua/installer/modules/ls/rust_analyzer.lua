local cmd_win = "./rust-analyzer"
local arch = vim.fn.getenv("PROCESSOR_ARCHITECTURE")
local url = nil
if arch == "ARM64" then
  url =
    "https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-aarch64-pc-windows-msvc.gz"
else
  url =
    "https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-pc-windows-msvc.gz"
end

local script_win = [[
    Invoke-WebRequest -UseBasicParsing ]] .. url .. [[ -OutFile "rust-analyzer.gz"
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
local cmd = "./rust-analyzer"
local script = [[
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

return require("installer/helpers").common.builder({
  lang = "rust_analyzer",
  inherit_lspconfig = true,
  install_script = {
    win = script_win,
    other = script,
  },
  cmd = {
    win = cmd_win,
    other = cmd,
  },
})
