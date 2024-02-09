vim.opt.termguicolors = true

vim.g.mapleader = ','

vim.wo.cursorline = true
vim.wo.relativenumber = true
vim.wo.number = true
vim.wo.linebreak = true
vim.wo.wrap = true

vim.o.tabstop = 4 -- \t is 4 chars wide
vim.o.expandtab = true -- tab key inserts spaces, not \t
vim.o.softtabstop = 4 -- 4 char width for space-tabs
vim.o.shiftwidth = 4 -- indenting tab width

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.c", "*.h", "*.cpp", "*.hpp", "*.cc" },
	callback = function(ev)
		vim.lsp.start({ name = 'clangd-server', cmd = { 'clangd', '--fallback-style=Microsoft' } })
	end
})

--vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
--    pattern = {"*.c", "*.h", "*.cpp", "*.hpp", "*.cc"},
--    callback = function(ev)
--        vim.lsp.start({
--            name = "ccls",
--            cmd = {"ccls"},
--            root_dir = vim.fs.dirname(vim.fs.find({"Makefile", "compile_commands.json"}, {upward = true})[1]),            
--        })
--    end
--})


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
			vim.api.nvim_set_keymap("n", "  ", "", {
				desc = "File Browser",
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
				separator = { left = '>', right = '<' },
				separator_at_end = false,
			}
		},
	},
	{
    		'willothy/moveline.nvim',
    		build = 'make',
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim"
		}
	},
    {
        "wellle/context.vim",
    },
	{
		"mcchrish/zenbones.nvim",
		dependencies = {"rktjmp/lush.nvim"},
	},  
	"plan9-for-vimspace/acme-colors",
	"huyvohcmc/atlas.vim",
	'alligator/accent.vim',
	"ourway/vim-bruin",
	"andreypopp/vim-colors-plain",
})

require("telescope").setup({
	pickers = {
		lsp_references = {theme = "cursor"},
		lsp_implementations = {theme = "cursor"},
		lsp_definitions = {theme = "cursor"},
		treesitter = {theme = "ivy"},
        buffers = {theme = "cursor"},
	}
})

local tele = require("telescope.builtin")
vim.keymap.set("n", " f", tele.find_files, {desc = "File Finder"})
vim.keymap.set("n", " g", tele.live_grep, {desc = "Live Grep"})
vim.keymap.set("n", " b", tele.buffers, {desc = "Tele buffers"})

vim.keymap.set("n", "gr", tele.lsp_references, {desc = "Show references"})
vim.keymap.set("n", "gd", tele.lsp_implementations, {desc = "Goto definition(s)"})
vim.keymap.set("n", "gD", tele.lsp_definitions, {desc = "Goto declaration(s)"})

vim.keymap.set("n", "gt", tele.treesitter, {desc = "Show treesitter"})

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

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		--vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Goto declaration" })
		--vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = "Goto definition" })
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover info" })
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = ev.buf, desc = "Goto implementation" })
		vim.keymap.set('n', '<space>w', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, { buffer = ev.buf, desc = "View workspace dirs" })
		vim.keymap.set('n', 'gC', vim.lsp.buf.type_definition,
			{ buffer = ev.buf, desc = "Goto _type_ definition" })
		vim.keymap.set('n', '<space>r', vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename this" })
		vim.keymap.set('n', '<space>c', vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Do code action" })
		vim.keymap.set('n', '<space>F', function()
			vim.lsp.buf.format { async = true }
		end, { buffer = ev.buf, desc = "Format" })
	end,
})

vim.opt.background = "light"
vim.cmd('colorscheme forestbones')

---- NEOVIDE STUFF ----

if vim.g.neovide then
    vim.o.guifont = "CaskaydiaCove NFM:h10"
    vim.g.neovide_cursor_animation_length = 0
end
