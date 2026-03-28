local M = {
  preview_mode = false,
  previewed_buffers = {},
  saved_ui = nil,
}

local function should_checktime(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].modified then
    return false
  end

  return vim.api.nvim_buf_get_name(bufnr) ~= ""
end

function M.reload_current_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not should_checktime(bufnr) then
    return
  end

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("checktime")
  end)
end

local function set_buffer_preview_mode(bufnr, enabled)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if enabled then
    vim.b[bufnr].opencode_preview = true
    M.previewed_buffers[bufnr] = true
    vim.diagnostic.disable(bufnr)

    if package.loaded["gitsigns"] then
      pcall(require("gitsigns").detach, bufnr)
    end

    if package.loaded["ibl"] then
      pcall(require("ibl").setup_buffer, bufnr, {
        enabled = false,
        scope = {
          enabled = false,
        },
      })
    end

    return
  end

  vim.b[bufnr].opencode_preview = false
  M.previewed_buffers[bufnr] = nil
  vim.diagnostic.enable(bufnr)

  if package.loaded["gitsigns"] then
    pcall(require("gitsigns").attach, bufnr)
  end

  if package.loaded["ibl"] and not require("user.bigfile").is_large(bufnr) then
    pcall(require("ibl").setup_buffer, bufnr, {
      enabled = true,
      scope = {
        enabled = true,
      },
    })
  end
end

function M.toggle_preview_mode()
  local bufnr = vim.api.nvim_get_current_buf()

  if not M.preview_mode then
    M.preview_mode = true
    M.saved_ui = {
      laststatus = vim.o.laststatus,
      showtabline = vim.o.showtabline,
    }

    vim.o.laststatus = 0
    vim.o.showtabline = 0
    set_buffer_preview_mode(bufnr, true)
    vim.notify("OpenCode preview mode enabled", vim.log.levels.INFO)
    return
  end

  M.preview_mode = false

  if M.saved_ui then
    vim.o.laststatus = M.saved_ui.laststatus
    vim.o.showtabline = M.saved_ui.showtabline
  end

  for previewed_bufnr, _ in pairs(M.previewed_buffers) do
    set_buffer_preview_mode(previewed_bufnr, false)
  end

  vim.notify("OpenCode preview mode disabled", vim.log.levels.INFO)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("user-opencode", { clear = true })

  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function(args)
      M.reload_current_buffer(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(args)
      if M.preview_mode then
        set_buffer_preview_mode(args.buf, true)
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(args)
      M.previewed_buffers[args.buf] = nil
    end,
  })

  vim.keymap.set("n", "<leader>or", function()
    M.reload_current_buffer()
    vim.cmd("edit")
  end, { desc = "Reload file from disk", silent = true })

  vim.keymap.set("n", "<leader>op", function()
    M.toggle_preview_mode()
  end, { desc = "Toggle OpenCode preview mode", silent = true })
end

return M
