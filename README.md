# conceal-comment.nvim

[![CI](https://github.com/kfly8/conceal-comment.nvim/actions/workflows/ci.yml/badge.svg)](https://github.com/kfly8/conceal-comment.nvim/actions/workflows/ci.yml)

Toggle the visibility of HTML comments (`<!-- ... -->`) in Markdown buffers.

Useful for Markdown files that use HTML comments as frontmatter-like
metadata (e.g. `<!-- {"key":"cover","layout":"cover"} -->` per slide), where
the comments add visual noise while editing prose.

https://github.com/user-attachments/assets/3dec779a-5b06-45b1-957e-7dce46473bd9

## Features

- `:ConcealComment` toggles concealing of top-level HTML comments in the
  current Markdown buffer, also mapped to `<leader>cc` by default
  (configurable, see [Configuration](#configuration)).
- A concealed line is left blank rather than removed, with a small sign
  column mark (`·` by default) so it doesn't read as if the line were simply
  gone.
- Comments inside fenced code blocks (` ``` ... ``` `) are left untouched.
- Multi-line comments are supported.
- Ships query overrides that strip every other default `conceal` rule from
  nvim-treesitter's bundled `markdown`/`markdown_inline` highlights, so
  toggling this plugin's own conceal does not also hide `**bold**`/`*italic*`/
  `` `code` `` markers, fenced code block delimiters (` ``` `), or collapse
  `[text](url)` links (see [Why the query override?](#why-the-query-override)).

## Requirements

- Neovim with `nvim-treesitter` and the `markdown` parser installed.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ 'kfly8/conceal-comment.nvim' }
```

Don't lazy-load this on `ft = 'markdown'`: its query override (see below)
needs to be on `'runtimepath'` before nvim-treesitter's markdown_inline
highlighter first requests that query, and that race is not safe to leave to
load order between two `ft`-lazy plugins. The plugin itself is tiny, so
loading it at startup has no real cost; only its `ftplugin/markdown.lua`
(keymap, autocmd) is filetype-triggered as usual.

## Usage

Open a Markdown file and either run `:ConcealComment` or press `<leader>cc`
to hide/show HTML comments.

## Configuration

By default, the plugin defines a buffer-local `:ConcealComment` command in
every Markdown buffer and maps `<leader>cc` to it; nothing else needs to be
set.

Set `vim.g.conceal_comment_keymap` before the Markdown buffer loads (e.g. in
`init.lua`) to change or disable the default mapping. `:ConcealComment` (and
`require('conceal-comment').toggle()`) still work either way:

```lua
-- Use a different key
vim.g.conceal_comment_keymap = '<leader>hc'

-- Disable the default mapping entirely, and bind it yourself
vim.g.conceal_comment_keymap = false
vim.keymap.set('n', '<leader>x', '<Cmd>ConcealComment<CR>', { desc = 'Toggle HTML comment visibility' })
```

Set `vim.g.conceal_comment_sign` to change the sign column mark (default
`{ text = '·', hl_group = 'Comment' }`), or to `false` to leave concealed
lines fully blank:

```lua
vim.g.conceal_comment_sign = { text = '┊', hl_group = 'NonText' }

-- Or turn it off entirely
vim.g.conceal_comment_sign = false
```

## Why the query override?

Extmark `conceal` (and `:syn-conceal`) is gated by the single window-local
`'conceallevel'` option — there's no per-feature switch. nvim-treesitter's
bundled `markdown`/`markdown_inline` highlights already use `'conceallevel'`
to hide a bunch of raw syntax: emphasis/code-span delimiters (`**`, `*`,
`` ` ``), fenced code block delimiters and their language label, and
`[text](url)` link syntax down to just `text`. Since this plugin also drives
`'conceallevel'` to reveal/hide comments, without stripping those rules,
toggling comments would also toggle all of that.

`after/queries/markdown/highlights.scm` and
`after/queries/markdown_inline/highlights.scm` are full copies of
nvim-treesitter's queries with every `(#set! conceal ...)` rule removed
(highlighting/colors are kept as-is). Relying on `'runtimepath'` /
`after/` conventions to make these win over nvim-treesitter's own queries
turned out not to be reliable in practice — which file "wins" depends on
load order against nvim-treesitter for the same `(lang, "highlights")` pair,
and this plugin doesn't control that. So instead, `lua/conceal-comment/init.lua`
reads these files and installs them directly via `vim.treesitter.query.set()`
when the module loads, which takes effect immediately regardless of that
order.

## Development

Requires [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for tests,
plus [luacheck](https://github.com/mpeterv/luacheck) and
[stylua](https://github.com/JohnnyMorganz/StyLua) for linting/formatting.

```sh
make test       # run the test suite
make lint       # luacheck
make fmt-check  # stylua --check
make fmt        # stylua (writes changes)
```
