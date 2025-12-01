return {
	{
		"github/copilot.vim",
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		build = "make tiktoken",
		config = function()
			require("CopilotChat").setup({
				model = "claude-4.5-sonnet",
			})
		end,
	},
}
