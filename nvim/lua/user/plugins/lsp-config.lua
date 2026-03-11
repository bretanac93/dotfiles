return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"b0o/schemastore.nvim",
	},
	event = "VeryLazy",
	config = function()
		local bigfile = require("user.bigfile")

		require("mason").setup({
			ui = {
				height = 0.8,
			},
		})

		require("mason-lspconfig").setup({ automatic_installation = true })

		local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

		local function with_defaults(config)
			return vim.tbl_deep_extend("force", {}, {
				capabilities = capabilities,
				flags = {
					debounce_text_changes = 150,
				},
			}, config or {})
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("user-lsp", { clear = true }),
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client then
					return
				end

				client.server_capabilities.semanticTokensProvider = nil

				if bigfile.is_huge(args.buf) and bigfile.is_minified(args.buf) then
					vim.schedule(function()
						vim.lsp.buf_detach_client(args.buf, client.id)
					end)
				end
			end,
		})

		-- Configure LSP servers using the new vim.lsp.config API
		vim.lsp.config("lua_ls", with_defaults())

		vim.lsp.config("gopls", with_defaults())

		vim.lsp.config("pyright", with_defaults())

		vim.lsp.config("intelephense", with_defaults({
			commands = {
				IntelephenseIndex = {
					function()
						vim.lsp.buf.execute_command({ command = "intelephense.index.workspace" })
					end,
				},
			},
		}))

		vim.lsp.config("vue_ls", with_defaults({
			filetypes = { "vue", "typescript" },
		}))

		vim.lsp.config("ts_ls", with_defaults({
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
			},
		}))

		vim.lsp.config("tailwindcss", with_defaults({
			filetypes = { "templ", "astro", "javascript", "typescript", "react", "vue", "html", "css", "scss", "less" },
		}))

		vim.lsp.config("jsonls", with_defaults({
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
				},
			},
		}))

		vim.lsp.config("templ", with_defaults())

		vim.lsp.config("html", with_defaults({
			filetypes = { "html", "templ" },
		}))

		vim.lsp.config("htmx", with_defaults({
			filetypes = { "html", "templ" },
		}))

		vim.lsp.config("ruby_lsp", with_defaults())

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
			update_in_insert = false,
			virtual_text = false,
			severity_sort = true,
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
