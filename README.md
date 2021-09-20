<h1 align="center">
  installer.nvim
</h1>

`installer.nvim` is a plugin that allows you to install external dependencies from neovim.

## Status

Beta. Operation is often unstable. APIs is subject to change without notice.

**If you were using `nazo6/lspinstall.nvim`(`main` branch), this plugin is incompatible with it. You can cotinue to use it by specifying `main` branch.**

## Features

- Many builtin installers.
- Most of builtin installers support windows.
- Able to create custom installers.
- Configurable.

You can find the built-in modules [here](./BUILTINS.md)

## Install

This plugin requires `plenary.nvim`.

With `packer.nvim`

```lua
use { "nazo6/installer.nvim",
  requires = {"nvim-lua/plenary.nvim"}
}
```

## Usage

You can install module using `:Install <category> <name>` and uninstall using `:Uninstall <category> <name>`.
You can also use `:Update` to update modules at once.

This plugin does not make much sense on its own. It is more powerful when used in combination with various plugins using the integrations.

## Configs

There is a `setup` function. This plugin works even if you don't call it, but if you do, call it before any other integration.

This is example of config.

```lua
require("installer").setup({
  -- Automatically installs modules that are not installed at startup
  ensure_installed = {
    ls = {"bashls", "tsserver"}
    tools = {"ripgrep"}
  }
   -- User defined modules(installers). See the "Custom module" section below for more information.
  custom_modules = {
    "ls" = {
      "some_language_server" = {
        install_script = function()
        end,
        lsp_config = function()
        end
      }
    }
  },
  -- Hooks
  hooks = {
    install = {
      pre = {
        function (category, name)
        end
      }
    }
  }
  debug = false,
})
```

### Language Server (LSP)

There are integration for installing and configurating language server.

⚠️ You have to install `nvim-lspconfig` to use this.

Calling the `setup` function will set up all the installed servers belonging to the `ls` category.

```lua
require("installer.integrations.ls").setup {
  configs = server_configs, -- Table<server_name, config> of lsp config. This will be passed to lspconfig.
  enable_hook = true, -- Auto setup server after installed.
}
```

### null-ls

```lua
require("installer.integrations.null_ls").setup {
  configs = {
    debug = true,
  },
  enable_hook = true,
}
require("lspconfig")["null-ls"].setup {
  capabilities = common_config.capabilities,
  on_attach = common_config.on_attach,
}
```

### tools

Modules belonging to the `tools` category have information about the own path, which can be retrieved with the following code.

```lua
require("installer.integrations.tools").get "ripgrep",
```

⚠️Note that it will return the path whether it is actually installed or not. Use `ensure_installed` if you want to be sure that it is installed.

This will make any external dependencies of the plugin portable.
This is an example of the configuration in `telescope.nvim`.

```lua
require("telescope").setup {
  defaults = {
    vimgrep_arguments = {
      require("installer.integrations.tools").get "ripgrep",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
  },
}
```

## Reference

### Commands

- `:Install <category> <name>`: Install module. For example: `:Install ls bashls`
- `:Reinstall <category> <name>`: Reinstall module.
- `:Uninstall <category> <name>`: Uninstall module.
- `:Update [<category> <name>]`: Update module. If args are omitted, all plugins will be updated.

### APIs

#### `installer`

- `setup(config)` Set config and install modules specified by `ensure_installed`
- `register(category, name, module)`
- `install(category, name)`
- `uninstall(category, name)`
- `reinstall(category, name)`
- `module_path(category, name)` Get installation path of module. This function returns the path regardless of whether the module is actually installed or not.

#### `installer/status`

- `get_module(category, name)` Get module content

#### `installer/status/{available, installed}`

- `get_modules()` Get all module name table
- `get_categories()` Get all categories name
- `get_category_modules(category)` Get all modules of category

#### `installer/integrations/ls`

- `setup(opts)` Setup ls.
- `setup_server(name, lsp_settings)` Setup ls.

#### `installer/integrations/null_ls`

- `setup(opts)`
- `get(module_name)`
- `get_all()`

#### `installer/integrations/tools`

- `get(module_name)`
- `get_all()`

### Custom modules

You can create custom modules and register it by `setup` or `register` function.
All modules must have `install_script` field, which is function that return install script. You should determine the os in your function and return the appropriate script for it.
On Windows, the script will run in `powershell.exe`, otherwise it will run in `/bin/bash`.

#### About category

`require"installer/integrations/ls".setup()` loads modules which belong to `ls` category. In this way, we can set up the categories properly and make the integration function work well.

And for some categories, additional fields may be required in the module, which is used in integration.

For example. `ls` category requires `lsp_config()` field, which provides function to return table passed for `nvim-lspconfig`.
There are also helper functon which is useful to create custom modules. For more details, please check [here](./lua/installer/builtins/ls/template.lua)

```lua
local some_language_server = {
  install_script = function()
  end,
  lsp_config = function()
  end
}

require"installer".register("ls", "somels", some_language_server)
```

## Credits

- [nvim-lspinstall](https://github.com/kabouzeid/nvim-lspinstall/) and [This PR](https://github.com/kabouzeid/nvim-lspinstall/pull/96) - Base of this plugin.
- [packer.nvim](https://github.com/wbthomason/packer.nvim) - Very helpful about the displaying.
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
