local vim = vim

local Plug = vim.fn['plug#']

vim.call('plug#begin')
-- Autocompletion of code
Plug('https://github.com/hrsh7th/cmp-buffer')
Plug('https://github.com/hrsh7th/cmp-nvim-lsp')
Plug('https://github.com/hrsh7th/cmp-nvim-lsp-signature-help')
Plug('https://github.com/hrsh7th/cmp-nvim-lua')
Plug('https://github.com/hrsh7th/cmp-path')
Plug('https://github.com/hrsh7th/cmp-vsnip')
Plug('https://github.com/hrsh7th/nvim-cmp')
Plug('https://github.com/hrsh7th/vim-vsnip')
Plug('https://github.com/L3MON4D3/LuaSnip', {['tag'] = 'v2.*', ['do'] = 'make install_jsregexp'})
-- C#
Plug('https://github.com/OmniSharp/omnisharp-vim')
-- Programmer Utilities
Plug('https://github.com/mfussenegger/nvim-dap')
Plug('https://github.com/neovim/nvim-lspconfig')
Plug('https://github.com/williamboman/mason.nvim')
Plug('https://github.com/williamboman/mason-lspconfig.nvim')
-- Rust
Plug('https://github.com/simrat39/rust-tools.nvim')
Plug('https://github.com/alx741/vim-rustfmt')
-- Themes
Plug('https://github.com/folke/tokyonight.nvim')
-- Utilities
Plug('https://github.com/pocco81/auto-save.nvim')
Plug('https://github.com/ggandor/leap.nvim')
Plug('https://github.com/nvim-treesitter/nvim-treesitter', {['do'] = ':TSUpdate'})
Plug('https://github.com/nvim-lua/plenary.nvim')
Plug('https://github.com/nvim-telescope/telescope-fzf-native.nvim', {['do'] = 'make' })
Plug('https://github.com/nvim-telescope/telescope.nvim')
Plug('https://github.com/nvim-telescope/telescope-file-browser.nvim')
Plug('https://github.com/lewis6991/gitsigns.nvim')
Plug('https://github.com/lukas-reineke/indent-blankline.nvim')
Plug('https://github.com/windwp/nvim-autopairs')
Plug('https://github.com/windwp/nvim-ts-autotag')
Plug('https://github.com/numToStr/Comment.nvim')
Plug('https://github.com/rafamadriz/friendly-snippets')
Plug('https://github.com/godlygeek/tabular')
Plug('https://github.com/matze/vim-move')
Plug('https://github.com/tpope/vim-repeat')
Plug('https://github.com/tpope/vim-surround')
Plug('https://github.com/tpope/vim-speeddating')
Plug('https://github.com/mattn/emmet-vim')
Plug('https://github.com/nickspoons/vim-sharpenup')
Plug('https://github.com/dense-analysis/ale')
Plug('https://github.com/junegunn/fzf')
Plug('https://github.com/junegunn/fzf.vim')
Plug('https://github.com/prabirshrestha/asyncomplete.vim')
Plug('https://github.com/itchyny/lightline.vim')
Plug('https://github.com/maximbaz/lightline-ale')
Plug('https://github.com/nvim-tree/nvim-web-devicons')

vim.call('plug#end')

-- Enable syntax highlighting
vim.cmd('syntax enable')

-- Enable filetype detection
vim.cmd('filetype plugin indent on')

local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})

-- LSP Diagnostics Options Setup 
local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = ''
  })
end

sign({name = 'DiagnosticSignError', text = ''})
sign({name = 'DiagnosticSignWarn', text = ''})
sign({name = 'DiagnosticSignHint', text = ''})
sign({name = 'DiagnosticSignInfo', text = ''})

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = true,
    underline = true,
    severity_sort = false,
    float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})

--Set completeopt to have a better completion experience
-- :help completeopt
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force to select one from the menu
-- shortness: avoid showing extra messages when using completion
-- updatetime: set updatetime for CursorHold
vim.opt.completeopt = {'menuone', 'noselect', 'noinsert'}
vim.opt.shortmess = vim.opt.shortmess + { c = true}
vim.api.nvim_set_option('updatetime', 300) 

