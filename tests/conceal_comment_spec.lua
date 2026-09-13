local conceal_comment = require('conceal-comment')

-- <leader> is resolved against g:mapleader at the time a mapping is
-- created, so this must be set before any ftplugin runs and registers
-- <leader>cc below.
vim.g.mapleader = ' '

describe('find_html_comment_ranges', function()
  it('finds a single-line top-level comment', function()
    local lines = { '<!-- hello -->' }
    assert.are.same({ { 0, 0, 0, 14 } }, conceal_comment.find_html_comment_ranges(lines))
  end)

  it('finds an inline comment surrounded by text', function()
    local lines = { 'foo <!-- bar --> baz' }
    assert.are.same({ { 0, 4, 0, 16 } }, conceal_comment.find_html_comment_ranges(lines))
  end)

  it('finds multiple comments on one line', function()
    local lines = { '<!--a--> text <!--b-->' }
    assert.are.same({ { 0, 0, 0, 8 }, { 0, 14, 0, 22 } }, conceal_comment.find_html_comment_ranges(lines))
  end)

  it('finds a multi-line comment', function()
    local lines = { '<!--', 'multi', 'line', '-->' }
    assert.are.same({ { 0, 0, 3, 3 } }, conceal_comment.find_html_comment_ranges(lines))
  end)

  it('ignores comments inside fenced code blocks', function()
    local lines = { '```html', '<!-- inside fence -->', '```', '<!-- outside -->' }
    assert.are.same({ { 3, 0, 3, 16 } }, conceal_comment.find_html_comment_ranges(lines))
  end)

  it('ignores comments inside tilde-fenced code blocks', function()
    local lines = { '~~~', '<!-- inside -->', '~~~' }
    assert.are.same({}, conceal_comment.find_html_comment_ranges(lines))
  end)

  it('returns no ranges when there are no comments', function()
    local lines = { '# Title', '', 'Some **bold** text.' }
    assert.are.same({}, conceal_comment.find_html_comment_ranges(lines))
  end)

  it('leaves an unterminated comment unconcealed', function()
    local lines = { 'text', '<!-- never closed' }
    assert.are.same({}, conceal_comment.find_html_comment_ranges(lines))
  end)
end)

describe('is_fence_delimiter', function()
  it('recognizes backtick fences', function()
    assert.is_true(conceal_comment.is_fence_delimiter('```'))
    assert.is_true(conceal_comment.is_fence_delimiter('```html'))
    assert.is_true(conceal_comment.is_fence_delimiter('  ```'))
  end)

  it('recognizes tilde fences', function()
    assert.is_true(conceal_comment.is_fence_delimiter('~~~'))
  end)

  it('rejects non-fence lines', function()
    assert.is_false(conceal_comment.is_fence_delimiter('plain text'))
    assert.is_false(conceal_comment.is_fence_delimiter('`inline code`'))
  end)
end)

describe('apply/clear/toggle', function()
  local bufnr

  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
  end)

  after_each(function()
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('conceals top-level comments and leaves fenced ones alone', function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      '<!-- meta -->',
      '```html',
      '<!-- fenced -->',
      '```',
    })

    conceal_comment.apply(bufnr)

    local ns = vim.api.nvim_get_namespaces()['html_comment_conceal']
    local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
    assert.are.equal(1, #marks)
    assert.are.equal(0, marks[1][2]) -- row of the top-level comment
  end)

  it('leaves a sign column mark on the concealed line by default', function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<!-- meta -->' })

    conceal_comment.apply(bufnr)

    local ns = vim.api.nvim_get_namespaces()['html_comment_conceal']
    local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
    assert.are.equal(1, #marks)
    assert.are.equal('· ', marks[1][4].sign_text) -- nvim pads sign_text to 2 cells
    assert.are.equal('Comment', marks[1][4].sign_hl_group)
  end)

  it('omits the sign when vim.g.conceal_comment_sign is false', function()
    vim.g.conceal_comment_sign = false
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<!-- meta -->' })

    conceal_comment.apply(bufnr)

    local ns = vim.api.nvim_get_namespaces()['html_comment_conceal']
    local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
    assert.are.equal(1, #marks)
    assert.is_nil(marks[1][4].sign_text)

    vim.g.conceal_comment_sign = nil
  end)

  it('clear removes all extmarks added by apply', function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<!-- meta -->' })
    conceal_comment.apply(bufnr)
    conceal_comment.clear(bufnr)

    local ns = vim.api.nvim_get_namespaces()['html_comment_conceal']
    local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
    assert.are.equal(0, #marks)
  end)

  it('toggle flips vim.b.html_comment_concealed and conceallevel', function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<!-- meta -->' })
    vim.api.nvim_set_current_buf(bufnr)

    conceal_comment.toggle(bufnr)
    assert.is_true(vim.b[bufnr].html_comment_concealed)
    assert.are.equal(2, vim.wo.conceallevel)

    conceal_comment.toggle(bufnr)
    assert.is_false(vim.b[bufnr].html_comment_concealed)
    assert.are.equal(0, vim.wo.conceallevel)
  end)
end)

describe('ftplugin', function()
  local bufnr

  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.bo[bufnr].filetype = 'markdown'
    -- `runtime! ftplugin/markdown.lua` would also pick up Neovim's own
    -- bundled ftplugin/markdown.lua, which errors on this filetype-less-at-
    -- source-time scratch buffer; load only our own file directly instead.
    dofile(vim.fn.getcwd() .. '/ftplugin/markdown.lua')
  end)

  after_each(function()
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('defines a :ConcealComment command that toggles concealing', function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<!-- meta -->' })

    vim.cmd('ConcealComment')
    assert.is_true(vim.b[bufnr].html_comment_concealed)

    vim.cmd('ConcealComment')
    assert.is_false(vim.b[bufnr].html_comment_concealed)
  end)

  it('maps <leader>cc to :ConcealComment by default', function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<!-- meta -->' })

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<leader>cc', true, false, true), 'x', false)

    assert.is_true(vim.b[bufnr].html_comment_concealed)
  end)
end)
