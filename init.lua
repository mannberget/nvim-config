local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

opt.compatible = false              -- some vi-compatibility stuff
opt.timeoutlen = 300
opt.guicursor = ""
opt.number = true                   -- show line numbers
opt.visualbell = true
opt.tabstop = 2                     -- number of spaces tabs count for
opt.softtabstop = 2
opt.shiftwidth = 2                  -- size of an indent
opt.expandtab = true
opt.hlsearch = true                 -- highlight searches
opt.incsearch = true
opt.scrolloff = 6
opt.laststatus = 2
opt.splitright = true               -- put new windows right of current
opt.smartindent = true              -- insert indents automatically
opt.termguicolors = true            -- true color support
opt.wrap = false
opt.encoding = "utf-8"
opt.cmdheight = 2
opt.wildmenu = true
opt.undofile = true
g.mapleader = " "

opt.path:append({'.', '**'})

vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
  highlight link markdownError NONE
]]

-- restore position in file
vim.cmd [[
  autocmd BufReadPost * if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
]]

vim.cmd("filetype plugin on")
g.netrw_banner = 0                  -- disable banner
g.netrw_altv = 1                    -- open splits to right
g.netrw_liststyle = 3               -- tree view
g.netrw_use_errorwindow = 0         -- popup window
g.netrw_sizestyle = "H"
g.netrw_list_hide = fn['netrw_gitignore#Hide']() .. [[,.git/]]
g.netrw_sort_sequence = [[[\/]$,*]] -- sort directories first
g.netrw_keepdir = 1                 -- keep main directory

-- Lua function to try :Rexplore and fallback to :Explore
function ToggleNetrw()
  local success = pcall(vim.cmd, "Rexplore")
  if not success or not (vim.api.nvim_buf_get_option(0, "filetype")=="netrw") then
    vim.cmd("Explore")
  end
end

vim.cmd("nnoremap <expr> <C-j> (winheight(0) / 5) . '<C-e>' . (winheight(0) / 5) . 'j'") -- small scroll down
vim.cmd("nnoremap <expr> <C-k> (winheight(0) / 5) . '<C-y>' . (winheight(0) / 5) . 'k'") -- small scroll down
map('n', '<leader>o', 'o<Esc>')                 -- insert newline from normal mode
map('n', '<leader>O', 'O<Esc>')                 -- insert newline from normal mode
map('n', '<leader>e', ':lua ToggleNetrw()<CR>', -- keep netrw position
    { silent = true })
map('n', '<leader>E', '<cmd>Explore<CR>',       -- force new netrw
    { silent = true })
map('v', '<leader>y', '"+y')                    -- yank into system clipboard
map('n', '<leader>y', '"+y')                    -- yank into system clipboard
map('v', '<leader>p', '"_dP')                   -- paste without overwrite register
map('n', '<leader>cc', 'gcc',                   -- comment line
    { noremap = false })
map('v', '<leader>c', 'gc',                     -- comment selection
    { noremap = false })
map("n", "<leader>ff", ":find *")               -- find files
map("n", "<leader>b", ":b ")                    -- find buffers
map("n", "<leader>sv", "<C-w>v")                -- split window vertically
map("n", "<leader>sh", "<C-w>s")                -- split window horizontally
map("n", "<leader>se", "<C-w>=")                -- make split windows equal width & height
map("n", "<leader>sx", ":close<CR>")            -- close current split window
map("n", "<leader>gt", "<C-]>")                 -- go to tag
map("n", "<leader>j", "<cmd>cnext<CR>")         -- next quickfix
map("n", "<leader>k", "<cmd>cprev<CR>")         -- prev quickfix
map("n", "<leader>l", "<cmd>cnfile<CR>")        -- next quickfix file
map("n", "<leader>h", "<cmd>cpfile<CR>")        -- prev quickfix file

-- TreeSitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "go", "javascript" },
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,
    additional_vim_regex_highlighting = false,
  },
}


-- LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufopts = { noremap=true, silent=true, buffer=bufnr }

    vim.keymap.set('n', 'gE', vim.diagnostic.goto_prev, { noremap=true, silent=true })
    vim.keymap.set('n', 'ge', vim.diagnostic.goto_next, { noremap=true, silent=true })

    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end

    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    end

    if client.supports_method('textDocument/rename') then
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    end

    if client.supports_method('textDocument/definition') then
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    end

    if client.supports_method('textDocument/references') then
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    end

    if client.supports_method('textDocument/formatting') then
      vim.keymap.set('n', '<leader>fo', vim.lsp.buf.format, bufopts)
    end

    if client.supports_method('textDocument/codeAction') then
      vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    end

    if client.supports_method('textDocument/implementation') then
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    end
  end,
})

-- Language Server Integrations:
require'lspconfig'.gopls.setup{}
require'lspconfig'.eslint.setup{}
require'lspconfig'.pylsp.setup{
  settings = {
    configurationSources = {"flake8"},
    pylsp = {
      plugins = {
        black = { enabled = false },
        pycodestyle = { enabled = false },
        pyflakes = { enabled = false },
        mccabe = { enabled = false },
        flake8 = { enabled = true },
        autopep8 = { enabled = true },
      }
    }
  }
}
require'lspconfig'.ccls.setup{
  init_options = {
    compilationDatabaseDirectory = "build";
    index = {
      threads = 0;
    };
  }
}


vim.opt.completeopt = {"menu", "menuone", "noselect"}
local cmp = require('cmp')
local cmp_types = require('cmp.types')
local source_mapping = {buffer = '[Buffer]', nvim_lsp = '[LSP]'}
cmp.setup({
  mapping = cmp.mapping.preset.insert({
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<C-f>'] = cmp.mapping.scroll_docs( 4),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-Space>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.abort()
        else
          cmp.complete()
        end
      end, { 'i', 's' }),
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'nvim_lsp_signature_help' },
  },
  {
      { name = 'path' },
      { name = 'buffer' },
  }),
  completion = {keyword_length = 2},
  formatting = {
      format = function(entry, vim_item)
          vim_item.menu = source_mapping[entry.source.name]
          return vim_item
      end,
  },
  experimental = {
    ghost_text = true,
  },
})
