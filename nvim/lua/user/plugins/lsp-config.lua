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

		-- Configure LSP servers using the new vim.lsp.config API
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
		})

		vim.lsp.config("gopls", {
			capabilities = capabilities,
		})

		vim.lsp.config("pyright", {
			capabilities = capabilities,
		})

		vim.lsp.config("intelephense", {
			commands = {
				IntelephenseIndex = {
					function()
						vim.lsp.buf.execute_command({ command = "intelephense.index.workspace" })
					end,
				},
			},
			capabilities = capabilities,
		})

		vim.lsp.config("vue_ls", {
			filetypes = { "vue", "typescript" },
			capabilities = capabilities,
		})

		vim.lsp.config("ts_ls", {
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

		vim.lsp.config("tailwindcss", {
			capabilities = capabilities,
			filetypes = { "templ", "astro", "javascript", "typescript", "react", "vue", "html", "css", "scss", "less" },
		})

		vim.lsp.config("jsonls", {
			capabilities = capabilities,
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
				},
			},
		})

		vim.lsp.config("templ", {
			capabilities = capabilities,
		})

		vim.lsp.config("html", {
			capabilities = capabilities,
			filetypes = { "html", "templ" },
		})

		vim.lsp.config("htmx", {
			capabilities = capabilities,
			filetypes = { "html", "templ" },
		})

		vim.lsp.config("ruby_lsp", {
			capabilities = capabilities,
		})

		-- Enable LSP servers
		vim.lsp.enable("lua_ls")
		vim.lsp.enable("gopls")
		vim.lsp.enable("pyright")
		vim.lsp.enable("intelephense")
		vim.lsp.enable("vue_ls")
		vim.lsp.enable("ts_ls")
		vim.lsp.enable("tailwindcss")
		vim.lsp.enable("jsonls")
		vim.lsp.enable("templ")
		vim.lsp.enable("html")
		vim.lsp.enable("htmx")
		vim.lsp.enable("ruby_lsp")

		vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
		vim.keymap.set("n", "<Leader>d", vim.diagnostic.open_float, {})
		vim.keymap.set("n", "gd", ":Telescope lsp_definitions<CR>", {})
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
		vim.keymap.set("n", "gi", ":Telescope lsp_implementations<CR>", {})
		vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>", {})
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {})
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {})

		vim.diagnostic.config({
			float = {
				source = "if_many",
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.INFO] = "",
					[vim.diagnostic.severity.HINT] = "",
				},
			},
		})
	end,
}
