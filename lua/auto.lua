-- this file handles all auto commands and event handling.

-- autogroups
local autocmd = vim.api.nvim_create_autocmd
local agroup_views = vim.api.nvim_create_augroup("views", {})
local agroup_hl = vim.api.nvim_create_augroup("hl", {})
local wsplit = require("local_utils.wsplit")
local usplit = require("local_utils.usplit")
local tsc = require("treesitter-context")
local utils = require("local_utils")
local marks = require("local_utils.marks")
local treeft = vim.g.tweaks.tree.version == "Neo" and "neo-tree" or "NvimTree"

-- local ibl = require('indent_blankline')

--- on leave, write the permanent settings file
autocmd({ 'VimLeave' }, {
  callback = function()
    if Config.plain == false then
      __Globals.write_config()
    end
  end,
  group = agroup_views
})

--- remember if UIEnter already done
local did_UIEnter = false

autocmd({ 'VimEnter' }, {
  callback = function()
    local econfig = require("editorconfig")
    if did_UIEnter == true then
      return
    end
    -- internal theme can be disabled via tweaks. This allows 
    -- to use an external theme
    if vim.g.tweaks.theme.disable == false then
      Config.theme.set()
    end
    -- support textwidth and formatoptions roperties via editorconfig files
    econfig.properties.textwidth = function(bufnr, val, _)
      vim.api.nvim_buf_set_option(bufnr, "textwidth", tonumber(val))
    end
    econfig.properties.formatoptions = function(bufnr, val, _)
      vim.api.nvim_buf_set_option(bufnr, "formatoptions", val)
    end
  end
})
-- on UIEnter show a terminal split and a left-hand nvim-tree file explorer. Unless the
-- environment variable or command line option forbids it for better startup performance and
-- a clean UI
autocmd({ "UIEnter" }, {
  callback = function()
    -- this should only run on initial UIEnter (nvim start), exactly ONCE. UIEnter is also
    -- fired when nvim resumes from suspend (Ctrl-Z) in which case this code is no longer needed
    -- because all the sub splits have already been created
    -- running this more than once will cause all kind of mayhem, so don't
    if did_UIEnter == true then
      return
    end

    -- create custom telescope themes as globals
    __Telescope_dropdown_theme = utils.Telescope_dropdown_theme
    __Telescope_vertical_dropdown_theme = utils.Telescope_vertical_dropdown_theme
    did_UIEnter = true
    __Globals.main_winid = vim.fn.win_getid()
    if Config.plain == false then
      if __Globals.perm_config.tree.active == true then
        __Globals.open_tree()
      end
      if __Globals.perm_config.terminal.active == true then
        __Globals.termToggle(__Globals.perm_config.terminal.height)
      end
      -- create the WinResized watcher to keep track of the terminal split height.
      -- also call the resize handlers for the usplit/wsplit frames.
      -- keep track of tree/outline window widths
      autocmd({ "WinClosed", "WinResized" }, {
        callback = function(sizeevent)
          require("local_utils.usplit").resize_or_closed(sizeevent)
          -- require("local_utils.wsplit").resize_or_closed()
          if sizeevent.event == "WinClosed" then
            if __Globals.term.winid ~= nil and vim.api.nvim_win_is_valid(__Globals.term.winid) == false then
              __Globals.term.winid = nil
              __Globals.term.visible = false
            end
            if wsplit.winid ~= nil and vim.api.nvim_win_is_valid(wsplit.winid) == false then
              wsplit.winid = nil
            end
            if usplit.winid ~= nil and vim.api.nvim_win_is_valid(usplit.winid) == false then
              usplit.winid = nil
            end
            local id = sizeevent.match
            local status, target = pcall(vim.api.nvim_win_get_var, tonumber(id), "termheight")
            if status and __Globals.term.winid ~= nil then
              vim.schedule(function() vim.api.nvim_win_set_height(__Globals.term.winid, tonumber(target)) end)
            end
          end
          if sizeevent.event == "WinResized" then
            if __Globals.term.winid ~= nil then
              __Globals.perm_config.terminal.height = vim.api.nvim_win_get_height(__Globals.term.winid)
            end
            wsplit.set_minheight()
            wsplit.refresh()
            local status = __Globals.is_outline_open()
            local tree = __Globals.findwinbyBufType(treeft)
            if status.outline ~= 0 then
              __Globals.perm_config.outline.width = vim.api.nvim_win_get_width(status.outline)
            end
            if status.aerial ~= 0 then
              __Globals.perm_config.outline.width = vim.api.nvim_win_get_width(status.aerial)
            end
            if __Globals.perm_config.outline.width < Config.outline_width then
              __Globals.perm_config.outline.width = Config.outline_width
            end
            if #tree > 0 and tree[1] ~= nil then
              __Globals.perm_config.tree.width = vim.api.nvim_win_get_width(tree[1])
              if __Globals.perm_config.tree.width < Config.filetree_width then
                __Globals.perm_config.tree.width = Config.filetree_width
              end
            end
          end
        end,
        group = agroup_views
      })
      vim.api.nvim_command("wincmd p")
      if __Globals.perm_config.weather.active == true then
        wsplit.content = __Globals.perm_config.weather.content
        wsplit.content_set_winid(__Globals.main_winid)
      end
      if __Globals.perm_config.sysmon.active then
        usplit.content = __Globals.perm_config.sysmon.content
      end
      if __Globals.perm_config.transbg == true then
        Config.theme.set_bg()
      end
    end
    vim.fn.win_gotoid(__Globals.main_winid)
  end
})


