-- NOTE: this file is adjusted from nvim-lspconfig and nvim-jdtls

local util = require("lspconfig/util")
local path = util.path
local lsp_util = require("installer/util")

local script_to_use = nil

local root_files = {
  -- Single-module projects
  {
    "build.xml", -- Ant
    "pom.xml", -- Maven
    "settings.gradle", -- Gradle
    "settings.gradle.kts", -- Gradle
  },
  -- Multi-module projects
  { "build.gradle", "build.gradle.kts" },
}

--- Callback function for the `language/status` notification.
--
-- The server sends a non-standard notification when the status of the language
-- server changes. This can be used to display progress as the server is
-- starting up.
local function on_language_status(_, _, result)
  local command = vim.api.nvim_command
  command("echohl ModeMsg")
  command(string.format('echo "%s"', result.message))
  command("echohl None")
end

--- The default config to be used
local default_config = {
  root_dir = function(...)
    for _, patterns in ipairs(root_files) do
      local root = util.root_pattern(unpack(patterns))(...)
      if root then
        return root
      end
    end
    return util.root_pattern(".git")(...)
  end,
  filetypes = { "java" },
  init_options = {
    workspace = path.join({ vim.loop.os_homedir(), "workspace" }),
    jvm_args = {},
    os_config = nil,
  },
  handlers = {
    -- Due to an invalid protocol implementation in the jdtls we have to
    -- conform these to be spec compliant.
    -- https://github.com/eclipse/eclipse.jdt.ls/issues/376
    -- Command in org.eclipse.lsp5j -> https://github.com/eclipse/lsp4j/blob/master/org.eclipse.lsp4j/src/main/xtend-gen/org/eclipse/lsp4j/Command.java
    -- CodeAction in org.eclipse.lsp4j -> https://github.com/eclipse/lsp4j/blob/master/org.eclipse.lsp4j/src/main/xtend-gen/org/eclipse/lsp4j/CodeAction.java
    -- Command in LSP -> https://microsoft.github.io/language-server-protocol/specification#command
    -- CodeAction in LSP -> https://microsoft.github.io/language-server-protocol/specification#textDocument_codeAction
    ["textDocument/codeAction"] = function(a, b, actions)
      for _, action in ipairs(actions) do
        -- TODO: (steelsojka) Handle more than one edit?
        -- if command is string, then 'ation' is Command in java format,
        -- then we add 'edit' property to change to CodeAction in LSP and 'edit' will be executed first
        if action.command == "java.apply.workspaceEdit" then
          action.edit = action.edit or action.arguments[1]
          -- if command is table, then 'action' is CodeAction in java format
          -- then we add 'edit' property to change to CodeAction in LSP and 'edit' will be executed first
        elseif type(action.command) == "table" and action.command.command == "java.apply.workspaceEdit" then
          action.edit = action.edit or action.command.arguments[1]
        end
      end

      require("vim.lsp.handlers")["textDocument/codeAction"](a, b, actions)
    end,
    ["language/status"] = vim.schedule_wrap(on_language_status),
  },
}

if lsp_util.is_windows() then
  default_config.on_new_config = function(new_config, new_root_dir)
    -- we're making an exception for this config by allowing to use `install_path("java")`
    local install_path = require("installer/util").install_path("java"):gsub("/", "\\")
    local workspace_name = "work" -- default workspace directory
    if new_root_dir ~= nil then
      local workspace_name, _ = string.gsub(vim.fn.fnamemodify(new_root_dir, ":p"), "/", "-")
    end
    local get_launcher = function(plugins_dir)
      for item in io.popen("dir " .. plugins_dir .. " /b"):lines() do
        if string.match(item, "org.eclipse.equinox.launcher_") then
          return plugins_dir .. item
        end
      end
      return plugins_dir
    end
    new_config.cmd = lsp_util.concat({
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xmx2G",
      "-javaagent:" .. install_path .. "/lombok.jar",
      "-jar",
      get_launcher(install_path .. "\\plugins\\"),
      "-configuration",
      install_path .. "/config_win",
      "-data",
      path.join({ install_path, "workspace", workspace_name }),
      "--add-modules=ALL-SYSTEM",
      "--add-opens java.base/java.util=ALL-UNNAMED",
      "--add-opens java.base/java.lang=ALL-UNNAMED",
    })
  end
  script_to_use = [[
    curl.exe -L -o jdt-language-server-latest.tar.gz http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
    tar.exe -xf jdt-language-server-latest.tar.gz
    curl.exe -L -o lombok.jar https://projectlombok.org/downloads/lombok.jar
  ]]
else
  default_config.on_new_config = function(new_config, new_root_dir)
    -- we're making an exception for this config by allowing to use `install_path("java")`
    local install_path = require("installer/util").install_path("java")
    local workspace_name, _ = string.gsub(vim.fn.fnamemodify(new_root_dir, ":p"), "/", "-")
    new_config.cmd = {
      path.join({ install_path, "jdtls.sh" }),
      path.join({ install_path, "workspace", workspace_name }),
    }
  end
  script_to_use = [[
    curl -L -o - http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz | tar xvz
    curl -L -o lombok.jar https://projectlombok.org/downloads/lombok.jar

cat << EOF > jdtls.sh
#!/usr/bin/env bash

WORKSPACE="\$1"

die () {
  echo
  echo "$*"
  echo
  exit 1
}

case $(uname) in
  Linux)
    CONFIG="$(pwd)/config_linux"
    ;;
  Darwin)
    CONFIG="$(pwd)/config_mac"
    ;;
esac

JAR="$(pwd)/plugins/org.eclipse.equinox.launcher_*.jar"

# Determine the Java command to use to start the JVM.
if [ -n "\$JAVA_HOME" ] ; then
    if [ -x "\$JAVA_HOME/jre/sh/java" ] ; then
        # IBM's JDK on AIX uses strange locations for the executables
        JAVACMD="\$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="\$JAVA_HOME/bin/java"
    fi
    if [ ! -x "\$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: \$JAVA_HOME

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
    fi
else
    JAVACMD="java"
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
fi

"\$JAVACMD" \\
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \\
  -Dosgi.bundles.defaultStartLevel=4 \\
  -Declipse.product=org.eclipse.jdt.ls.core.product \\
  -Dlog.protocol=true \\
  -Dlog.level=ALL \\
  -Xms1g \\
  -Xmx2G \\
  -javaagent:$(pwd)/lombok.jar \\
  -Xbootclasspath/a:$(pwd)/lombok.jar \\
  --add-modules=ALL-SYSTEM \\
  --add-opens java.base/java.util=ALL-UNNAMED \\
  --add-opens java.base/java.lang=ALL-UNNAMED \\
  -jar \$(echo "\$JAR") \\
  -configuration "\$CONFIG" \\
  -data "\$WORKSPACE"
EOF
    chmod +x jdtls.sh
  ]]
end

return {
  default_config = default_config,
  install_script = script_to_use,
}
