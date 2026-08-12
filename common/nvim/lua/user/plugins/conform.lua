return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{
			"<leader>gf",
			function()
				require("conform").format({
					async = true,
					lsp_format = "fallback",
				})
			end,
			desc = "Format buffer",
		},
	},
	opts = {
		formatters_by_ft = {
			go = { "goimports", "gofmt" },
			kotlin = { "ktlint" },
			lua = { "stylua" },
			python = { "black" },
			php = { "pint" },
			javascript = { "eslint_d", stop_after_first = true },
			typescript = { "eslint_d", stop_after_first = true },
			typescriptreact = { "eslint_d", stop_after_first = true },
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
		-- ktlint pays JVM startup on every run, so it needs a longer leash.
		format_on_save = function(bufnr)
			return {
				lsp_format = "fallback",
				timeout_ms = vim.bo[bufnr].filetype == "kotlin" and 3000 or 500,
			}
		end,
	},
}