-- Fixed column for diagnostics to appear
-- Show autodiagnostic popup on cursor hover_range
-- Goto previous / next diagnostic warning / error 
-- Show inlay_hints more frequently 
vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

-- Completion Plugin Setup
local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },
  -- Installed sources:
  sources = {
    { name = 'path' },                              -- file paths
    { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
    { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
    { name = 'buffer', keyword_length = 2 },        -- source current buffer
    { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip 
    { name = 'calc'},                               -- source for math calculation
  },
  window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
  },
  formatting = {
      fields = {'menu', 'abbr', 'kind'},
      format = function(entry, item)
          local menu_icon ={
              nvim_lsp = 'λ',
              vsnip = '⋗',
              buffer = 'Ω',
              path = '🖫',
          }
          item.menu = menu_icon[entry.source.name]
          return item
      end,
  },
})

vim.opt.showmode = false

vim.cmd('colorscheme tokyonight-storm')

require("mason").setup()
require("mason-lspconfig").setup()
require("lspconfig").lua_ls.setup {}
require("lspconfig").rust_analyzer.setup {}
require('nvim-treesitter.install').prefer_git = false
-- Treesitter Plugin Setup 
require('nvim-treesitter.configs').setup {
  ensure_installed = { "lua", "rust", "toml" },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting=false,
  },
  ident = { enable = true }, 
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  }
}

require('nvim-ts-autotag').setup()
require('nvim-autopairs').setup()
require('ibl').setup()
require('leap').create_default_mappings()
require('Comment').setup()
require('rust-tools').setup()

require('telescope').setup {
  extensions = {
    file_browser = {
      hidden = true -- Make hidden files visible
    }
  }
}

-- Load the file_browser extension
require('telescope').load_extension('file_browser')

-- Define the key mapping for find_files
vim.api.nvim_set_keymap('n', '<Leader>ff', '<cmd>lua require("telescope.builtin").find_files()<CR>', { noremap = true, silent = true })

-- Settings
-- Treesitter folding 
-- vim.wo.foldmethod = 'expr'
-- vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'

vim.opt.filetype = "on"
vim.opt.encoding = "utf-8"
vim.opt.backspace = "indent,eol,start"
vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = -1
vim.opt.tabstop = 8
vim.opt.textwidth = 80
vim.opt.title = true
vim.opt.hidden = true
vim.opt.fixendofline = false
vim.opt.startofline = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.laststatus = 2
vim.opt.number = false
vim.opt.ruler = false
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.mouse = "a"
vim.opt.updatetime = 1000

-- Colorscheme preferences
vim.cmd [[
augroup ColorschemePreferences
  autocmd!
  autocmd ColorScheme * highlight Normal     ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight SignColumn ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight Todo       ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight link ALEErrorSign   WarningMsg
  autocmd ColorScheme * highlight link ALEWarningSign ModeMsg
  autocmd ColorScheme * highlight link ALEInfoSign    Identifier
augroup END
]]

-- Use truecolor in the terminal if supported
if vim.fn.has('termguicolors') == 1 then
  vim.opt.termguicolors = true
end

-- ALE settings
vim.g.ale_sign_error = '•'
vim.g.ale_sign_warning = '•'
vim.g.ale_sign_info = '·'
vim.g.ale_sign_style_error = '·'
vim.g.ale_sign_style_warning = '·'
vim.g.ale_linters = { cs = { 'OmniSharp' } }

-- Asyncomplete settings
vim.g.asyncomplete_auto_popup = 1
vim.g.asyncomplete_auto_completeopt = 0

-- Define the key mappings
vim.api.nvim_set_keymap('i', '<Tab>', 'pumvisible() ? "<C-n>" : "<Tab>"', { expr = true })
vim.api.nvim_set_keymap('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<S-Tab>"', { expr = true })
vim.api.nvim_set_keymap('i', '<CR>', 'pumvisible() ? asyncomplete#close_popup() : "<CR>"', { expr = true })

