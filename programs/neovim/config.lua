-- install lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- global options
vim.g.mapleader = ','
Languages = {
  {
    name = 'Lua',
    filetype = 'lua',
    formatter = 'lua:stylua',
    style = {
      tabstop = 2,
      shiftwidth = 2,
    },
    lsp = {
      server = 'lua_ls',
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          },
          diagnostics = {
            globals = { 'vim' },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file('', true),
          },
          telemetry = {
            enable = false,
          },
        },
      },
    },
  },
  {
    name = 'Go',
    filetype = 'go',
    formatter = nil,
    style = {
      tabstop = 4,
      shiftwidth = 4,
    },
    dap = {
      adapters = {
        delve = {
          type = 'server',
          port = '${port}',
          executable = {
            command = 'dlv',
            args = { 'dap', '-l', '127.0.0.1:${port}' },
          },
        }
      },
      configurations = {
        {
          type = 'delve',
          name = 'Debug',
          request = 'launch',
          program = '${file}'
        },
        {
          type = 'delve',
          name = 'Debug test', -- configuration for debugging test files
          request = 'launch',
          mode = 'test',
          program = '${file}'
        },
        -- works with go.mod packages and sub packages 
        {
          type = 'delve',
          name = 'Debug test (go.mod)',
          request = 'launch',
          mode = 'test',
          program = './${relativeFileDirname}'
        }
      },
    },
  },
  {
    name = 'Nix',
    filetype = 'nix',
    formatter = 'nix:nixpkgs_fmt',
    style = {
      tabstop = 2,
      shiftwidth = 2,
    },
    lsp = {
      server = 'nixd',
    },
  },
  {
    name = 'Python',
    filetype = 'py',
    formatter = 'python:black',
    style = {
      tabstop = 4,
      shiftwidth = 4,
      expandtab = false,
    },
    lsp = {
      server = 'pyright',
    },
  },
  {
    name = 'Latex',
    filetype = 'tex',
    --filetypes = {'tex', 'cls'}, -- @TODO: add support for multiple filetypes
    formatter = 'latex:latexindent',
    style = {
      tabstop = 4,
      shiftwidth = 4,
      expandtab = false,
    },
    lsp = {
      server = 'digestif',
    },
  },
}

-- setup functions
function Cfg_lspconfig()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
      -- Enable completion triggered by <c-x><c-o>
      -- @TODO: remove?
      --vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

      -- Buffer local mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      local opts = { buffer = ev.buf }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
      vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
      vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
      vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, opts)
      vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', '<space>f', function()
        vim.lsp.buf.format { async = true }
      end, opts)
    end,
  })
end

function Cfg_cmp()
  local has_words_before = function ()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
  end

  local cmp = require('cmp')
  local luasnip = require('luasnip')

  cmp.setup({
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),

      -- supertab-like mappings
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { 'i', 's' }),

      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'path' },
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'buffer', opt = { keyword_length = 5 } }, -- include words from buffer in completion
    })
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  local lspconfig = require('lspconfig')

  for _, language in pairs(Languages) do
    if language.lsp ~= nil then
      lspconfig[language.lsp.server].setup({
        capabilities = capabilities,
        settings = language.lsp.settings,
      })
    end
  end
end

function Cfg_dap()
  local dap = require('dap')

  for _, language in pairs(Languages) do
    if language.dap ~= nil then
      for name, adapter in pairs(language.dap.adapters) do
        dap.adapters[name] = adapter;
      end

      -- @TODO: might be able to remove temp var
      -- using `table.insert(list, pos, value)` syntax
      local configurations = {};
      for _, configuration in pairs(language.dap.configurations) do
        table.insert(configurations, configuration)
      end
      dap.configurations[language.filetype] = configurations
    end
  end
end

function Cfg_formatter()
  local formatter = require('formatter')

  local filetypes = {};
  for _, language in pairs(Languages) do
    local fmt = nil
    if language.formatter ~= nil then
			local filetype, name = string.match(language.formatter, '(.*):(.*)') -- split on :
			fmt = require('formatter.filetypes.' .. filetype)[name]
    else
      fmt = require('formatter.filetypes.' .. language.filetype)[0]
    end
    filetypes[language.name] = fmt
  end

  formatter.setup({
    filetype = filetypes,
  })
end

