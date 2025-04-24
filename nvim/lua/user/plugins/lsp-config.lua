return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"b0o/schemastore.nvim",
	},
	event = "VeryLazy",
	config = function()
		require("mason").setup({
			ui = {
				height = 0.8,
			},
		})

		require("mason-lspconfig").setup({ automatic_installation = true })

		local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

		local lspconfig = require("lspconfig")

		lspconfig.lua_ls.setup({
			capabilities = capabilities,
		})
		lspconfig.gopls.setup({
			capabilities = capabilities,
		})

		lspconfig.pyright.setup({
			capabilities = capabilities,
		})

		lspconfig.intelephense.setup({
			commands = {
				IntelephenseIndex = {
					function()
						vim.lsp.buf.execute_command({ command = "intelephense.index.workspace" })
					end,
				},
			},
			capabilities = capabilities,
		})

		lspconfig.volar.setup({
			filetypes = { "vue" },
			on_attach = function(client, bufnr)
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
			end,
			capabilities = capabilities,
		})

		lspconfig.ts_ls.setup({
			capabilities = capabilities,
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
			},
		})

		lspconfig.tailwindcss.setup({ capabilities = capabilities })

		lspconfig.jsonls.setup({
			capabilities = capabilities,
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
				},
			},
		})

		vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
		vim.keymap.set("n", "<Leader>d", vim.diagnostic.open_float, {})
		vim.keymap.set("n", "gd", ":Telescope lsp_definitions<CR>", {})
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
		vim.keymap.set("n", "gi", ":Telescope lsp_implementations<CR>", {})
		vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>", {})
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {})
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {})

		-- Sign configuration
		vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

		vim.diagnostic.config({
			float = {
				source = "if_many",
			},
		})
	end,
}
