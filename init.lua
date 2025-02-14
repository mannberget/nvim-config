local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

require('statusline').setup{}

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
opt.cmdheight = 1
opt.wildmenu = true
opt.undofile = true
g.mapleader = " "

-- Toggle cursorline only on active window
vim.cmd [[
augroup CursorLine
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END
]]

vim.cmd [[
  colorscheme lunaperche
  highlight Normal guibg=none guifg=white
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
  highlight link markdownError NONE
]]

-- restore position in file
vim.cmd [[
  autocmd BufReadPost * if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
]]

-- Disable netrw
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

vim.cmd("nnoremap <expr> <C-j> (winheight(0) / 5) . '<C-e>' . (winheight(0) / 5) . 'j'") -- small scroll down
vim.cmd("nnoremap <expr> <C-k> (winheight(0) / 5) . '<C-y>' . (winheight(0) / 5) . 'k'") -- small scroll down
map('n', '<leader>o', 'o<Esc>')                 -- insert newline from normal mode
map('n', '<leader>O', 'O<Esc>')                 -- insert newline from normal mode
map("n", "-", "<CMD>Oil<CR>",           -- open oil
    { desc = "Open oil" })
map('v', '<leader>y', '"+y')                    -- yank into system clipboard
map('n', '<leader>y', '"+y')                    -- yank into system clipboard
map('v', '<leader>p', '"_dP')                   -- paste without overwrite register
map('n', '<leader>cc', 'gcc',                   -- comment line
    { noremap = false })
map('v', '<leader>c', 'gc',                     -- comment selection
    { noremap = false })
map("n", "<leader>ff",                          -- find files
  ":lua require'telescope.builtin'.find_files()<CR>",
  { silent = true })
map("n", "<leader>fb",                          -- find buffers
  ":lua require'telescope.builtin'.buffers()<CR>",
  { silent = true })
map("n", "<leader>fg",                          -- grep 
  ":lua require'telescope.builtin'.live_grep()<CR>",
  { silent = true })
map("n", "<leader>sv", "<C-w>v")                -- split window vertically
map("n", "<leader>sh", "<C-w>s")                -- split window horizontally
map("n", "<leader>se", "<C-w>=")                -- make split windows equal width & height
map("n", "<leader>sx", ":close<CR>")            -- close current split window
map("n", "<leader>gt", "<C-]>")                 -- go to tag
map("n", "<leader>j", "<cmd>cnext<CR>")         -- next quickfix
map("n", "<leader>k", "<cmd>cprev<CR>")         -- prev quickfix
map("n", "<leader>l", "<cmd>cnfile<CR>")        -- next quickfix file
map("n", "<leader>h", "<cmd>cpfile<CR>")        -- prev quickfix file
map("v", "<Tab>", ">gv")                        -- indent selection
map("v", "<S-Tab>", "<gv")                      -- unindent selection
map("n", "H", "^")                              -- go to beginning of line
map("n", "L", "$")                              -- go to end of line
map('n', '<leader>o', 'o<Esc>')                 -- insert newline from normal mode

map('n', '<C-l>',                           -- make split larger
  '<cmd>vertical resize +5<CR>')
map('n', '<C-h>',                           -- make split smaller
  '<cmd>vertical resize -5<CR>')

-- Telescope
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = require('telescope.actions').close,
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
        ["<C-s>"] = require('telescope.actions').toggle_selection,
        ["<C-u>"] = require('telescope.actions').preview_scrolling_up,
        ["<C-d>"] = require('telescope.actions').preview_scrolling_down,
      }
    }
  },
}

-- TreeSitter
require('nvim-treesitter.configs').setup {
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

require('oil').setup()

-- LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufopts = { noremap=true, silent=true, buffer=bufnr }

    vim.keymap.set('n', 'gE', vim.diagnostic.goto_prev, { noremap=true, silent=true })
    vim.keymap.set('n', 'ge', vim.diagnostic.goto_next, { noremap=true, silent=true })
    vim.keymap.set('n', '<leader>ge', function() vim.diagnostic.goto_next({
      severity = vim.diagnostic.severity.ERROR }) end, { noremap=true,
      silent=true })

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
lspconfig = require('lspconfig')
lspconfig.gopls.setup{}
lspconfig.pylsp.setup{
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
lspconfig.ccls.setup{
  init_options = {
    compilationDatabaseDirectory = "build";
    index = {
      threads = 0;
    };
  }
}
local root_pattern = require("lspconfig.util").root_pattern
lspconfig.eslint.setup{
  root_dir = root_pattern(
    ".eslintrc.js",
    "eslint.config.js",
    "node_modules",
    ".git"
  )
}

lspconfig.volar.setup {
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
  init_options = {
    typescript = {
      serverPath = "node_modules/typescript/lib",
      tsdk = "node_modules/typescript/lib",
      useProjectReferences = false,
    },
    vue = {
      hybridMode = false,
    },
  },
}


vim.opt.completeopt = {"menu", "menuone", "noselect"}
local cmp = require('cmp')
local cmp_types = require('cmp.types')
local source_mapping = {buffer = '[Buffer]', nvim_lsp = '[LSP]'}
cmp.setup({
  mapping = cmp.mapping.preset.insert({
      ['<C-n>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<C-p>'] = cmp.mapping(function(fallback)
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
  preselect = cmp.PreselectMode.None,
  completion = {keyword_length = 2, completeopt = "menu,menuone,noselect"},
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

require('ts-comments').setup{}
