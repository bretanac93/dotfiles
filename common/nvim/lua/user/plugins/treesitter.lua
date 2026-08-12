local ensure_installed = {
	"bash",
	"blade",
	"go",
	"groovy",
	"html",
	"java",
	"json",
	"kotlin",
	"lua",
	"markdown",
	"markdown_inline",
	"php",
	"properties",
	"query",
	"vim",
	"vimdoc",
	"xml",
	"yaml",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")

		ts.setup()

		-- The `main` branch dropped `ensure_installed` from setup(), so anything
		-- missing has to be installed by hand.
		local installed = require("nvim-treesitter.config").get_installed("parsers")

		local missing = vim.tbl_filter(function(lang)
			return not vim.tbl_contains(installed, lang)
		end, ensure_installed)

		if #missing > 0 then
			ts.install(missing)
		end
	end,
	init = function()
		local bigfile = require("user.bigfile")
		local group = vim.api.nvim_create_augroup("user-treesitter", { clear = true })

		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			callback = function(args)
				if vim.bo[args.buf].buftype ~= "" or not vim.bo[args.buf].modifiable then
					return
				end

				if vim.api.nvim_buf_get_name(args.buf) == "" then
					return
				end

				if bigfile.is_large(args.buf) then
					return
				end

				pcall(vim.treesitter.start, args.buf)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
