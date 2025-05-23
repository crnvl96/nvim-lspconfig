## Requirements

- [Lint requirements](#lint)
- Documentation is generated by `scripts/docgen.lua`.
  - Only works on linux and macOS

## Scope of nvim-lspconfig

The point of lspconfig is to provide the minimal configuration necessary for a server to act in compliance with the language server protocol. In general, if a server requires custom client-side commands or off-spec handlers, then the server configuration should be added *without* those in lspconfig and receive a dedicated plugin such as nvim-jdtls, nvim-metals, etc.

## Pull requests (PRs)

- Mark your pull request as "draft" until it's ready for review.
- Avoid cosmetic changes to unrelated files in the same commit.
- Use a **rebase workflow** for small PRs.
  - After addressing review comments, it's fine to rebase and force-push.

## Adding a server to lspconfig

New configs must meet these criteria (to avoid spam/quasi-marketing/vanity projects):

- GitHub Stars: The server repository should have at least 100 stars, or some other evidence (such as vscode marketplace downloads) that the LSP server is reasonably popular and is not spam/quasi-marketing/vanity projects.
- Provide some reference or evidence that the language targeted by the LSP server has an active user base.

This helps ensure that we only include actively maintained and widely used servers to provide a better experience for
the community.

To add a new language server, start with a minimal skeleton. See `:help lspconfig-new` and other configurations in `lsp/`.

When choosing a config name, convert dashes (`-`) to underscores (`_`). If the name of the server is a unique name (`pyright`, `clangd`) or a commonly used abbreviation (`zls`), prefer this as the server name. If the server instead follows the pattern x-language-server, prefer the convention `x_ls` (`jsonnet_ls`). 

`default_config` should include:

* `cmd`: a list which includes the executable name as the first entry, with arguments constituting subsequent list elements (`--stdio` is common).
  ```lua
  cmd = { 'typescript-language-server', '--stdio' }
  ```
* `filetypes`: list of filetypes that should activate this config.
* `root_markers`: a list of files that mark the root of the project.
    * See `:help lspconfig-new`.
    * See `vim.fs.root()`

An example for adding a new config `lsp/pyright.lua` is shown below:

```lua
local function organize_imports()
  -- executes lsp command. See `lsp/pyright.lua` for the full example.
end

---@brief
---
--- https://github.com/microsoft/pyright
---
--- `pyright`, a static type checker and language server for python
return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
  },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
      },
    },
  },
  on_attach = function()
    vim.api.nvim_buf_create_user_command(0, 'LspPyrightOrganizeImports', organize_imports, {})
  end,
}
```

## Commit style

Follow the Neovim core [commit message guidelines](https://github.com/neovim/neovim/blob/master/CONTRIBUTING.md#commit-messages). Examples:

* Adding a new config for "lua_ls":
  ```
  feat: lua_ls
  ```
* Fixing a bug for "lua_ls":
  ```
  fix(lua_ls): update root directory pattern

  Problem:
  Root directory incorrectly prefers "foo".

  Solution:
  Rearrange the root dir definition.
  ```

## Lint

PRs are checked with the following software:
- [luacheck](https://github.com/luarocks/luacheck#installation)
- [stylua](https://github.com/JohnnyMorganz/StyLua).
- [selene](https://github.com/Kampfkarren/selene)

To run the linter locally:

    make lint

If using nix, you can use `nix develop` to install these to a local nix shell.

## Generating docs

GitHub Actions automatically generates `configs.md`. Only modify
`scripts/docs_template.md` or the docstrings in the source of the config file.
Do not modify `configs.md` directly.

To preview the generated `configs.md` locally, run `scripts/docgen.lua` from
`nvim` (from the project root):

    nvim -R -Es +'set rtp+=$PWD' +'luafile scripts/docgen.lua'
