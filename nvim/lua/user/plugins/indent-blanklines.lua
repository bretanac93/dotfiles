-- Indentation lines

return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  config = function(_, opts)
    local bigfile = require("user.bigfile")
    local ibl = require("ibl")

    ibl.setup(opts)

    vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
      group = vim.api.nvim_create_augroup("user-ibl", { clear = true }),
      callback = function(args)
        if not bigfile.is_large(args.buf) then
          return
        end

        ibl.setup_buffer(args.buf, {
          enabled = false,
          scope = {
            enabled = false,
          },
        })
      end,
    })
  end,
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
