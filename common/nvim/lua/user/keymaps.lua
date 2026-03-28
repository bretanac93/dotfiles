-- Leader is <space>
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Helper for common keymap opts
local map = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Normal mode mappings
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>Q", ":bufdo bdelete<CR>")
map("n", "[b", ":bprev<CR>")
map("n", "]b", ":bnext<CR>")
map("n", "<C-J>", ":m .+1<CR>==")
map("n", "<C-K>", ":m .-2<CR>==")

-- Visual mode mappings
map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "y", "myy`y")
map("v", "Y", "myY`y")
map("v", "p", '"_dP')
map("v", "<C-J>", ":m '>+1<CR>gv=gv")
map("v", "<C-K>", ":m '<-2<CR>gv=gv")

-- Insert mode mappings
map("i", ";;", "<Esc>A;<Esc>")
map("i", ",,", "<Esc>A,<Esc>")

-- Expr-based movement for wrapped lines
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
