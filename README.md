<h1 style="text-align: center;">
  installer.nvim
</h1>
<hr />

`installer.nvim` is a plugin that allows external dependencies (Language Server, Debug Adapter) to be installed in neovim, making the configuration fully reproducible.

## Features
- Many builtin installers for Language Server, Debug Adapter and null-ls.
- Most of builtin installers support windows.
- Able to create custom installers.

## Install
This plugin requires `plenary.nvim`.

With `packer.nvim`
```lua
use { "nazo6/installer.nvim",
  requires = {"nvim-lua/plenary.nvim"}
}
```

## Config
The only core function of this plugin is to run the installation script and return the path of the installed items. LS integration, etc. are separated from the core.

## Reference
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

### Commands

- `:Install <category> <name>`: Install module. For example: `:Install ls bashls`
- `:Reinstall <category> <name>`: Reinstall module.
- `:Uninstall <category> <name>`: Uninstall module.
- `:Update <category> <name>`: Update module.

## Credits
- [nvim-lspinstall](https://github.com/kabouzeid/nvim-lspinstall/) and [This PR](https://github.com/kabouzeid/nvim-lspinstall/pull/96) Base of this plugin.
