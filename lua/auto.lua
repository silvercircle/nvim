-- autogroups
local autocmd = vim.api.nvim_create_autocmd
local globals = require("globals")
local agroup_views = vim.api.nvim_create_augroup("views", {} )
local agroup_hl = vim.api.nvim_create_augroup("hl", {} )

autocmd({ 'VimLeave' }, {
  callback = function()
    if vim.g.config.plain == false then
      globals.write_config()
    end
  end,
  group = agroup_views
})

-- on UIEnter show a terminal split and a left-hand nvim-tree file explorer. Unless the
-- environment variable or command line option forbids it for better startup performance and
-- a clean UI
autocmd({ 'UIEnter' }, {
  callback = function()
    globals.main_winid = vim.fn.win_getid()
    if vim.g.config.plain == false then
      require('nvim-tree.api').tree.toggle({focus = false})
      globals.restore_config()
      if globals.perm_config.terminal.active == true then
        globals.termToggle(globals.perm_config.terminal.height)
      end
      if globals.perm_config.sysmon.active ~= true and globals.perm_config.weather.active ~= true then
        -- create the WinResized watcher to keep track of the terminal split height.
        -- When either sysmon or weather splits are active, this is done by their resize handlers
        -- so we don't need this here
        autocmd({ "WinResized" }, {
          callback = function()
            if globals.term.winid ~= nil then
              globals.perm_config.terminal.height = vim.api.nvim_win_get_height(globals.term.winid)
            end
          end,
          group = agroup_views
        })
      end
      vim.api.nvim_command("wincmd p")
      if vim.g.config.use_bufferlist == true then
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
        require("local_utils.blist").open(true)
      end
    end
  end
})

-- create a view to save folds when saving the file
autocmd( { 'bufwritepre' }, {
  pattern = "*",
  callback = function() globals.mkview() end,
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
  pattern = { 'alpha' },
  callback = function()
     vim.cmd("silent! setlocal statuscolumn=")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = { 'qf' },
  callback = function()
    if #globals.findwinbyBufType("sysmon") > 0 or #globals.findwinbyBufType("weather") > 0 then
      vim.cmd("setlocal statuscolumn= | setlocal signcolumn=no | wincmd J")
    else
      vim.cmd("setlocal statuscolumn= | setlocal signcolumn=no")
    end
    vim.api.nvim_win_set_height(globals.term.winid, globals.perm_config.terminal.height)
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = { 'Outline' },
  callback = function()
    vim.cmd("silent! setlocal colorcolumn=36 | silent! setlocal foldcolumn=0 | silent! setlocal signcolumn=no | silent! setlocal nonumber | silent! setlocal statuscolumn= | silent! setlocal statusline=Outline | setlocal winhl=Normal:NeoTreeNormalNC,CursorLine:Visual | hi nCursor blend=100")
  end,
  group = agroup_views
})

-- this is for the treesitter tree split view (tsp command)
autocmd( { 'FileType' }, {
  pattern = "Treesitter",
  callback = function()
    vim.cmd("silent! setlocal signcolumn=no | silent! setlocal foldcolumn=0 | silent! setlocal nonumber | setlocal norelativenumber | silent setlocal statuscolumn= | setlocal statusline=Treesitter | setlocal winhl=Normal:NeoTreeNormalNC")
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
  pattern = { 'vim', 'nim', 'python', 'lua', 'json', 'html', 'css', 'dart', 'go' },
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
    if filetype == "DressingSelect" or filetype == "Outline" or filetype =="NvimTree" or filetype == 'BufList' then
      vim.cmd("setlocal winhl=CursorLine:Visual,Normal:NeoTreeNormalNC | hi nCursor blend=100")
    end
  end,
  group = agroup_hl
})

autocmd( { 'WinLeave' }, {
  pattern = '*',
  callback = function()
    local filetype = vim.bo.filetype
    if filetype == "DressingSelect" or filetype == "Outline" or filetype =="NvimTree" or filetype == 'BufList' then
      vim.cmd("hi nCursor blend=0")
    end
  end,
  group = agroup_hl
})

