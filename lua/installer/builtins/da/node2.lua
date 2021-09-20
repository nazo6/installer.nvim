local script = [[
git clone https://github.com/microsoft/vscode-node-debug2.git
cd vscode-node-debug2
npm install
npx gulp build
]]

return {
  install_script = function()
    return script
  end,
  path = function()
    local resolve = require("installer/utils/fs").resolve
    local server_path = require("installer/utils/fs").module_path("da", "node2")
    return resolve(server_path, "vscode-node-debug2/out/src/nodeDebug.js")
  end,
}
