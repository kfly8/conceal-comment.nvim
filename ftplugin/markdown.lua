----------------------------------------------------
-- markdown settings
----------------------------------------------------

-- Toggle visibility of HTML comments (<!-- ... -->) with <leader>tc.
-- Comments inside fenced code blocks (``` ... ```) are left untouched.
--
-- Extmark conceal shares the window-local 'conceallevel' option, and
-- nvim-treesitter's markdown_inline/highlights.scm conceals emphasis
-- delimiters (**/*) by default. Enabling this feature would otherwise also
-- hide bold/italic markers, so that rule is stripped via
-- after/queries/markdown_inline/highlights.scm.

local conceal_comment = require('conceal-comment')

vim.keymap.set('n', '<leader>tc', function()
  conceal_comment.toggle()
end, {
  buffer = true,
  silent = true,
  desc = 'Toggle HTML comment visibility',
})

vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'InsertLeave' }, {
  buffer = 0,
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.b[bufnr].html_comment_concealed then
      conceal_comment.apply(bufnr)
    end
  end,
})
