require("nvim-autopairs").setup()
local cmp_autopairs = require("nvim-autopairs.completion.cmp")

local cmp = require("cmp")
local luasnip = require("luasnip")

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local function abort_and_fallback(...)
	return function(fallback)
		cmp.abort(arg)
		fallback()
	end
end

local function close_and_fallback(...)
	return function(fallback)
		cmp.close(arg)
		fallback()
	end
end

local function confirm_and_fallback(...)
	return function(fallback)
		cmp.confirm(arg)
		fallback()
	end
end

local select_behaviour = cmp.SelectBehavior.Select
local select_opts = { behaviour = select_behaviour }
local confirm_behaviour = cmp.ConfirmBehavior.Insert
-- local confirm_behaviour = cmp.ConfirmBehavior.Replace

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = {
		-- Specify `cmp.config.disable` if you want to remove a default mapping.
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
		["<C-Space>"] = cmp.mapping.disable,
		-- ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
		["<C-y>"] = cmp.config.disable,
		["<C-a>"] = cmp.mapping({
			i = abort_and_fallback(),
			c = close_and_fallback(),
		}),
		["<C-e>"] = cmp.mapping({
			i = confirm_and_fallback({ behaviour = confirm_behaviour, select = false }),
			c = confirm_and_fallback({ behaviour = confirm_behaviour, select = false }),
		}),
		-- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<CR>"] = cmp.mapping.confirm({ behaviour = confirm_behaviour, select = false }),

		-- Setup super tab
		["<Tab>"] = cmp.mapping(function(fallback)
			if luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif cmp.visible() then
				cmp.select_next_item(select_opts)
			elseif has_words_before() then
				cmp.complete()
			else
				-- The fallback function sends an already mapped key.
				-- In this case, it's probably <Tab>
				fallback()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			elseif cmp.visible() then
				cmp.select_prev_item(select_opts)
			else
				fallback()
			end
		end, { "i", "s" }),

		["<Up>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				local entry = cmp.get_selected_entry()
				if not entry then
					fallback()
				else
					cmp.select_prev_item(select_opts)
				end
			else
				fallback()
			end
		end, { "i", "s" }),

		["<Down>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				local entry = cmp.get_selected_entry()
				if not entry then
					fallback()
				else
					cmp.select_next_item(select_opts)
				end
			else
				fallback()
			end
		end, { "i", "s" }),
	},

	-- IMPORTANT: The order of the sources is important. It establishes priority between source candidates
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer", keyword_length = 4 },
		{ name = "path" },
		{ name = "luasnip" },
	}),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
if false then
	cmp.setup.cmdline("/", {
		sources = {
			{ name = "buffer" },
		},
	})
end

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline", keyword_length = 3 },
	}),
})

-- Fix for nvim-autopair
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
