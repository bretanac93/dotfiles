return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	main = "nvim-treesitter",
	build = ":TSUpdate",
	opts = {},
	init = function()
		local bigfile = require("user.bigfile")
		local ensure_installed = {
			"bash",
			"blade",
			"go",
			"html",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"php",
			"query",
			"vim",
			"vimdoc",
		}
		local group = vim.api.nvim_create_augroup("user-treesitter", { clear = true })
		local installed = require("nvim-treesitter").get_installed()
		local missing = vim.iter(ensure_installed)
			:filter(function(parser)
				return not vim.list_contains(installed, parser)
			end)
			:totable()

		if #missing > 0 then
			require("nvim-treesitter").install(missing)
		end

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
