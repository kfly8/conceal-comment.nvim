; Override of nvim-treesitter's bundled markdown_inline highlights.
;
; This is a full replacement (no `;; extends` marker), copied from
; nvim-treesitter/queries/markdown_inline/highlights.scm with every
; `(#set! conceal ...)` rule removed: emphasis/code-span delimiters
; (**/*/`), link/image syntax ([text](url), ![alt](url), reference links),
; and HTML entity substitution. Without this, toggling 'conceallevel' for
; our own HTML comment concealing (ftplugin/markdown.lua) would also hide
; or rewrite all of that, since conceal is gated by the same window-local
; 'conceallevel' option.
;
; Applied via vim.treesitter.query.set() in lua/conceal-comment/init.lua,
; not relied on to load automatically through 'runtimepath'.

(code_span) @markup.raw @nospell

(emphasis) @markup.italic

(strong_emphasis) @markup.strong

(strikethrough) @markup.strikethrough

(shortcut_link
  (link_text) @nospell)

[
  (backslash_escape)
  (hard_line_break)
] @string.escape

(inline_link
  [
    "["
    "]"
    "("
    (link_destination)
    ")"
  ] @markup.link)

[
  (link_label)
  (link_text)
  (link_title)
  (image_description)
] @markup.link.label

((inline_link
  (link_destination) @_url) @_label
  (#set! @_label url @_url))

((image
  (link_destination) @_url) @_label
  (#set! @_label url @_url))

(image
  [
    "!"
    "["
    "]"
    "("
    (link_destination)
    ")"
  ] @markup.link)

(full_reference_link
  [
    "["
    "]"
    (link_label)
  ] @markup.link)

(collapsed_reference_link
  [
    "["
    "]"
  ] @markup.link)

(shortcut_link
  [
    "["
    "]"
  ] @markup.link)

[
  (link_destination)
  (uri_autolink)
  (email_autolink)
] @markup.link.url @nospell

((uri_autolink) @_url
  (#offset! @_url 0 1 0 -1)
  (#set! @_url url @_url))

(entity_reference) @nospell
