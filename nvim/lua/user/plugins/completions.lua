return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp-signature-help",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"rafamadriz/friendly-snippets",
		"onsails/lspkind.nvim",
	},
	config = function()
		-- Set up nvim-cmp.
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")

		require("luasnip.loaders.from_vscode").lazy_load()

		local source_map = {
			buffer = "Buffer",
			nvim_lsp = "LSP",
			nvim_lsp_signature_help = "Signature",
			luasnip = "Snippet",
			path = "Path",
		}

		local ltrim = function(s)
			return s:match("^%s*(.*)")
		end

		cmp.setup({
			preselect = false,
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = lspkind.cmp_format({
					mode = "symbol",
					-- See: https://www.reddit.com/r/neovim/comments/103zetf/how_can_i_get_a_vscodelike_tailwind_css/
					before = function(entry, vim_item)
						-- Replace the 'menu' field with the kind and source
						vim_item.menu = "  "
							.. vim_item.kind
							.. " ("
							.. (source_map[entry.source.name] or entry.source.name)
							.. ")"
						vim_item.menu_hl_group = "SpecialComment"

						vim_item.abbr = ltrim(vim_item.abbr)

						if vim_item.kind == "Color" and entry.completion_item.documentation then
							local _, _, r, g, b =
								string.find(entry.completion_item.documentation, "^rgb%((%d+), (%d+), (%d+)")
							if r then
								local color = string.format("%02x", r)
									.. string.format("%02x", g)
									.. string.format("%02x", b)
								local group = "Tw_" .. color
								if vim.fn.hlID(group) < 1 then
									vim.api.nvim_set_hl(0, group, { fg = "#" .. color })
								end
								vim_item.kind_hl_group = group
								return vim_item
							end
						end

						return vim_item
					end,
				}),
			},
			mapping = cmp.mapping.preset.insert({
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				-- ["<Tab>"] = cmp.mapping(function(fallback)
				-- 	if cmp.visible() then
				-- 		cmp.select_next_item()
				-- 	elseif luasnip.expand_or_jumpable() then
				-- 		luasnip.expand_or_jump()
				-- 	elseif has_words_before() then
				-- 		cmp.complete()
				-- 	else
				-- 		fallback()
				-- 	end
				-- end, { "i", "s" }),
				-- ["<S-Tab>"] = cmp.mapping(function(fallback)
				-- 	if cmp.visible() then
				-- 		cmp.select_prev_item()
				-- 	elseif luasnip.jumpable(-1) then
				-- 		luasnip.jump(-1)
				-- 	else
				-- 		fallback()
				-- 	end
				-- end, { "i", "s" }),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
			}),
			experimental = {
				-- ghost_text = true,
			},
		})

		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})
	end,
}