-- create a view to save folds when saving the file
autocmd({ 'bufwritepost' }, {
  pattern = "*",
  callback = function()
    if vim.g.tweaks.mkview_on_save == true then
      __Globals.mkview()
    end
  end,
  group = agroup_views
})

-- when config.mkview_on_leave is true, create a view when a buffer loses focus
autocmd({ 'bufwinleave' }, {
  pattern = "*",
  callback = function()
    if vim.g.tweaks.mkview_on_leave == true then
      __Globals.mkview()
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
    if vim.api.nvim_buf_get_option(args.buf, "buftype") == '' then
      local val = __Globals.get_buffer_var(args.buf, "tsc")
      if val == true then
        vim.schedule(function() tsc.enable() end)
      else
        vim.schedule(function() tsc.disable() end)
      end
    end
    __Globals.get_bufsize()
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
    vim.api.nvim_buf_set_var(0, "tsc", __Globals.perm_config.treesitter_context)
    if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(0, "buftype") ~= 'nofile' then
      vim.cmd("silent! loadview")
    end
  end,
  group = agroup_views
})

-- for these file types we want spellcheck
autocmd({ 'FileType' }, {
  pattern = { 'tex', 'markdown', 'text', 'telekasten', 'liquid' },
  callback = function()
    if vim.bo.modifiable == true then
      vim.cmd("setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal textwidth=105 | setlocal ff=unix | setlocal fo+=nwqtc | setlocal foldmethod=manual")
    end
    if vim.bo.buftype == "" then
      vim.cmd("setlocal spell spelllang=en_us,de_de")
    end
  end,
  group = agroup_views
})

-- handle treesitter configuration and start it on supported filetypes.
autocmd({ "Filetype" }, {
  pattern = Config.treesitter_types,
  callback = function()
    vim.treesitter.start()
  end,
  group = agroup_hl
})
-- pattern for which the indent and tabstop options must be set.
local tabstop_pattern = { 'vim', 'nim', 'python', 'lua', 'json', 'html', 'css', 'dart', 'go' }
-- filetypes for which we want conceal enabled
local conceal_pattern = { "markdown", "telekasten", "liquid" }

