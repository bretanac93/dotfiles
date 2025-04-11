local set = vim.opt

set.expandtab = true
set.shiftwidth = 2
set.tabstop = 2
set.softtabstop = 2
set.relativenumber = true
set.signcolumn = "yes:2"
set.clipboard = "unnamedplus"
set.undofile = true
set.wildmode = "longest:full,full"
set.completeopt = "menuone,longest,preview"
set.updatetime = 100
set.redrawtime = 10000

vim.cmd([[
augroup kitty_mp
    autocmd!
    au VimLeave * :silent !kitty @ set-spacing padding=20 margin=10
    au VimEnter * :silent !kitty @ set-spacing padding=0 margin=0
augroup END
]])
