----------------------------------------------------
-- markdown settings
----------------------------------------------------

-- Toggle visibility of HTML comments (<!-- ... -->) with vim.g.conceal_comment_keymap
-- (defaults to <leader>cc). Comments inside fenced code blocks (``` ... ```)
-- are left untouched.
--
-- Extmark conceal shares the window-local 'conceallevel' option, and
-- nvim-treesitter's markdown_inline/highlights.scm conceals emphasis
-- delimiters (**/*) by default. Enabling this feature would otherwise also
-- hide bold/italic markers, so that rule is stripped via
-- after/queries/markdown_inline/highlights.scm.

local conceal_comment = require('conceal-comment')

-- Set vim.g.conceal_comment_keymap = false to disable the default mapping
-- (e.g. to bind require('conceal-comment').toggle() yourself), or to a
-- different lhs string to change it.
local keymap = vim.g.conceal_comment_keymap
if keymap == nil then
  keymap = '<leader>cc'
end

if keymap then
  vim.keymap.set('n', keymap, function()
    conceal_comment.toggle()
  end, {
    buffer = true,
    silent = true,
    desc = 'Toggle HTML comment visibility',
  })
end

vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'InsertLeave' }, {
  buffer = 0,
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.b[bufnr].html_comment_concealed then
      conceal_comment.apply(bufnr)
    end
  end,
})
