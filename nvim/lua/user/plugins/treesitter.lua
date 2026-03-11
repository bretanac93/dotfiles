return {
	{
		"nvim-treesitter/nvim-treesitter",
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local bigfile = require("user.bigfile")
			local config = require("nvim-treesitter.configs")
			config.setup({
				auto_install = true,
				highlight = {
					enable = true,
					disable = function(_, buf)
						return bigfile.is_large(buf)
					end,
				},
				indent = {
					enable = true,
					disable = function(_, buf)
						return bigfile.is_large(buf)
					end,
				},
			})
		end,
	},
}
