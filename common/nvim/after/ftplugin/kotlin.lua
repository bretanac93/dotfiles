local set = vim.opt_local

set.expandtab = true
set.shiftwidth = 4
set.tabstop = 4
set.softtabstop = 4

-- Prefer the project's gradle wrapper, fall back to a gradle on PATH.
local wrapper = vim.fs.find("gradlew", {
	upward = true,
	path = vim.fn.expand("%:p:h"),
})[1]

local gradle = wrapper and vim.fn.fnameescape(wrapper) or "gradle"

set.makeprg = gradle .. " --console=plain"

local function gradle_task(task)
	return function()
		vim.cmd("FloatermNew! " .. gradle .. " " .. task .. " | less -X")
	end
end

local function map(lhs, task, desc)
	vim.keymap.set("n", lhs, gradle_task(task), { buffer = true, desc = desc })
end

map("<Leader>kb", "build", "Gradle build")
map("<Leader>kc", "compileKotlin", "Gradle compileKotlin")
map("<Leader>kr", "run", "Gradle run")
map("<Leader>kk", "clean build", "Gradle clean build")
