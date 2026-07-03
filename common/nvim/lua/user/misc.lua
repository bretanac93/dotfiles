vim.cmd([[
  augroup FileTypeOverrides
    autocmd!
    autocmd TermOpen * setlocal nospell
  augroup END
]])

vim.api.nvim_create_autocmd("textyankpost", {
  desc = "When text is yanked, highlight the selection",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 100 })
  end,
})

-- tmux 3.7 mishandles synchronized-output frames (DECSET 2026), leaving stale
-- cells and erratic paints. Disable termsync inside tmux so nvim never wraps
-- its redraws in those markers; bare terminals keep the flicker-free default.
if vim.env.TMUX then
  vim.o.termsync = false
end
