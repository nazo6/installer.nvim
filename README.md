<h1 align="center">
  installer.nvim
</h1>

`installer.nvim` is a plugin that allows external dependencies (Language Server, Debug Adapter) to be installed in neovim, making the configuration fully reproducible.

## Features
- Many builtin installers.
- Most of builtin installers support windows.
- Able to create custom installers.
- Configurable by lua.

You can find the built-in installer [here](./BUILTINS.md)

## Install
This plugin requires `plenary.nvim`.

With `packer.nvim`
```lua
use { "nazo6/installer.nvim",
  requires = {"nvim-lua/plenary.nvim"}
}
```

## Config
There is `setup` function, but you don't have to call it.
Please don't copy and paste below config. It is just example.
```lua
require("installer").setup({
  -- Automatically installs modules that are not installed at startup
  ensure_install = {
    ls = {"bashls", "tsserver"}
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
  -- Called before installation
  pre_install_hook = function(category, name) end
  -- Called after successful installation
  post_install_hook = function(category, name) end
  debug = false,
})
```

### Language Server (LSP)
There are integration for installing and configurating language server.

You have to setup it.
```lua
require("installer.integrations.ls").setup {
  configs = server_configs, -- Table<server_name, config> of lsp config. This will be passed to lspconfig.
  enable_install_hook = true, -- Auto setup server after installed.
}
```

## Reference
### Commands

- `:Install <category> <name>`: Install module. For example: `:Install ls bashls`
- `:Reinstall <category> <name>`: Reinstall module.
- `:Uninstall <category> <name>`: Uninstall module.

### APIs
#### `installer/`
- `setup()`
- `install()`
- `uninstall()`
- `status()`

#### `installer/integrations/ls`
- `setup()`
#### `installer/integrations/ls/helper`
- `build()`

#### `installer/integrations/null-ls`
- `get()`
#### `installer/integrations/null-ls/helper`
- `build()`

#### `installer/helpers/npm`
#### `installer/helpers/pip`
#### `installer/helpers/common`

## Credits
- [nvim-lspinstall](https://github.com/kabouzeid/nvim-lspinstall/) and [This PR](https://github.com/kabouzeid/nvim-lspinstall/pull/96)  - Base of this plugin.
- [packer.nvim](https://github.com/wbthomason/packer.nvim) - Very helpful about the displaying.
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
