return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		keys = {
			{
				"<leader><leader>",
				function()
					require("telescope.builtin").find_files()
				end,
			},
			{
				"<leader>fg",
				function()
					require("telescope.builtin").live_grep()
				end,
			},
			{
				"<leader>fb",
				function()
					require("telescope.builtin").buffers()
				end,
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			local telescope = require("telescope")

			telescope.setup({
				pickers = {
					find_files = {
						theme = "dropdown",
					},
					live_grep = {
						theme = "dropdown",
					},
					buffers = {
						theme = "dropdown",
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			telescope.load_extension("ui-select")
		end,
	},
}
