return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	main = "nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"blade",
			"go",
			"groovy",
			"html",
			"json",
			"kotlin",
			"lua",
			"markdown",
			"markdown_inline",
			"php",
			"query",
			"vim",
			"vimdoc",
		},
	},
	init = function()
		local bigfile = require("user.bigfile")
		local group = vim.api.nvim_create_augroup("user-treesitter", { clear = true })

		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			callback = function(args)
				if bigfile.is_large(args.buf) then
					return
				end

				pcall(vim.treesitter.start, args.buf)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
