vim.g.mapleader = ','
vim.wo.foldmethod = "syntax"
vim.wo.cursorline = true
vim.wo.relativenumber = true
vim.wo.number = true

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.c", "*.h", "*.cpp", "*.hpp", "*.cc" },
	callback = function(ev)
		vim.lsp.start({ name = 'clangd-server', cmd = { 'clangd' } })
	end
})


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"folke/which-key.nvim",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 0
		end,
		opts = {
			key_labels = {
				["<space>"] = "<SPACE>",
				["<cr>"] = "<ENTER>",
				["<tab>"] = "<TAB>",
			},
			icons = {
				breadcrumb = "..",
				separator = "->",
				group = "+"
			}
		}
	},
	{
		"nvim-treesitter/nvim-treesitter"
	},
	{
		"kelly-lin/ranger.nvim",
		config = function()
			require("ranger-nvim").setup({ replace_netrw = true })
			vim.api.nvim_set_keymap("n", " f", "", {
				noremap = true,
				callback = function()
					require("ranger-nvim").open(true)
				end,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig"
	},
	{
		"smoka7/hop.nvim",
		version = "*",
		opts = {}
	},
	{
		'gen740/SmoothCursor.nvim',
		config = function()
			require('smoothcursor').setup()
		end
	},
	{
		'romgrk/barbar.nvim',
		init = function() vim.g.barbar_auto_setup = false end,
		opts = {
			modified = { button = 'M' },
			pinned = { button = '*', filename = true },
			icons = {
				button = 'x',
				filetype = {
					enabled = false,
				},
				separator = { left = '{', right = '}' },
				separator_at_end = false,
			}
		},
	},
	{
    		'willothy/moveline.nvim',
    		build = 'make',
	},
	"plan9-for-vimspace/acme-colors",
	"huyvohcmc/atlas.vim",
	'alligator/accent.vim',
	"ourway/vim-bruin",
	"andreypopp/vim-colors-plain",
})

local moveline = require('moveline')
vim.keymap.set('n', '<M-k>', moveline.up)
vim.keymap.set('n', '<M-j>', moveline.down)
vim.keymap.set('v', '<M-k>', moveline.block_up)
vim.keymap.set('v', '<M-j>', moveline.block_down)

local hop = require("hop")
local dirs = require("hop.hint").HintDirection

vim.keymap.set("n", "f", function()
	hop.hint_char1({ direction = dirs.AFTER_CURSOR, current_line_only = false })
end, { remap = true })

vim.keymap.set("n", "F", function()
	hop.hint_char1({ direction = dirs.BEFORE_CURSOR, current_line_only = false })
end, { remap = true })

vim.keymap.set("n", "?", function()
	hop.hint_patterns()
end, { remap = true })

vim.keymap.set("n", "#", hop.hint_words, { remap = true })

local bbopts = {noremap = true, silent = true}
local bbmap = vim.api.nvim_set_keymap

bbmap("n", "<Left>", "<Cmd>BufferPrevious<CR>", bbopts)
bbmap("n", "<Right>", "<Cmd>BufferNext<CR>", bbopts)
bbmap("n", "<S-Left>", "<Cmd>BufferMovePrevious<CR>", bbopts)
bbmap("n", "<S-Right>", "<Cmd>BufferMoveNext<CR>", bbopts)
bbmap("n", "<CR>", "<Cmd>BufferPick<CR>", bbopts)

hop.setup {
	multi_windows = true,
}


local wk = require("which-key")
wk.register({
	[" f"] = { "Pick File" }
})

local lspconfig = require("lspconfig")
lspconfig.clangd.setup {
	on_attach = on_attach,
	cmd = { "clangd", "--offset-encoding=utf-16" },
}

require 'lspconfig'.lua_ls.setup {}

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Goto declaration" })
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = "Goto definition" })
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover info" })
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = ev.buf, desc = "Goto implementation" })
		vim.keymap.set('n', '<space>w', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, { buffer = ev.buf, desc = "View workspace dirs" })
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition,
			{ buffer = ev.buf, desc = "Goto _type_ definition" })
		vim.keymap.set('n', '<space>r', vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename this" })
		vim.keymap.set('n', '<space>c', vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Do code action" })
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = ev.buf, desc = "List all references" })
		vim.keymap.set('n', '<space>F', function()
			vim.lsp.buf.format { async = true }
		end, { buffer = ev.buf, desc = "Format" })
	end,
})

local smth = require("smoothcursor")

smth.setup({
	cursor = "?",
	speed = 30,
	texthl = "SmoothCursor",
})

local autocmd = vim.api.nvim_create_autocmd

local curs_setup = function()
	local cols = {
		n = 'Green',
		v = 'Yellow',
		V = 'LightYellow',
		i = 'LightBlue',
	}

	local colour = cols[vim.fn.mode()]
	if colour == nil then
		colour = 'White'
	end

	vim.api.nvim_set_hl(0, 'SmoothCursor', { ctermfg = colour })
	vim.fn.sign_define('smoothcursor', { text = vim.fn.mode() })
end

autocmd({ 'ModeChanged' }, { callback = curs_setup })

curs_setup()

vim.cmd('colorscheme plain')
vim.api.nvim_set_hl(0, 'SmoothCursor', { fg = '#ffff00', ctermfg = 'Yellow' })
