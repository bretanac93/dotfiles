return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      buffers = {
        follow_current_file = {
          enabled = true,
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = true,
          hide_gitignored = true,
          never_show = {
            ".git",
            ".DS_Store",
            ".idea",
          },
        },
      },
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "none",
        },
      },
    })
    vim.keymap.set("n", "<leader>n", ":Neotree filesystem toggle<CR>", {})
  end,
}
