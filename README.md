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

### Language Server (LSP)

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

## Credits
- [nvim-lspinstall](https://github.com/kabouzeid/nvim-lspinstall/) and [This PR](https://github.com/kabouzeid/nvim-lspinstall/pull/96)  - Base of this plugin.
- [packer.nvim](https://github.com/wbthomason/packer.nvim) - Very inspired by the installation screen.
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