function Cfg_luasnip()
  require('luasnip.loaders.from_vscode').lazy_load()
end

function Cfg_lualine()
  local lualine = require('lualine')
  lualine.setup({
    options = {
      theme = 'auto'
    }
  })
end

function Cfg_telescope()
  local telescope = require('telescope')
  telescope.setup({})
end

function Cfg_vimtex()
  vim.g.vimtex_view_general_viewer = 'zathura'
  vim.g.vimtex_compiler_latexmk = {
    options = {
      '-verbose',
      '-file-line-error',
      '-synctex=1',
      '-interaction=nonstopmode',
      '-shell-escape',
    }
  }
end

function Cfg_rusttools()
  --[[ @TODO: once codelldb has been packaged, switch to using it
  local extension_path = 
  local codelldb_path =  extension_path .. 'adapter/codelldb'
  local liblldb_path =  extension_path .. 'adapter/codelldb'

  local rust_tools = require('rust-tools')
  rust_tools.setup({
    dap = {
      adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path)
    }
  })
  --]]

  require('rust-tools').setup()
end

function Cfg_neodev()
  local neodev  = require('neodev')
  local util = require('neodev.util')

  neodev.setup({
    override = function(root_dir, options)
      -- @TODO: set to $HOME/dev/dotnix/programs/neovim
      if util.has_file(root_dir, '/home/mib/dev/dotnix/programs/neovim') then
        options.enabled = true
        options.plugins = true
      end
    end,
  })
end

function Cfg_vimtex()
  vim.g.vimtex_view_general_viewer = 'zathura'
  vim.g.vimtex_compiler_latexmk = {
    options = {
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
        '-shell-escape',
    }
  }
end

-- plugin install
require('lazy').setup({
  'nvim-lua/plenary.nvim',
  'tpope/vim-sensible',
  --'sheerun/vim-polyglot',

  -- magic
  { 'neovim/nvim-lspconfig', config = Cfg_lspconfig },
  { 'mfussenegger/nvim-dap', config = Cfg_dap },
  { 'mhartington/formatter.nvim', config = Cfg_formatter },
  {
    'hrsh7th/nvim-cmp',
    config = Cfg_cmp,
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      {
        'L3MON4D3/LuaSnip',
        version = '1.*',
        build = 'make install_jsregexp',
        config = Cfg_luasnip,
        dependencies = {
          'saadparwaiz1/cmp_luasnip',
          --'rafamadriz/friendly-snippets',
        },
      },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.2',
    config = Cfg_telescope,
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- tools
  { 'iamcco/markdown-preview.nvim', build = 'cd app && yarn install', ft = 'markdown' },
  { 'lervag/vimtex', config = Cfg_vimtex, ft = 'tex' },
  { 'simrat39/rust-tools.nvim', config = Cfg_rusttools, ft = 'rust' },
  { 'folke/neodev.nvim', config = Cfg_neodev, ft = 'lua' },
  { 'lervag/vimtex', config = Cfg_vimtex, ft = { 'tex', 'cls' } },

  -- appearance
  {
    'nvim-lualine/lualine.nvim',
    config = Cfg_lualine,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  { 'marko-cerovac/material.nvim', lazy = true },
  { 'folke/tokyonight.nvim', lazy = true },
})

-- lsp
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- tabs
vim.opt.expandtab = true

-- keymaps
vim.keymap.set('', '<Leader>y', '"+y') -- yank to clipboard
vim.keymap.set('', '<Leader>p', '"+p') -- paste from clipboard
vim.keymap.set('', '<Leader>n', ':nohlsearch<CR>') -- disables highlight of previous search pattern

-- autocmds
local au_language_styles = vim.api.nvim_create_augroup('language_styles', { clear = true })
for _, language in pairs(Languages) do
  if language.style ~= nil then
    local style = language.style
    vim.api.nvim_create_autocmd('BufRead', {
      desc = 'Apply language-specific styles for ' .. language.name,
      pattern = '*.' .. language.filetype,
      group = au_language_styles,
      callback = function ()
        for key, value in pairs(style) do
          vim.o[key] = value
        end
      end
    })
  end
end

-- appearance
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = true

vim.g.material_style = 'deep ocean'
vim.cmd.colorscheme('material')

--[[
@TODO: telescope
@TODO: test completion & DAP with other languages (i.e. rust)
--]]
