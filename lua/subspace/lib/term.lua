--- *mini.misc* Miscellaneous functions
--- *MiniMisc*
---
--- MIT License Copyright (c) 2021 Evgeni Chasnovski
---
--- ==============================================================================
---
--- - |MiniMisc.setup_termbg_sync()| to set up terminal background synchronization
---   (removes possible "frame" around current Neovim instance).
---
--- This module doesn't have runtime options, so using `vim.b.minimisc_config`
--- will have no effect here.

local M = {}
local H = {}
H.termbg_init = 0

H.parse_osc11 = function(x)
  local r, g, b = x:match('^\027%]11;rgb:(%x+)/(%x+)/(%x+)$')
  if not (r and g and b) then
    local a
    r, g, b, a = x:match('^\027%]11;rgba:(%x+)/(%x+)/(%x+)/(%x+)$')
    if not (a and a:len() <= 4) then return end
  end
  if not (r and g and b) then return end
  if not (r:len() <= 4 and g:len() <= 4 and b:len() <= 4) then return end
  local parse_osc_hex = function(c) return c:len() == 1 and (c .. c) or c:sub(1, 2) end
  return '#' .. parse_osc_hex(r) .. parse_osc_hex(g) .. parse_osc_hex(b)
end

M.setup_termbg_sync = function()
  -- Handling `'\027]11;?\007'` response was added in Neovim 0.10
  if vim.fn.has('nvim-0.10') == 0 then return vim.notify('`setup_termbg_sync()` requires Neovim>=0.10') end

  -- Proceed only if there is a valid stdout to use
  local has_stdout_tty = false
  for _, ui in ipairs(vim.api.nvim_list_uis()) do
    has_stdout_tty = has_stdout_tty or ui.stdout_tty
  end
  if not has_stdout_tty then return end

  local augroup = vim.api.nvim_create_augroup('MiniMiscTermbgSync', { clear = true })
  local track_au_id, bad_responses, had_proper_response = nil, {}, false
  local f = function(args)
    -- Process proper response only once
    if had_proper_response then return end

    -- Neovim=0.10 uses string sequence as response, while Neovim>=0.11 sets it
    -- in `sequence` table field
    local seq = type(args.data) == 'table' and args.data.sequence or args.data
    local ok, bg_init = pcall(H.parse_osc11, seq)
    if not (ok and type(bg_init) == 'string') then return table.insert(bad_responses, seq) end
    had_proper_response = true
    pcall(vim.api.nvim_del_autocmd, track_au_id)

    -- Set up sync
    local sync = function()
      -- local normal = vim.api.nvim_get_hl_by_name('Normal', true)
      local normal = vim.api.nvim_get_hl(0, { name = "Normal" } )
      local bg = string.sub(require("darkmatter").T[require("darkmatter").get_conf().variant].treebg, 2)
      vim.notify("The bg color is: " .. bg)
      if normal.bg == nil then return end
      -- NOTE: use `io.stdout` instead of `io.write` to ensure correct target
      -- Otherwise after `io.output(file); file:close()` there is an error
      io.stdout:write(string.format('\027]11;#%06s\007', bg))
      vim.notify("sending ESC: " .. string.format('\027]11;#%06s\007', bg))
    end
    -- vim.api.nvim_create_autocmd({ 'VimResume', 'ColorScheme' }, { group = augroup, callback = sync })

    -- Set up reset to the color returned from the very first call
    H.termbg_init = H.termbg_init or bg_init
    local reset = function() io.stdout:write('\027]11;' .. H.termbg_init .. '\007') end
    -- vim.api.nvim_create_autocmd({ 'VimLeavePre', 'VimSuspend' }, { group = augroup, callback = reset })

    -- Sync immediately
    sync()
  end

  -- Ask about current background color and process the proper response.
  -- NOTE: do not use `once = true` as Neovim itself triggers `TermResponse`
  -- events during startup, so this should wait until the proper one.
  track_au_id = vim.api.nvim_create_autocmd('TermResponse', { group = augroup, callback = f, nested = true })
  io.stdout:write('\027]11;?\007')
  vim.defer_fn(function()
    if had_proper_response then return end
    pcall(vim.api.nvim_del_augroup_by_id, augroup)
    local bad_suffix = #bad_responses == 0 and '' or (', only these: ' .. vim.inspect(bad_responses))
    local msg = '`setup_termbg_sync()` did not get proper response from terminal emulator' .. bad_suffix
    vim.notify(msg)
  end, 1000)
end

return M

