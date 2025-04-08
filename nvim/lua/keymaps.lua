-- Leader is <space>
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- clear search highlights
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Close all open buffers
vim.keymap.set("n", "<leader>Q", ":bufdo bdelete<CR>")

-- Reselect visual block after indent/outdent
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Maintain the cursor position when yanking a visual selection.
vim.keymap.set("v", "y", "myy`y")
vim.keymap.set("v", "Y", "myY`y")

-- When text is wrapped, move by terminal rows, not lines, unless a count is provided.
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Paste replace visual selection without copying it.
vim.keymap.set("v", "p", '"_dP')

-- Easy insertion of a trailing ; or , from insert mode.
vim.keymap.set("i", ";;", "<Esc>A;<Esc>")
vim.keymap.set("i", ",,", "<Esc>A,<Esc>")

vim.keymap.set("n", "[b", ":bprev<CR>")
vim.keymap.set("n", "]b", ":bnext<CR>")

-- Move current line down
vim.keymap.set("n", "<C-J>", ":m .+1<CR>==", { noremap = true, silent = true })
-- Move current line up
vim.keymap.set("n", "<C-K>", ":m .-2<CR>==", { noremap = true, silent = true })

-- Move selected lines down
vim.keymap.set("v", "<C-J>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
-- Move selected lines up
vim.keymap.set("v", "<C-K>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
