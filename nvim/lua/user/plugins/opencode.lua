return {
	"nickjvandyke/opencode.nvim",
	version = "*",
	keys = {
		{
			"<leader>oa",
			function()
				require("opencode").ask("@this: ", { submit = true })
			end,
			mode = { "n", "x" },
			desc = "Ask OpenCode",
		},
		{
			"<leader>os",
			function()
				require("opencode").select()
			end,
			desc = "OpenCode actions",
		},
	},
	init = function()
		vim.g.opencode_opts = vim.tbl_deep_extend("force", vim.g.opencode_opts or {}, {
			server = {
				start = false,
				stop = false,
				toggle = false,
			},
		})
	end,
}
