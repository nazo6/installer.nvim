# installer.nvim
## About


## Setup

### Notice

- Some install scripts may not work with Powershell 7. In the case, please try running them in Powershell 5.

### Install

With `packer.nvim`

```lua
-- nvim-lspconfig is required
use { "nazo6/lspinstall.nvim",
  requires = {"neovim/nvim-lspconfig"}
}
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

- :ballot_box_with_check: : Not tested but there is script to install.
- :white_check_mark: : Should work.

| Name                   | Language Server                          | Win                     | Linux                   |
| ---------------------- | ---------------------------------------- | ----------------------- | ----------------------- |
| angularls              | Angular Language Service                 | :ballot_box_with_check: | :ballot_box_with_check: |
| bashls                 | bash-language-server                     | :ballot_box_with_check: | :ballot_box_with_check: |
| clojure_lsp            | clojure-lsp                              | :ballot_box_with_check: | :ballot_box_with_check: |
| cmake                  | cmake-language-server                    | :white_check_mark:      | :ballot_box_with_check: |
| cpp                    | clangd                                   | :ballot_box_with_check: | :ballot_box_with_check: |
| cssls                  | vscode-langservers-extracted             | :ballot_box_with_check: | :ballot_box_with_check: |
| dockerls               | docker-langserver                        | :ballot_box_with_check: | :ballot_box_with_check: |
| elixirls               | Elixir Language Server (elixir-ls)       | :ballot_box_with_check: | :ballot_box_with_check: |
| elmls                  | Elm Language Server (elm-ls)             | :ballot_box_with_check: | :ballot_box_with_check: |
| ember                  | Ember Language Server                    | :ballot_box_with_check: | :ballot_box_with_check: |
| forls                  | Fortran Language Server (fortls)         | :ballot_box_with_check: | :ballot_box_with_check: |
| gopls                  | gopls                                    | :ballot_box_with_check: | :ballot_box_with_check: |
| graphql                | GraphQL language service                 | :ballot_box_with_check: | :ballot_box_with_check: |
| hls                    | haskell-language-server                  | :ballot_box_with_check: | :ballot_box_with_check: |
| html                   | vscode-langservers-extracted             | :white_check_mark:      | :white_check_mark:      |
| intelephense           | intelephense                             | :ballot_box_with_check: | :ballot_box_with_check: |
| jdtls                  | Eclipse JDTLS with Lombok                |                         | :ballot_box_with_check: |
| jsonls                 | vscode-langservers-extracted             | :white_check_mark:      | :white_check_mark:      |
| kotlin_language_server | kotlin-language-server                   | :ballot_box_with_check: | :ballot_box_with_check: |
| texlab                 | texlab                                   | :white_check_mark:      | :ballot_box_with_check: |
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

Use `require'lspinstall'.register_server(name, config)` to register a config with an installer.
`name` is server name and there are helper function to create config.

### If nvim-lspconfig has a setting of the server

#### npm based servers
There is helper function to register npm based servers.

The following example provides an installer for bash-language-server.

```lua
require("lspinstall").register_server("bashls", require("lspinstall/helpers").npm.builder {
  install_package = "bash-language-server",
  lang = "bashls",
})
```

#### Others
If server is not a npm module, you will need to write the installation script manually.

On windows, the script will run in Powershell. Otherwise, it will be run in bash.

```lua
require("lspinstall").register_server("<server-name>", require("lspinstall/helpers").common.builder {
  lang = "<server-name>",
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
```

You can see more information in [template.lua](/lua/lspinstall/servers/template.lua). Or you can check the implementation in [helpers.lua](/lua/lspinstall/helpers.lua)

### If nvim-lspconfig don't have settings of the server
You can't use helper functions for now.
Please create settings manually.

Example:
```lua
require("lspinstall").register("<server-name>", {
  install_script = function()
    -- Function to return install script. Need to return different scripts for windows and Linux.
  end,
  lsp_config = function()
    -- Function to return lsp config. This is the same thing that is passed to `nvim-lspconfig`.
    return {
      default_config = {
        cmd = {}, 
      }
    }
  end,
})
```

Make sure to do this before you call `require'lspinstall'.setup()`.

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
