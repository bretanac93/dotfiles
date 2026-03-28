-- Markdown preview

return {
	"toppair/peek.nvim",
	build = "deno task --quiet build:fast",
	cmd = {
		"PeekOpen",
		"PeekClose",
	},
	config = function()
		require("peek").setup({
			syntax = true,
			theme = "light",
			app = "browser",
		})

		vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
		vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
	end,
}
