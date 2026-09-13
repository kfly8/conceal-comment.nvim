vim.opt.rtp:prepend(vim.fn.getcwd())

local plenary_dir = os.getenv('PLENARY_DIR') or (vim.fn.stdpath('data') .. '/site/pack/deps/start/plenary.nvim')
vim.opt.rtp:append(plenary_dir)

vim.cmd('runtime plugin/plenary.vim')
