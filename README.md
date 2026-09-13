# conceal-comment.nvim

Toggle the visibility of HTML comments (`<!-- ... -->`) in Markdown buffers.

Useful for Markdown files that use HTML comments as frontmatter-like
metadata (e.g. `<!-- {"key":"cover","layout":"cover"} -->` per slide), where
the comments add visual noise while editing prose.

## Features

- `<leader>tc` toggles concealing of top-level HTML comments in the current
  Markdown buffer.
- Comments inside fenced code blocks (` ``` ... ``` `) are left untouched.
- Multi-line comments are supported.
- Ships an `after/queries/markdown_inline/highlights.scm` override that
  removes nvim-treesitter's default `emphasis_delimiter`/`code_span_delimiter`
  conceal rule, so toggling this plugin does not also hide `**bold**`/`*italic*`/
  `` `code` `` markers (see [Why the query override?](#why-the-query-override)).

## Requirements

- Neovim with `nvim-treesitter` and the `markdown` parser installed.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim), as a local plugin:

```lua
{
  dir = '~/src/github.com/kfly8/conceal-comment.nvim',
  ft = 'markdown',
}
```

## Usage

Open a Markdown file and press `<leader>tc` to hide/show HTML comments.

## Why the query override?

Extmark `conceal` (and `:syn-conceal`) is gated by the window-local
`'conceallevel'` option. nvim-treesitter's bundled
`markdown_inline/highlights.scm` already uses `'conceallevel'` to hide
emphasis/code-span delimiters (`**`, `*`, `` ` ``). Since this plugin also
drives `'conceallevel'` to reveal/hide comments, without the override,
toggling comments would also toggle those delimiters — making
`**bold**` flicker to `bold`. The bundled
`after/queries/markdown_inline/highlights.scm` is a full copy of
nvim-treesitter's query with just that one conceal rule removed.
