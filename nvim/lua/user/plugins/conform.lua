return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			go = { "goimports", "gofmt" },
			lua = { "stylua" },
			php = { "pint" },
			javascript = { "eslint_d", stop_after_first = true },
			typescript = { "eslint_d", stop_after_first = true },
			typescriptreact = { "eslint_d", stop_after_first = true },
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
		format_on_save = {
			lsp_format = "fallback",
			timeout_ms = 500,
		},
	},
}
