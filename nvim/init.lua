vim.loader.enable()

require("user.options")
require("user.keymaps")
require("user.misc")
require("user.bigfile").setup()
require("user.opencode").setup()
require("user.lazy")