-- generic FileType handler adressing common actions
autocmd({ 'FileType' }, {
  pattern = { "aerial", "Outline", "DressingSelect", "DressingInput", "query", "mail", "qf", "replacer", "Trouble",
    'vim', 'nim', 'python', 'lua', 'json', 'html', 'css', 'dart', 'go',
    "markdown", "telekasten", "liquid", "Glance", "scala", "sbt" },
  callback = function(args)
    if args.match == "aerial" or args.match == "Outline" then
      vim.cmd(
      "silent! setlocal foldcolumn=0 | silent! setlocal signcolumn=no | silent! setlocal nonumber | silent! setlocal statusline=\\ \\ Outline" ..
      "\\ (" ..
      __Globals.perm_config.outline_filetype ..
      ") | setlocal winhl=Normal:NeoTreeNormalNC,CursorLine:TreeCursorLine | hi nCursor blend=0")
      -- aerial can set its own statuscolumn
      if args.match == 'Outline' then
        vim.cmd("silent! setlocal statuscolumn=")
      end
      vim.api.nvim_win_set_width(0, __Globals.perm_config.outline.width)
    elseif args.match == "DressingSelect" then
      vim.cmd("setlocal winhl=CursorLine:TreeCursorLine | hi nCursor blend=100")
    elseif args.match == "DressingInput" then
      vim.cmd("hi nCursor blend=0")
    elseif args.match == "mail" then
      vim.cmd("setlocal foldcolumn=0 | setlocal fo-=c | setlocal fo+=w | setlocal ff=unix | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de")
    elseif args.match == "query" then
      vim.cmd("silent! setlocal signcolumn=no | silent! setlocal foldcolumn=0 | silent! setlocal norelativenumber | silent! setlocal nonumber | setlocal statusline=Treesitter | setlocal winhl=Normal:NeoTreeNormalNC")
    elseif args.match == "Glance" then
      vim.defer_fn(function() vim.cmd("setlocal cursorline") end, 400)
    elseif args.match == "qf" or args.match == "replacer" then
    --  if #__Globals.findwinbyBufType("sysmon") > 0 or #__Globals.findwinbyBufType("weather") > 0 then
    --    vim.cmd("setlocal statuscolumn=%#NeoTreeNormalNC#\\  | setlocal signcolumn=no | setlocal nonumber | wincmd J")
    --  else
    --    vim.cmd("setlocal statuscolumn=%#NeoTreeNormalNC#\\  | setlocal signcolumn=no | setlocal nonumber")
    --  end
      vim.cmd("setlocal winhl=Normal:NeoTreeNormalNC,CursorLine:Visual")
    --  vim.api.nvim_win_set_height(__Globals.term.winid, __Globals.perm_config.terminal.height)
    elseif args.match == "Trouble" then
      if __Globals.term.winid ~= nil then
        vim.api.nvim_win_set_var(0, "termheight", __Globals.perm_config.terminal.height)
      end
    elseif vim.tbl_contains(tabstop_pattern, args.match) then
      vim.cmd(
      "setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal fo-=c")
    elseif vim.tbl_contains(conceal_pattern, args.match) then
      vim.cmd("setlocal conceallevel=2 | setlocal concealcursor=nc | setlocal formatexpr=")
    -- metals, attach on filetype
    elseif args.match == "scala" or args.match == "sbt" then
      require("metals").initialize_or_attach({
        -- TODO: review config
        capabilities = __Globals.get_lsp_capabilities(),
        settings = {
          metalsBinaryPath = vim.g.lsp_server_bin["metals"]
        }
      })
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
local enter_leave_filetypes = { "DressingSelect", "aerial", "Outline", "NvimTree", "neo-tree"  }
local old_mode

autocmd({ 'WinEnter' }, {
  pattern = '*',
  callback = function()
    wsplit.content_set_winid(vim.fn.win_getid())
    if wsplit.content == 'info' then
      __Globals.get_bufsize()
      vim.schedule(function() wsplit.refresh() end)
    end

    local filetype = vim.bo.filetype
    if vim.tbl_contains(enter_leave_filetypes, filetype) then
      vim.cmd("setlocal winhl=CursorLine:TreeCursorLine,Normal:NeoTreeNormalNC | hi nCursor blend=100")
    end
    -- HACK: NvimTree and outline windows will complain about the buffer being not modifiable
    -- when insert mode is active. So stop it and remember its state
    if filetype == "neo-tree" or filetype == "NvimTree" or filetype == "Outline" or filetype == "aerial" then
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
    if filetype == "neo-tree" or filetype == "NvimTree" or filetype == "Outline" or filetype == "aerial" then
      if old_mode == 'i' then
        old_mode = ''
        vim.cmd.startinsert()
      end
    end
  end,
  group = agroup_hl
})

autocmd({ 'User'}, {
  pattern = "MiniFilesWindowOpen",
  callback = function()
    vim.cmd("hi nCursor blend=100")
    vim.cmd("setlocal winhl=MiniFilesCursorLine:Visual")
  end
})

autocmd({ 'User'}, {
  pattern = "MiniFilesExplorerClose",
  callback = function()
    vim.cmd("hi nCursor blend=0")
  end
})
