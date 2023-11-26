-- this file handles all auto commands and event handling.

-- autogroups
local autocmd = vim.api.nvim_create_autocmd
local globals = require("globals")
local agroup_views = vim.api.nvim_create_augroup("views", {})
local agroup_hl = vim.api.nvim_create_augroup("hl", {})
local wsplit = require("local_utils.wsplit")
local usplit = require("local_utils.usplit")
local tsc = require("treesitter-context")
local utils = require("local_utils")
local marks = require("local_utils.marks")

-- local ibl = require('indent_blankline')

--- on leave, write the permanent settings file
autocmd({ 'VimLeave' }, {
  callback = function()
    if Config.plain == false then
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
    if Config.plain == false then
      if globals.perm_config.tree.active == true then
        require('nvim-tree.api').tree.toggle({ focus = false })
      end
      if globals.perm_config.terminal.active == true then
        globals.termToggle(globals.perm_config.terminal.height)
      end
      -- create the WinResized watcher to keep track of the terminal split height.
      -- also call the resize handlers for the usplit/wsplit frames.
      -- keep track of tree/outline window widths
      autocmd({ "WinClosed", "WinResized" }, {
        callback = function(sizeevent)
          if globals.term.winid ~= nil then
            globals.perm_config.terminal.height = vim.api.nvim_win_get_height(globals.term.winid)
          end
          require("local_utils.usplit").resize_or_closed()
          -- require("local_utils.wsplit").resize_or_closed()
          if sizeevent.event == "WinResized" then
            wsplit.set_minheight()
            wsplit.refresh()
            local status = globals.is_outline_open()
            local tree = globals.findwinbyBufType("NvimTree")
            if status.outline ~= 0 then
              globals.perm_config.outline.width = vim.api.nvim_win_get_width(status.outline)
              -- print("Outline (" .. status.outline .. ") width set to: " .. globals.perm_config.outline.width)
            end
            if status.aerial ~= 0 then
              globals.perm_config.outline.width = vim.api.nvim_win_get_width(status.aerial)
              -- print("Aerial (" .. status.aerial .. ") width set to: " .. globals.perm_config.outline.width, 3)
            end
            if globals.perm_config.outline.width < Config.outline_width then
              globals.perm_config.outline.width = Config.outline_width
            end
            if #tree > 0 and tree[1] ~= nil then
              globals.perm_config.tree.width = vim.api.nvim_win_get_width(tree[1])
              if globals.perm_config.tree.width < Config.filetree_width then
                globals.perm_config.tree.width = Config.filetree_width
              end
            end
          end
        end,
        group = agroup_views
      })
      vim.api.nvim_command("wincmd p")
      --      require("local_utils.blist").setup({
      --        symbols = {
      --          current = "+", -- default 
      --          split = "s", -- default 
      --          alternate = "a", -- default 
      --          hidden = "~", -- default ﬘
      --          unloaded = "-",
      --          locked = "L", -- default 
      --          ro = "r", -- default 
      --          edited = "*", -- default 
      --          terminal = "t", -- default 
      --  --        default_file = "D", -- Filetype icon if not present in nvim-web-devicons. Default 
      --          terminal_symbol = ">" -- Filetype icon for a terminal split. Default 
      --        }
      --      })
      --      if globals.perm_config.blist == true then
      --require("local_utils.blist").open(true, 0, globals.perm_config.blist_height)
      --      end
      if globals.perm_config.weather.active == true then
        wsplit.content = globals.perm_config.weather.content
        wsplit.content_set_winid(globals.main_winid)
      end
      if globals.perm_config.sysmon.active then
        usplit.content = globals.perm_config.sysmon.content
      end
      if globals.perm_config.transbg == true then
        globals.set_bg()
      end
    end
    vim.fn.win_gotoid(globals.main_winid)
  end
})


-- create a view to save folds when saving the file
autocmd({ 'bufwritepre' }, {
  pattern = "*",
  callback = function()
    globals.mkview()
  end,
  group = agroup_views
})

-- when config.mkview_on_leave is true, create a view when a buffer loses focus
autocmd({ 'bufwinleave' }, {
  pattern = "*",
  callback = function()
    if Config.mkview_on_leave == true then
      globals.mkview()
    end
  end,
  group = agroup_views
})

-- just recalculate buffer size in bytes when entering a buffer.
-- We need this for some performance tweaks
-- also: set treesitter-context status (per buffer)
autocmd({ 'BufEnter' }, {
  pattern = "*",
  callback = function(args)
    local val = globals.get_buffer_var(0, "tsc")
    if val == true then
      tsc.enable()
    else
      tsc.disable()
    end
    globals.get_bufsize()
    wsplit.content_set_winid(vim.fn.win_getid())
    if wsplit.content == 'info' then
      vim.schedule(function() wsplit.refresh() end)
    end
    marks.BufWinEnterHandler(args) -- update marks in sign column
  end,
  group = agroup_views
})

-- restore view when reading a file
autocmd({ 'bufread' }, {
  pattern = "*",
  callback = function()
    vim.api.nvim_buf_set_var(0, "tsc", globals.perm_config.treesitter_context)
    if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(0, "buftype") ~= 'nofile' then
      vim.cmd("silent! loadview")
    end
  end,
  group = agroup_views
})

autocmd({ 'FileType' }, {
  pattern = { 'tex', 'markdown', 'text', 'telekasten', 'liquid' },
  callback = function()
    if vim.bo.modifiable == true then
      vim.cmd(
      "setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal textwidth=105 | setlocal ff=unix | setlocal fo+=nwqtc | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de")
    end
  end,
  group = agroup_views
})

