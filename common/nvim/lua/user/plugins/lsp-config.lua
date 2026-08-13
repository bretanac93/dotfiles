return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"b0o/schemastore.nvim",
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local bigfile = require("user.bigfile")

		require("mason").setup({
			ui = {
				height = 0.8,
			},
		})

		require("mason-lspconfig").setup({
			automatic_installation = true,
			ensure_installed = {
				"groovyls",
				"kotlin_lsp",
			},
		})

		local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

		-- On the JVM, `textDocument/references` for an interface member returns
		-- call sites only -- the overrides come back from
		-- `textDocument/implementation` instead. A method with implementors but
		-- no callers therefore answers with just its own declaration, which
		-- Telescope drops because it sits on the cursor line, leaving you with
		-- "No LSP References found". Fall back to implementations in that case.
		local function references_or_implementations()
			local builtin = require("telescope.builtin")
			local bufnr = vim.api.nvim_get_current_buf()

			local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/references" })

			if #clients == 0 then
				return builtin.lsp_references({ include_current_line = true })
			end

			local params = function(client)
				local position = vim.lsp.util.make_position_params(0, client.offset_encoding)
				position.context = { includeDeclaration = false }
				return position
			end

			vim.lsp.buf_request_all(bufnr, "textDocument/references", params, function(results)
				for _, response in pairs(results) do
					if response.result and #response.result > 0 then
						return builtin.lsp_references({ include_current_line = true })
					end
				end

				require("user.kotlin").implementations()
			end)
		end

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

				-- Kotlin's treesitter grammar can't resolve types, so the JetBrains
				-- server's semantic tokens are the only source of real highlighting.
				if client.name ~= "kotlin_lsp" then
					client.server_capabilities.semanticTokensProvider = nil
				end

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

		vim.lsp.config("groovyls", with_defaults())

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

		-- The backend scatters its system and log dirs across random $TMPDIR
		-- paths, which makes the Gradle import log -- the only place that says
		-- why a module failed to import -- impossible to find. Pin them per
		-- project, and lift the stock 2G heap, which is thin for a large repo.
		local function kotlin_lsp_cmd(dispatchers, config)
			local root = config.root_dir or assert(vim.uv.cwd())
			local cache = vim.fs.joinpath(vim.fn.stdpath("cache"), "kotlin-lsp", vim.fn.sha256(root):sub(1, 16))

			vim.fn.mkdir(cache, "p")

			return vim.lsp.rpc.start({ "intellij-server", "--stdio" }, dispatchers, {
				env = {
					IJ_JAVA_OPTIONS = table.concat({
						"-Xmx6g",
						"-Didea.system.path=" .. vim.fs.joinpath(cache, "system"),
						"-Didea.config.path=" .. vim.fs.joinpath(cache, "config"),
						"-Didea.log.path=" .. vim.fs.joinpath(cache, "log"),
					}, " "),
				},
			})
		end

		-- root_markers come from lspconfig; the server ships its own JBR.
		vim.lsp.config("kotlin_lsp", with_defaults({
			cmd = kotlin_lsp_cmd,
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
		vim.lsp.enable("groovyls")
		vim.lsp.enable("pyright")
		vim.lsp.enable("intelephense")
		vim.lsp.enable("vue_ls")
		vim.lsp.enable("ts_ls")
		vim.lsp.enable("tailwindcss")
		vim.lsp.enable("jsonls")
		vim.lsp.enable("kotlin_lsp")
		vim.lsp.enable("templ")
		vim.lsp.enable("html")
		vim.lsp.enable("htmx")
		vim.lsp.enable("ruby_lsp")

		vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
		vim.keymap.set("n", "<Leader>d", vim.diagnostic.open_float, {})
		vim.keymap.set("n", "gd", ":Telescope lsp_definitions<CR>", {})
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
		vim.keymap.set("n", "gi", function()
			require("user.kotlin").implementations()
		end, { desc = "LSP implementations (hops up to supertypes)" })
		vim.keymap.set("n", "gr", references_or_implementations, { desc = "LSP references (falls back to impls)" })
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
