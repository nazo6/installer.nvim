local npm = require("lspinstall/helpers").npm

return {
  install_script = npm.install_script "vscode-langservers-extracted",
  default_config = {
    cmd = { "node", npm.bin_path "vscode-html-language-server", "--stdio" },
    filetypes = {
      -- html
      "aspnetcorerazor",
      "blade",
      "django-html",
      "edge",
      "ejs",
      "eruby",
      "gohtml",
      "haml",
      "handlebars",
      "hbs",
      "html",
      "html-eex",
      "jade",
      "leaf",
      "liquid",
      "markdown",
      "mdx",
      "mustache",
      "njk",
      "nunjucks",
      "php",
      "razor",
      "slim",
      "twig",
      -- mixed
      "vue",
      "svelte",
    },
    root_dir = require("lspconfig").util.root_pattern(".git", vim.fn.getcwd()),
    init_options = {
      provideFormatter = true,
    },
  },
}
