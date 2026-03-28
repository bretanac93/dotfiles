local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazyrepo = "https://github.com/folke/lazy.nvim.git"

local function clone_lazy(extra_args)
  local clone_cmd = {
    "git",
    "clone",
    "--branch=stable",
  }

  vim.list_extend(clone_cmd, extra_args)
  vim.list_extend(clone_cmd, {
    lazyrepo,
    lazypath,
  })

  vim.fn.system(clone_cmd)

  return vim.v.shell_error == 0
end

if not uv.fs_stat(lazypath .. "/lua/lazy/init.lua") then
  vim.fn.mkdir(vim.fs.dirname(lazypath), "p")

  if not clone_lazy({ "--filter=blob:none" }) then
    vim.fn.delete(lazypath, "rf")

    if not clone_lazy({}) then
      error("failed to clone lazy.nvim from " .. lazyrepo)
    end
  end
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup('user.plugins', {
  rocks = {
    enabled = false,
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  install = {
    colorscheme = { "tokyonight", "habamax" },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
