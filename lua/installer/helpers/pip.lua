local resolve = require("installer/utils/fs").resolve
local is_windows = require("installer/utils/os").is_windows

return {
  install_script = function(package_to_install)
    local python_to_use = ""
    if vim.fn.executable("python3") == 1 then
      python_to_use = "python3"
    else
      python_to_use = "python"
    end
    local is_python3 = false

    local version_line = io.popen(python_to_use .. ' -c "import sys; print(sys.version_info.major)"'):read("l")
    if version_line == "3" then
      is_python3 = true
    end

    if is_python3 == false then
      -- "util.print_warning("Sorry couldn't find valid python of version 3")
      return 'echo "Couldn\'t find python 3"'
    end

    if is_windows then
      return python_to_use
        .. [[ -m venv ./venv
      ./venv/Scripts/pip3 install -U pip
      ./venv/Scripts/pip3 install -U ]]
        .. package_to_install
    else
      return python_to_use
        .. [[ -m venv ./venv
      ./venv/bin/pip3 install -U pip
      ./venv/bin/pip3 install -U ]]
        .. package_to_install
    end
  end,
  bin_path = function(bin_name)
    if is_windows then
      return resolve("venv/Scripts", bin_name)
    else
      return resolve("venv/bin", bin_name)
    end
  end,
}
