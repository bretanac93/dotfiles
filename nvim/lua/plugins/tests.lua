return {
	"vim-test/vim-test",
	keys = {
		{ "<Leader>tn", ":silent TestNearest<CR>" },
		{ "<Leader>tf", ":silent TestFile<CR>" },
		{ "<Leader>ts", ":silent TestSuite<CR>" },
		{ "<Leader>tl", ":silent TestLast<CR>" },
		{ "<Leader>tv", ":silent TestVisit<CR>" },
	},
	dependencies = { "voldikss/vim-floaterm" },
	config = function()
		vim.cmd([[
      function! FloatermStrategy(cmd)
        execute 'silent FloatermSend q'
        execute 'silent FloatermKill'
        execute 'FloatermNew! '.a:cmd.'| less -X'
      endfunction

      let g:test#custom_strategies = {'floaterm': function('FloatermStrategy')}
      let g:test#strategy = 'floaterm'
    ]])
	end,
}
