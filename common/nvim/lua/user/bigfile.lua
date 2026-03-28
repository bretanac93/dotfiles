local M = {}

local uv = vim.uv or vim.loop

M.large_file_size = 512 * 1024
M.large_line_count = 5000
M.huge_file_size = 1024 * 1024
M.huge_line_count = 20000
M.minified_line_length = 300
M.minified_sample_size = 50
M.minified_ratio = 0.9

local function normalize_bufnr(bufnr)
  if bufnr == nil or bufnr == 0 then
    return vim.api.nvim_get_current_buf()
  end

  return bufnr
end

local function set_flag(bufnr, name, value)
  vim.b[bufnr][name] = value
end

local function get_path(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return nil
  end

  return name
end

function M.inspect_filesize(bufnr)
  bufnr = normalize_bufnr(bufnr)

  if not vim.api.nvim_buf_is_valid(bufnr) or vim.b[bufnr].bigfile_checked_fs then
    return
  end

  set_flag(bufnr, "bigfile_checked_fs", true)

  local path = get_path(bufnr)
  if not path then
    return
  end

  local stat = uv.fs_stat(path)
  if not stat or stat.type ~= "file" then
    return
  end

  set_flag(bufnr, "file_size", stat.size)

  if stat.size >= M.large_file_size then
    set_flag(bufnr, "bigfile", true)
  end

  if stat.size >= M.huge_file_size then
    set_flag(bufnr, "hugefile", true)
  end
end

function M.inspect_buffer(bufnr)
  bufnr = normalize_bufnr(bufnr)

  if not vim.api.nvim_buf_is_valid(bufnr) or vim.b[bufnr].bigfile_checked_buffer then
    return
  end

  set_flag(bufnr, "bigfile_checked_buffer", true)

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  set_flag(bufnr, "line_count", line_count)

  if line_count >= M.large_line_count then
    set_flag(bufnr, "bigfile", true)
  end

  if line_count >= M.huge_line_count then
    set_flag(bufnr, "hugefile", true)
  end

  if M.is_minified(bufnr) then
    set_flag(bufnr, "bigfile", true)
    set_flag(bufnr, "hugefile", true)
    set_flag(bufnr, "minified_file", true)
  end
end

function M.is_large(bufnr)
  bufnr = normalize_bufnr(bufnr)
  return vim.b[bufnr].bigfile == true
end

function M.is_huge(bufnr)
  bufnr = normalize_bufnr(bufnr)
  return vim.b[bufnr].hugefile == true
end

function M.is_minified(bufnr)
  bufnr = normalize_bufnr(bufnr)

  if vim.b[bufnr].minified_file == true then
    return true
  end

  local path = get_path(bufnr) or ""
  if path:match("%.min%.[cm]?js$") or path:match("%.min%.css$") then
    return true
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count == 0 then
    return false
  end

  local sample_size = math.min(line_count, M.minified_sample_size)
  local long_lines = 0

  for i = 1, sample_size do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1] or ""
    if #line >= M.minified_line_length then
      long_lines = long_lines + 1
    end
  end

  return sample_size >= 20 and (long_lines / sample_size) >= M.minified_ratio
end

function M.apply(bufnr)
  bufnr = normalize_bufnr(bufnr)

  if not M.is_large(bufnr) or vim.b[bufnr].bigfile_applied then
    return
  end

  set_flag(bufnr, "bigfile_applied", true)

  vim.opt_local.synmaxcol = 200
  vim.opt_local.spell = false

  if vim.bo[bufnr].syntax == "" and vim.bo[bufnr].filetype ~= "" then
    vim.bo[bufnr].syntax = vim.bo[bufnr].filetype
  end

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("syntax sync minlines=64")
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("user-bigfile", { clear = true })

  vim.api.nvim_create_autocmd({ "BufReadPre", "FileReadPre" }, {
    group = group,
    callback = function(args)
      M.inspect_filesize(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufReadPost", "FileReadPost", "BufWinEnter" }, {
    group = group,
    callback = function(args)
      M.inspect_filesize(args.buf)
      M.inspect_buffer(args.buf)
      M.apply(args.buf)
    end,
  })
end

return M
