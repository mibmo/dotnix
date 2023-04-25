-- install lazy.nvim
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

-- pre-lazy.nvim settings
vim.g.mapleader = ","

-- plugin configs
function cfg_lspconfig()
	local lspconfig = require('lspconfig')
	local lsp_defaults = lspconfig.util.default_config

	lsp_defaults.capabilities = vim.tbl_deep_extend(
		'force',
		lsp_defaults.capabilities,
		require('cmp_nvim_lsp').default_capabilities()
	)
end

function cfg_nvimcmp()
	vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

	require('luasnip.loaders.from_vscode').lazy_load()

	local cmp = require('cmp')
	local luasnip = require('luasnip')

	local select_opts = {behavior = cmp.SelectBehavior.Select}

	cmp.setup({
		snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end
		},
		sources = {
		{name = 'path'},
		{name = 'nvim_lsp', keyword_length = 1},
		{name = 'buffer', keyword_length = 3},
		{name = 'luasnip', keyword_length = 2},
		},
		window = {
		documentation = cmp.config.window.bordered()
		},
		formatting = {
		fields = {'menu', 'abbr', 'kind'},
		format = function(entry, item)
			local menu_icon = {
			nvim_lsp = 'λ',
			luasnip = '⋗',
			buffer = 'Ω',
			path = '🖫',
			}

			item.menu = menu_icon[entry.source.name]
			return item
		end,
		},
		mapping = {
		['<Up>'] = cmp.mapping.select_prev_item(select_opts),
		['<Down>'] = cmp.mapping.select_next_item(select_opts),

		['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
		['<C-n>'] = cmp.mapping.select_next_item(select_opts),

		['<C-u>'] = cmp.mapping.scroll_docs(-4),
		['<C-d>'] = cmp.mapping.scroll_docs(4),

		['<C-e>'] = cmp.mapping.abort(),
		['<C-y>'] = cmp.mapping.confirm({select = true}),
		['<CR>'] = cmp.mapping.confirm({select = false}),

		['<C-f>'] = cmp.mapping(function(fallback)
			if luasnip.jumpable(1) then
			luasnip.jump(1)
			else
			fallback()
			end
		end, {'i', 's'}),

		['<C-b>'] = cmp.mapping(function(fallback)
			if luasnip.jumpable(-1) then
			luasnip.jump(-1)
			else
			fallback()
			end
		end, {'i', 's'}),

		['<Tab>'] = cmp.mapping(function(fallback)
			local col = vim.fn.col('.') - 1

			if cmp.visible() then
			cmp.select_next_item(select_opts)
			elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
			fallback()
			else
			cmp.complete()
			end
		end, {'i', 's'}),

		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
			cmp.select_prev_item(select_opts)
			else
			fallback()
			end
		end, {'i', 's'}),
		},
	})
end

function cfg_peek()
	local peek = require('peek')

    vim.api.nvim_create_user_command('PeekOpen', peek.open, {})
    vim.api.nvim_create_user_command('PeekClose', peek.close, {})

	peek.setup({
		auto_load = false,
	})
end

function cfg_lualine()
	local lualine = require('lualine')

	lualine.setup {
		options = {
			theme = 'material'
		};
	}
end

------ @TODO: bunchhh of stuff to migrate from old config file
require("lazy").setup({
  'tpope/vim-sensible',
  'nvim-lua/plenary.nvim',
  'sbdchd/neoformat',

  -- lsp
  { 'neovim/nvim-lspconfig', config = cfg_lspconfig, lazy = true },
  { 'mfussenegger/nvim-dap', lazy = true },

  -- completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'L3MON4D3/LuaSnip' },
    config = cfg_nvimcmp
  },
	--[[
  {
    'L3MON4D3/LuaSnip',
		--build = 'make install_jsregexp',
    dependencies = { 'saadparwaiz1/cmp_luasnip', 'rafamadriz/friendly-snippets' },
    lazy = true
  },
	--]]

  -- convenience
  'monaqa/dial.nvim',

  -- looks
  'nvim-lualine/lualine.nvim',
  'marko-cerovac/material.nvim',
  'folke/tokyonight.nvim',

  -- syntax highlighting
  'sheerun/vim-polyglot',

  -- language-specific
  { 'folke/neodev.nvim', ft = 'lua' },
  { 'toppair/peek.nvim', config = cfg_peek, build = 'deno task --quiet build:fast', ft = 'markdown' }, -- markdown preview

  {} -- empty
})

--vim.opt.syntax = true;
vim.opt.number = true;
vim.opt.relativenumber = true;
vim.opt.wrap = false;

vim.opt.expandtab = true;
vim.opt.shiftwidth = 4;
vim.opt.tabstop = 4;

vim.keymap.set('', '<Leader>y', '"+y')
vim.keymap.set('', '<Leader>p', '"+p')

-- colorscheme
vim.g.material_style = "deep ocean"
vim.cmd.colorscheme('material')
