local M = {}

local ns = vim.api.nvim_create_namespace('html_comment_conceal')

function M.is_fence_delimiter(line)
  return line:match('^%s*```+') ~= nil or line:match('^%s*~~~+') ~= nil
end

-- Returns HTML comment ranges in `lines` (excluding fenced code blocks) as a
-- list of { start_row, start_col, end_row, end_col } (0-indexed, end
-- exclusive). Handles multi-line comments.
function M.find_html_comment_ranges(lines)
  local ranges = {}
  local in_fence = false
  local pending -- start position { row, col } of an open multi-line comment

  for i, line in ipairs(lines) do
    local row = i - 1

    if M.is_fence_delimiter(line) then
      in_fence = not in_fence
      pending = nil
    elseif not in_fence then
      local search_from = 1
      while true do
        if pending then
          local close_s, close_e = line:find('%-%->', search_from)
          if not close_s then
            break
          end
          table.insert(ranges, { pending[1], pending[2], row, close_e })
          pending = nil
          search_from = close_e + 1
        else
          local open_s = line:find('<!%-%-', search_from)
          if not open_s then
            break
          end
          local _, close_e = line:find('%-%->', open_s + 4)
          if close_e then
            table.insert(ranges, { row, open_s - 1, row, close_e })
            search_from = close_e + 1
          else
            pending = { row, open_s - 1 }
            break
          end
        end
      end
    end
  end

  return ranges
end

function M.clear(bufnr)
  bufnr = bufnr or 0
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

function M.apply(bufnr)
  bufnr = bufnr or 0
  M.clear(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for _, r in ipairs(M.find_html_comment_ranges(lines)) do
    vim.api.nvim_buf_set_extmark(bufnr, ns, r[1], r[2], {
      end_row = r[3],
      end_col = r[4],
      conceal = '',
    })
  end
end

function M.toggle(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.b[bufnr].html_comment_concealed = not vim.b[bufnr].html_comment_concealed

  if vim.b[bufnr].html_comment_concealed then
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = 'nc'
    M.apply(bufnr)
  else
    vim.wo.conceallevel = 0
    M.clear(bufnr)
  end
end

return M
