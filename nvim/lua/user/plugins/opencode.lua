return {
	"nickjvandyke/opencode.nvim",
	version = "*",
	keys = {
		{
			"<leader>oa",
			function()
				require("opencode").prompt("@this ")
			end,
			mode = { "n", "x" },
			desc = "Send selection to OpenCode",
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
		local opencode_port = tonumber(vim.env.OPENCODE_PORT or "")

		vim.g.opencode_opts = vim.tbl_deep_extend("force", vim.g.opencode_opts or {}, {
			server = {
				port = opencode_port,
				start = false,
				stop = false,
				toggle = false,
			},
		})
	end,
}
