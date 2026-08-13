--- Navigation helpers that paper over gaps in the pre-alpha kotlin_lsp.
---
--- `textDocument/implementation` comes back empty whenever the cursor sits on
--- an override: nothing overrides an override, so its sibling implementations
--- are only reachable through the supertype the member came from. The server
--- offers no way up -- `textDocument/definition` returns the override itself,
--- and `prepareTypeHierarchy` is advertised but answers with nothing -- so the
--- hop has to happen locally, off the syntax tree.

local M = {}

--- Positions of the supertype identifiers on the class/object enclosing the
--- cursor, e.g. the `Handler` in `class AuditHandler : Handler`.
---@param bufnr integer
---@return lsp.Position[]
local function supertype_positions(bufnr)
	local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })

	if not ok or not node then
		return {}
	end

	while node and node:type() ~= "class_declaration" and node:type() ~= "object_declaration" do
		node = node:parent()
	end

	if not node then
		return {}
	end

	local positions = {}

	for child in node:iter_children() do
		if child:type() == "delegation_specifier" then
			local pending = { child }

			while #pending > 0 do
				local current = table.remove(pending)

				if current:type() == "type_identifier" then
					local row, col = current:range()
					table.insert(positions, { line = row, character = col })
					pending = {}
				else
					for sub in current:iter_children() do
						if sub:named() then
							table.insert(pending, sub)
						end
					end
				end
			end
		end
	end

	return positions
end

---@param client vim.lsp.Client
---@param locations lsp.Location[]
---@param title string
local function show(client, locations, title)
	if #locations == 1 then
		return vim.lsp.util.show_document(locations[1], client.offset_encoding, { focus = true })
	end

	vim.fn.setqflist({}, " ", {
		title = title,
		items = vim.lsp.util.locations_to_items(locations, client.offset_encoding),
	})

	require("telescope.builtin").quickfix()
end

--- Ask for implementations at each position in turn, stopping at the first that
--- answers. Async throughout -- a cold monorepo can take seconds per request.
---@param client vim.lsp.Client
---@param bufnr integer
---@param positions lsp.Position[]
---@param index integer
---@param done fun(locations: lsp.Location[])
local function first_answer(client, bufnr, positions, index, done)
	if index > #positions then
		return done({})
	end

	local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
	params.position = positions[index]

	client:request("textDocument/implementation", params, function(err, result)
		if not err and result and not vim.tbl_isempty(result) then
			return done(vim.islist(result) and result or { result })
		end

		first_answer(client, bufnr, positions, index + 1, done)
	end, bufnr)
end

--- Implementations at the cursor, falling back to the enclosing type's
--- supertypes so that `gi` on an override finds its siblings.
function M.implementations()
	local builtin = require("telescope.builtin")
	local bufnr = vim.api.nvim_get_current_buf()
	local client = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/implementation" })[1]

	if not client or vim.bo[bufnr].filetype ~= "kotlin" then
		return builtin.lsp_implementations()
	end

	local cursor = vim.lsp.util.make_position_params(0, client.offset_encoding).position
	local positions = { cursor }

	vim.list_extend(positions, supertype_positions(bufnr))

	first_answer(client, bufnr, positions, 1, function(locations)
		if vim.tbl_isempty(locations) then
			return vim.notify("No implementations found", vim.log.levels.INFO)
		end

		show(client, locations, "LSP Implementations")
	end)
end

return M