-- Sharpenup settings
vim.g.sharpenup_map_prefix = '<Space>os'
vim.g.sharpenup_statusline_opts = { Text = '%s (%p/%P)', Highlight = 0 }
vim.cmd [[
augroup OmniSharpIntegrations
  autocmd!
  autocmd User OmniSharpProjectUpdated,OmniSharpReady call lightline#update()
augroup END
]]

-- Lightline settings
vim.g.lightline = {
  colorscheme = 'tokyonight-storm',
  active = {
    right = {
      { 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' },
      { 'lineinfo' }, { 'percent' },
      { 'fileformat', 'fileencoding', 'filetype', 'sharpenup' }
    }
  },
  inactive = {
    right = { { 'lineinfo' }, { 'percent' }, { 'sharpenup' } }
  },
  component = {
    sharpenup = vim.fn['sharpenup#statusline#Build']()
  },
  component_expand = {
    linter_checking = 'lightline#ale#checking',
    linter_infos = 'lightline#ale#infos',
    linter_warnings = 'lightline#ale#warnings',
    linter_errors = 'lightline#ale#errors',
    linter_ok = 'lightline#ale#ok'
  },
  component_type = {
    linter_checking = 'right',
    linter_infos = 'right',
    linter_warnings = 'warning',
    linter_errors = 'error',
    linter_ok = 'right'
  }
}

vim.g.lightline_ale_indicator_checking = '•'
vim.g.lightline_ale_indicator_infos = '•'
vim.g.lightline_ale_indicator_warnings = '·'
vim.g.lightline_ale_indicator_errors = '·'
vim.g.lightline_ale_indicator_ok = '·'

-- OmniSharp settings
vim.g.OmniSharp_popup_position = 'peek'
if vim.fn.has('nvim') == 1 then
  vim.g.OmniSharp_popup_options = {
    winblend = 30,
    winhl = 'Normal:Normal,FloatBorder:ModeMsg',
    border = 'rounded'
  }
else
  vim.g.OmniSharp_popup_options = {
    highlight = 'Normal',
    padding = { 0 },
    border = { 1 },
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    borderhighlight = { 'ModeMsg' }
  }
end
vim.g.OmniSharp_popup_mappings = {
  sigNext = '<C-n>',
  sigPrev = '<C-p>',
  pageDown = { '<C-f>', '<PageDown>' },
  pageUp = { '<C-b>', '<PageUp>' }
}
if using_snippets then
  vim.g.OmniSharp_want_snippet = 1
end
vim.g.OmniSharp_highlight_groups = { ExcludedCode = 'NonText' }

-- Tab that's not on a newline or whitespace will perform auto completion
-- vim.api.nvim_set_keymap('i', '<Tab>', 'pumvisible() ? "<C-n>" : (vim.fn.match(getline("."), "[[:alnum:].-_#$]", col(".") - 2) ~= -1 ? "<C-x><C-o>" : "<Tab>")', { expr = true })

-- Handy dandy remaps
vim.api.nvim_set_keymap('n', '<C-o><C-u>', ':OmniSharpFindUsages<CR>', {})
vim.api.nvim_set_keymap('n', '<C-o><C-d>', ':OmniSharpGoToDefinition<CR>', {})
vim.api.nvim_set_keymap('n', '<C-o><C-p><C-d>', ':OmniSharpPreviewDefinition<CR>', {})
vim.api.nvim_set_keymap('n', '<C-o><C-r>', ':!dotnet run<CR>', {})
vim.api.nvim_set_keymap('n', '<C-o><C-t>', ':!dotnet test<CR>', {})

vim.api.nvim_set_keymap('n', '<Leader>fb', ':Telescope file_browser<CR>', { silent = true })
vim.api.nvim_set_keymap('v', '<Leader>y', ':w !clip<CR><CR>', { silent = true })

-- Map a key combination to call the Lua function
vim.api.nvim_set_keymap('n', '<leader>fb', ':lua require(\'telescope\').extensions.file_browser.file_browser({cwd = vim.fn.expand(\'%:p:h\')})<CR>', { noremap = true, silent = true })
-- Map <leader>y to yank to system clipboard
vim.api.nvim_set_keymap('n', '<leader>y', '"+y', { noremap = true, silent = true })
