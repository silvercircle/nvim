-- this file handles all auto commands and event handling.

-- autogroups
local autocmd = vim.api.nvim_create_autocmd
local globals = require("globals")
local agroup_views = vim.api.nvim_create_augroup("views", {} )
local agroup_hl = vim.api.nvim_create_augroup("hl", {} )
local wsplit = require("local_utils.wsplit")

-- local ibl = require('indent_blankline')

--- on leave, write the permanent settings file
autocmd({ 'VimLeave' }, {
  callback = function()
    if vim.g.config.plain == false then
      globals.write_config()
    end
  end,
  group = agroup_views
})

--- remember if UIEnter already done
local did_UIEnter = false

-- on UIEnter show a terminal split and a left-hand nvim-tree file explorer. Unless the
-- environment variable or command line option forbids it for better startup performance and
-- a clean UI
autocmd({ 'UIEnter' }, {
  callback = function(event)
    -- this should only run on initial UIEnter (nvim start), exactly ONCE. UIEnter is also
    -- fired when nvim resumes from suspend (Ctrl-Z) in which case this code is no longer needed
    -- because all the sub splits have already been created
    -- running this more than once will cause all kind of mayhem, so don't
    if did_UIEnter == true then
      return
    end
    did_UIEnter = true
    globals.main_winid = vim.fn.win_getid()
    if vim.g.config.plain == false then
      if globals.perm_config.tree == true then
        require('nvim-tree.api').tree.toggle({focus = false})
      end
      if globals.perm_config.terminal.active == true then
        globals.termToggle(globals.perm_config.terminal.height)
      end
      -- create the WinResized watcher to keep track of the terminal split height.
      -- also call the resize handlers for the usplit/wsplit frames.
      autocmd({ "WinClosed", "WinResized" }, {
        callback = function()
          if globals.term.winid ~= nil then
            globals.perm_config.terminal.height = vim.api.nvim_win_get_height(globals.term.winid)
          end
          require("local_utils.usplit").resize_or_closed()
          require("local_utils.wsplit").resize_or_closed()
        end,
        group = agroup_views
      })
      vim.api.nvim_command("wincmd p")
      require("local_utils.blist").setup({
        symbols = {
          current = "+", -- default 
          split = "s", -- default 
          alternate = "a", -- default 
          hidden = "~", -- default ﬘
          unloaded = "-",
          locked = "L", -- default 
          ro = "r", -- default 
          edited = "*", -- default 
          terminal = "t", -- default 
  --        default_file = "D", -- Filetype icon if not present in nvim-web-devicons. Default 
          terminal_symbol = ">" -- Filetype icon for a terminal split. Default 
        }
      })
      if globals.perm_config.blist == true then
        --require("local_utils.blist").open(true, 0, globals.perm_config.blist_height)
      end
      if globals.perm_config.weather.active == true then
        wsplit.content = globals.perm_config.weather.content
        wsplit.content_set_winid(globals.main_winid)
        --wsplit.refresh()
      end
      if globals.perm_config.transbg == true then
        globals.set_bg()
      end
      globals.set_scrollbar()
    end
    vim.fn.win_gotoid(globals.main_winid)
  end
})


-- create a view to save folds when saving the file
autocmd( { 'bufwritepre' }, {
  pattern = "*",
  callback = function()
    globals.mkview()
  end,
  group = agroup_views
})

-- when config.mkview_on_leave is true, create a view when a buffer loses focus
autocmd( { 'bufwinleave' }, {
  pattern = "*",
  callback = function()
    if vim.g.config.mkview_on_leave == true then
      globals.mkview()
    end
  end,
  group = agroup_views
})

-- just recalculate buffer size in bytes when entering a buffer.
-- We need this for some performance tweaks
autocmd( { 'bufwinenter' }, {
  pattern = "*",
  callback = function()
    globals.get_bufsize()
    wsplit.content_set_winid(vim.fn.win_getid())
    if wsplit.content == 'info' then
      vim.schedule(function() wsplit.refresh() end)
    end
  end,
  group = agroup_views
})

