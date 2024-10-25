local M = {}
local state = {}
local cache = {}
cache.branch = ""
cache.lsp = ""

function _G._statusline_component(name)
  return state[name]()
end

local mode_map = {
  ["n"] = "NORMAL",
  ["no"] = "NORMAL",
  ["v"] = "VISUAL",
  ["V"] = "VISUAL LINE",
  ["\22"] = "VISUAL BLOCK",  -- "\22" represents Ctrl-V
  ["s"] = "SELECT",
  ["S"] = "SELECT LINE",
  ["\19"] = "SELECT BLOCK",  -- "\19" represents Ctrl-S
  ["i"] = "INSERT",
  ["ic"] = "INSERT",
  ["R"] = "REPLACE",
  ["Rv"] = "VISUAL REPLACE",
  ["c"] = "COMMAND",
  ["cv"] = "VIM EX",
  ["ce"] = "EX",
  ["r"] = "PROMPT",
  ["rm"] = "MOAR",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  ["t"] = "TERMINAL",
}

-- Mode function based on mode_map
function state.mode()
  local current_mode = vim.api.nvim_get_mode().mode
  local mode_name = mode_map[current_mode] or "UNKNOWN"
  return string.format("   %s ", mode_name):upper()
end

function M.update_git_branch()
  return vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null")
end


function state.git_branch()
  if cache.branch == "" then
    return ""
  end
  return string.format(" (%s) ", cache.branch:gsub("%s+", ""))  -- Trim whitespace
end

-- Function to get file path
function state.filepath()
  local fpath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.:h")
  if fpath == "" or fpath == "." then
    return " "
  end
  return string.format(" %%<%s/", fpath)
end

-- Function to get file name
function state.filename()
  local fname = vim.fn.expand("%:t")
  if fname == "" then
    return ""
  end
  return fname .. " "
end

function M.update_lsp()
  local count = {}
  local levels = {
    errors = "Error",
    warnings = "Warn",
  }

  for k, level in pairs(levels) do
    count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
  end

  local errors = ""
  local warnings = ""

  -- Set the error count with Neovim's DiagnosticError highlight group
  if count["errors"] ~= 0 then
    errors = "%#DiagnosticError#  " .. count["errors"] .. " "
  end

  -- Set the warning count with Neovim's DiagnosticWarn highlight group
  if count["warnings"] ~= 0 then
    warnings = "%#DiagnosticWarn#  " .. count["warnings"] .. " "
  end

  -- Restore to normal highlight after the diagnostics
  return errors .. warnings .. '%#Normal#'

end

-- LSP diagnostics function
function state.lsp()
  return cache.lsp
end

-- Filetype function
function state.filetype()
  return string.format("  %s  ", vim.bo.filetype)
end

-- Line information function
function state.lineinfo()
  if vim.bo.filetype == "alpha" then
    return ""
  end
  -- return " %P %l:%c "
  return " %l "
end

-- Status line format
state.full_status = {
  '%{%v:lua._statusline_component("mode")%} ',
  '%#Normal#',
  '%{%v:lua._statusline_component("git_branch")%} ',
  '%{%v:lua._statusline_component("filepath")%}',
  '%{%v:lua._statusline_component("filename")%}',
  '%=',
  '%{%v:lua._statusline_component("lsp")%}',
  '%{%v:lua._statusline_component("filetype")%}',
  '%{%v:lua._statusline_component("lineinfo")%}',
}

state.short_status = {
  state.full_status[1], -- mode
  '%=',                 -- center alignment
  '%{%v:lua._statusline_component("lineinfo")%}', -- line info
}

state.inactive_status = {
  ' %F', -- full file path
}

-- Setup function for autocommands and to apply statusline
function M.setup()
  local augroup = vim.api.nvim_create_augroup('statusline_cmds', { clear = true })
  local autocmd = vim.api.nvim_create_autocmd

  vim.opt.showmode = false

  -- Setting up the statusline for active windows
  autocmd('WinEnter', {
    group = augroup,
    callback = function()
      vim.wo.statusline = M.get_status('full')
    end
  })

  autocmd('InsertEnter', {
    group = augroup,
    desc = 'Clear message area',
    command = "echo ''"
  })

  autocmd('BufEnter', {
    group = augroup,
    callback = function()
      cache.branch = M.update_git_branch()
      vim.wo.statusline = M.get_status('full')
    end
  })

  autocmd('WinLeave', {
    group = augroup,
    callback = function()
      vim.wo.statusline = M.get_status('inactive')
    end
  })

  autocmd('BufLeave', {
    group = augroup,
    callback = function()
      vim.wo.statusline = M.get_status('inactive')
    end
  })

  autocmd('DiagnosticChanged', {
    group = augroup,
    callback = function()
      cache.lsp = M.update_lsp()
      vim.wo.statusline = M.get_status('full')
    end
  })

end

-- Function to retrieve the statusline format
function M.get_status(name)
  return table.concat(state[string.format('%s_status', name)], '')
end

return M