local treesitter_configured = false

-- handle treesitter configuration and start it on supported filetypes.
autocmd({ "Filetype" }, {
  pattern = Config.treesitter_types,
  callback = function()
    if not treesitter_configured then
      globals.configure_treesitter()
      treesitter_configured = true
    end
    vim.treesitter.start()
  end,
  group = agroup_hl
})
-- pattern for which the indent and tabstop options must be set.
local tabstop_pattern = { 'vim', 'nim', 'python', 'lua', 'json', 'html', 'css', 'dart', 'go' }
local conceal_pattern = { "markdown", "telekasten", "liquid" }

-- generic FileType handler adressing common actions
autocmd({ 'FileType' }, {
  pattern = { "aerial", "Outline", "DressingSelect", "DressingInput", "query", "mail", "qf", "replacer",
    'vim', 'nim', 'python', 'lua', 'json', 'html', 'css', 'dart', 'go',
    "markdown", "telekasten", "liquid", "Glance" },
  callback = function(args)
    if args.match == "aerial" or args.match == "Outline" then
      vim.cmd(
      "silent! setlocal foldcolumn=0 | silent! setlocal signcolumn=no | silent! setlocal nonumber | silent! setlocal statusline=\\ \\ Outline" ..
      "\\ (" ..
      globals.perm_config.outline_filetype ..
      ") | setlocal winhl=Normal:NeoTreeNormalNC,CursorLine:Visual | hi nCursor blend=0")
      -- aerial can set its own statuscolumn
      if args.match == 'Outline' then
        vim.cmd("silent! setlocal statuscolumn=")
      end
      vim.api.nvim_win_set_width(0, globals.perm_config.outline.width)
    elseif args.match == "DressingSelect" then
      vim.cmd("setlocal winhl=CursorLine:Visual | hi nCursor blend=100")
    elseif args.match == "DressingInput" then
      vim.cmd("hi nCursor blend=0")
    elseif args.match == "mail" then
      vim.cmd(
      "setlocal foldcolumn=0 | setlocal fo-=c | setlocal fo+=w | setlocal ff=unix | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de")
    elseif args.match == "query" then
      vim.cmd(
      "silent! setlocal signcolumn=no | silent! setlocal foldcolumn=0 | silent! setlocal norelativenumber | silent! setlocal nonumber | setlocal statusline=Treesitter | setlocal winhl=Normal:NeoTreeNormalNC")
    elseif args.match == "Glance" then
      vim.defer_fn(function() vim.cmd("setlocal cursorline") end, 400)
    elseif args.match == "qf" or args.match == "replacer" then
      if #globals.findwinbyBufType("sysmon") > 0 or #globals.findwinbyBufType("weather") > 0 then
        vim.cmd("setlocal statuscolumn=%#NeoTreeNormalNC#\\  | setlocal signcolumn=no | setlocal nonumber | wincmd J")
      else
        vim.cmd("setlocal statuscolumn=%#NeoTreeNormalNC#\\  | setlocal signcolumn=no | setlocal nonumber")
      end
      vim.api.nvim_win_set_height(globals.term.winid, globals.perm_config.terminal.height)
    elseif vim.tbl_contains(tabstop_pattern, args.match) then
      vim.cmd(
      "setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal fo-=c")
    elseif vim.tbl_contains(conceal_pattern, args.match) then
      vim.cmd("setlocal conceallevel=2 | setlocal concealcursor=nc | setlocal formatexpr=")
    end
  end,
  group = agroup_hl
})

autocmd({ 'CmdLineEnter' }, {
  pattern = '*',
  callback = function()
    vim.cmd("hi nCursor blend = 0")
  end,
  group = agroup_hl
})

-- filetypes for left, right and bottom splits. They are meant to have a different background
-- color and no cursor
local enter_leave_filetypes = { "DressingSelect", "aerial", "Outline", "NvimTree" }
local old_mode

autocmd({ 'WinEnter' }, {
  pattern = '*',
  callback = function()
    wsplit.content_set_winid(vim.fn.win_getid())
    if wsplit.content == 'info' then
      globals.get_bufsize()
      vim.schedule(function() wsplit.refresh() end)
    end

    local filetype = vim.bo.filetype
    if vim.tbl_contains(enter_leave_filetypes, filetype) then
      vim.cmd("setlocal winhl=CursorLine:Visual,Normal:NeoTreeNormalNC | hi nCursor blend=100")
    end
    -- HACK: NvimTree and outline windows will complain about the buffer being not modifiable
    -- when insert mode is active. So stop it and remember its state
    if filetype == "NvimTree" or filetype == "Outline" or filetype == "aerial" then
      old_mode = vim.api.nvim_get_mode().mode
      vim.cmd.stopinsert()
    end
  end,
  group = agroup_hl
})

autocmd({ 'WinLeave' }, {
  pattern = '*',
  callback = function()
    local filetype = vim.bo.filetype
    if vim.tbl_contains(enter_leave_filetypes, filetype) then
      vim.cmd("hi nCursor blend=0")
    end
    -- HACK: restore the insert mode if it was active when changing to the NvimTree or outline
    -- split.
    if filetype == "NvimTree" or filetype == "Outline" or filetype == "aerial" then
      if old_mode == 'i' then
        old_mode = ''
        vim.cmd.startinsert()
      end
    end
  end,
  group = agroup_hl
})