autocmd( { 'winenter' }, {
  pattern = "*",
  callback = function()
    wsplit.content_set_winid(vim.fn.win_getid())
    if wsplit.content == 'info' then
      globals.get_bufsize()
      vim.schedule(function() wsplit.refresh() end)
    end
  end,
  group = agroup_views
})

-- restore view when reading a file
autocmd( { 'bufread' }, {
  pattern = "*",
  callback = function()
    if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(0, "buftype") ~= 'nofile' then
      vim.cmd("silent! loadview")
    end
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = { 'qf', 'replacer' },
  callback = function()
    if #globals.findwinbyBufType("sysmon") > 0 or #globals.findwinbyBufType("weather") > 0 then
      vim.cmd("setlocal statuscolumn=%#NeoTreeNormalNC#\\  | setlocal signcolumn=no | setlocal nonumber | wincmd J")
    else
      vim.cmd("setlocal statuscolumn=%#NeoTreeNormalNC#\\  | setlocal signcolumn=no | setlocal nonumber")
    end
    vim.api.nvim_win_set_height(globals.term.winid, globals.perm_config.terminal.height)
  end,
  group = agroup_views
})

--- Outline is from symbols-outline plugin and holds the symbol tree
autocmd( { 'FileType' }, {
  pattern = vim.g.config.outline_filetype,
  callback = function()
    vim.cmd("silent! setlocal foldcolumn=0 | silent! setlocal signcolumn=no | silent! setlocal nonumber | silent! setlocal statuscolumn= | silent! setlocal statusline=\\ \\ Outline | setlocal winhl=Normal:NeoTreeNormalNC,CursorLine:Visual | hi nCursor blend=100")
  end,
  group = agroup_views
})

-- this is for the treesitter tree split view (tsp command)
autocmd( { 'FileType' }, {
  pattern = "query",
  callback = function()
    vim.cmd("silent! setlocal signcolumn=no | silent! setlocal foldcolumn=0 | silent! setlocal norelativenumber | silent! setlocal nonumber | setlocal statusline=Treesitter | setlocal winhl=Normal:NeoTreeNormalNC")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = 'mail',
  callback = function()
    vim.cmd("setlocal foldcolumn=0 | setlocal fo-=c | setlocal fo+=w | setlocal ff=unix | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = { 'markdown', 'telekasten', 'liquid' },
  callback = function()
    vim.cmd("setlocal conceallevel=2 | setlocal concealcursor=nc | setlocal formatexpr=")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = { 'tex', 'markdown', 'text', 'telekasten', 'liquid' },
  callback = function()
    if vim.bo.modifiable == true then
      vim.cmd("setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal textwidth=105 | setlocal ff=unix | setlocal fo+=nwqtc | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de")
    end
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = { 'vim', 'nim', 'python', 'lua', 'json', 'html', 'css', 'dart', 'go'},
  callback = function()
    vim.cmd("setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal fo-=c")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = "DressingSelect",
  callback = function()
    vim.cmd("setlocal winhl=CursorLine:Visual | hi nCursor blend=100")
  end,
  group = agroup_hl
})
autocmd( { 'FileType' } , {
  pattern = "DressgingInput",
  callback = function()
    vim.cmd("hi nCursor blend=0")
  end,
  group = agroup_hl
})

autocmd( { 'CmdLineEnter' }, {
  pattern = '*',
  callback = function()
    vim.cmd("hi nCursor blend = 0")
  end,
  group = agroup_hl
})

autocmd( { 'WinEnter' }, {
  pattern = '*',
  callback = function()
    local filetype = vim.bo.filetype
    if filetype == "DressingSelect" or filetype == vim.g.config.outline_filetype or filetype =="NvimTree" or filetype == 'BufList' then
      vim.cmd("setlocal winhl=CursorLine:Visual,Normal:NeoTreeNormalNC | hi nCursor blend=100")
    end
  end,
  group = agroup_hl
})

autocmd( { 'WinLeave' }, {
  pattern = '*',
  callback = function()
    local filetype = vim.bo.filetype
    if filetype == "DressingSelect" or filetype == vim.g.config.outline_filetype or filetype =="NvimTree" or filetype == 'BufList' then
      vim.cmd("hi nCursor blend=0")
    end
  end,
  group = agroup_hl
})

