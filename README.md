## About

This is fork version of [nvim-lspinstall](https://github.com/kabouzeid/nvim-lspinstall).
Mainly windows support is added.
Many code is from [this PR](https://github.com/kabouzeid/nvim-lspinstall/pull/96)

## Setup

### Notice

- Some install scripts may not work with Powershell 7. In the case, please try running them in Powershell 5.

### Install

With `packer.nvim`

```lua
use "nazo6/lspinstall.nvim"
```

### Settings

```lua
local function setup_servers()
  require'lspinstall'.setup()
  local servers = require'lspinstall'.installed_servers()
  for _, server in pairs(servers) do
    require'lspconfig'[server].setup{}
  end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
require'lspinstall'.post_install_hook = function ()
  setup_servers() -- reload installed servers
  vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end
```

## Usage

- `:LspInstall <language>` to install/update the language server for `<language>` (e.g. `:LspInstall python`).
- `:LspReinstall <language>` to re-install the language server for `<language>`.
- `:LspUninstall <language>` to uninstall the language server for `<language>`.
- `require'lspinstall'.setup()` to make configs of installed servers available for `require'lspconfig'.<server>.setup{}`.

## Installers

- :ballot_box_with_check: : There is an LS installation script, but I have not verified that it installs and works.
- :white_check_mark: : I have confirmed that the installation and operation are successful.

| Name                   | Language Server                          | Win                     | Linux                   |
| ---------------------- | ---------------------------------------- | ----------------------- | ----------------------- |
| angularls              | Angular Language Service                 | :ballot_box_with_check: | :ballot_box_with_check: |
| bashls                 | bash-language-server                     | :ballot_box_with_check: | :ballot_box_with_check: |
| clojure_lsp            | clojure-lsp                              | :ballot_box_with_check: | :ballot_box_with_check: |
| cmake                  | cmake-language-server                    | :ballot_box_with_check: | :ballot_box_with_check: |
| cpp                    | clangd                                   | :ballot_box_with_check: | :ballot_box_with_check: |
| cssls                  | vscode-langservers-extracted             | :ballot_box_with_check: | :ballot_box_with_check: |
| dockerls               | docker-langserver                        | :ballot_box_with_check: | :ballot_box_with_check: |
| elixirls               | Elixir Language Server (elixir-ls)       | :ballot_box_with_check: | :ballot_box_with_check: |
| elmls                  | Elm Language Server (elm-ls)             | :ballot_box_with_check: | :ballot_box_with_check: |
| ember                  | Ember Language Server                    | :ballot_box_with_check: | :ballot_box_with_check: |
| fortran                | Fortran Language Server (fortls)         | :ballot_box_with_check: | :ballot_box_with_check: |
| gopls                  | gopls                                    | :ballot_box_with_check: | :ballot_box_with_check: |
| graphql                | GraphQL language service                 | :ballot_box_with_check: | :ballot_box_with_check: |
| haskell                | haskell-language-server                  | :ballot_box_with_check: | :ballot_box_with_check: |
| html                   | vscode-langservers-extracted             | :white_check_mark:      | :white_check_mark:      |
| intelephense           | intelephense                             | :ballot_box_with_check: | :ballot_box_with_check: |
| jdtls                  | Eclipse JDTLS with Lombok                |                         | :ballot_box_with_check: |
| jsonls                 | vscode-langservers-extracted             | :white_check_mark:      | :white_check_mark:      |
| kotlin_language_server | kotlin-language-server                   |                         | :ballot_box_with_check: |
| latex                  | texlab                                   | :white_check_mark:      | :ballot_box_with_check: |
| ocamlls                | ocaml-language-server                    | :ballot_box_with_check: | :ballot_box_with_check: |
| omnisharp              | OmniSharp                                | :ballot_box_with_check: | :ballot_box_with_check: |
| powershell_es          | PowerShellEditorServices                 | :white_check_mark:      | :white_check_mark:      |
| prismals               | prisma-language-server                   | :ballot_box_with_check: | :ballot_box_with_check: |
| purescriptls           | purescript-language-server               | :ballot_box_with_check: | :ballot_box_with_check: |
| pyright                | pyright-langserver                       | :ballot_box_with_check: | :ballot_box_with_check: |
| rust_analyzer          | rust-analyzer                            | :white_check_mark:      | :ballot_box_with_check: |
| solargraph             | solargraph                               | :ballot_box_with_check: | :ballot_box_with_check: |
| sqlls                  | sql-language-server                      | :ballot_box_with_check: | :ballot_box_with_check: |
| sumneko_lua            | (sumneko) lua-language-server            | :white_check_mark:      | :ballot_box_with_check: |
| svelte                 | svelte-language-server                   | :ballot_box_with_check: | :ballot_box_with_check: |
| tailwindcss            | tailwindcss-intellisense                 | :white_check_mark:      | :ballot_box_with_check: |
| terraform              | Terraform Language Server (terraform-ls) |                         | :ballot_box_with_check: |
| tsserver               | typescript-language-server               | :white_check_mark:      | :white_check_mark:      |
| vimls                  | vim-language-server                      | :ballot_box_with_check: | :ballot_box_with_check: |
| vls                    | Vue vls (vetur)                          | :ballot_box_with_check: | :ballot_box_with_check: |
| yamlls                 | yaml-language-server                     | :white_check_mark:      | :white_check_mark:      |

| Name         | Description                                         | Win                     | Linux                   |
| ------------ | --------------------------------------------------- | ----------------------- | ----------------------- |
| denols       | https://deno.land/                                  |                         | :ballot_box_with_check: |
| diagnosticls | https://github.com/iamcco/diagnostic-languageserver | :ballot_box_with_check: | :ballot_box_with_check: |
| efm          | https://github.com/mattn/efm-langserver             | :ballot_box_with_check: | :ballot_box_with_check: |
| rome         | https://rome.tools/                                 | :ballot_box_with_check: | :ballot_box_with_check: |

## Custom Installer

Use `require'lspinstall/servers'.<lang> = config` to register a config with an installer.
Here `config` is a LSP config for [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig), the only difference is that there are two additional keys `install_script` and `uninstall_script` which contain shell scripts to install/uninstall the language server.

The following example provides an installer for `bash-language-server`.

```lua
-- 1. get the default config from nvim-lspconfig
local config = require"lspinstall/util".extract_config("bashls")
-- 2. update the cmd. relative paths are allowed, lspinstall automatically adjusts the cmd and cmd_cwd for us!
config.default_config.cmd[1] = "./node_modules/.bin/bash-language-server"

-- 3. extend the config with an install_script and (optionally) uninstall_script
require'lspinstall/servers'.bash = vim.tbl_extend('error', config, {
  -- lspinstall will automatically create/delete the install directory for every server
  install_script = [[
  ! test -f package.json && npm init -y --scope=lspinstall || true
  npm install bash-language-server@latest
  ]],
  uninstall_script = nil -- can be omitted
})
```

Make sure to do this before you call `require'lspinstall'.setup()`.

Note: **don't** replace the `/` with a `.` in the `require` calls above ([see here if you're interested why](https://github.com/kabouzeid/nvim-lspinstall/issues/14)).

## Lua API

- `require'lspinstall'.setup()`

- `require'lspinstall'.installed_servers()`

- `require'lspinstall'.install_server(<lang>)`
- `require'lspinstall'.post_install_hook`
- `require'lspinstall'.reinstall_server(<lang>)`

- `require'lspinstall'.uninstall_server(<lang>)`
- `require'lspinstall'.post_uninstall_hook`

- `require'lspinstall/servers'`

- `require'lspinstall/util'.extract_config(<lspconfig-name>)`
