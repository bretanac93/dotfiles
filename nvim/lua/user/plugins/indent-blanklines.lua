-- Indentation lines

return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {
    indent = {
      char = "┊",
    },
    scope = {
      show_start = false,
      show_end = false,
    },
    exclude = {
      filetypes = {
        "dashboard",
      },
    },
  },
}
