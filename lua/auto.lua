-- this file handles all auto commands and event handling.

-- autogroups
local autocmd = vim.api.nvim_create_autocmd
local agroup_views = vim.api.nvim_create_augroup("views", {})
local agroup_hl = vim.api.nvim_create_augroup("hl", {})
local Wsplit = require("subspace.content.wsplit")
local Usplit = require("subspace.content.usplit")
local Tsc = require("treesitter-context")
local marks = require("subspace.lib.marks")
local treeft = Tweaks.tree.filetype

-- local ibl = require('indent_blankline')

local function configure_outline_sidebar()
  --vim.schedule(function()
    vim.cmd("silent! set foldcolumn=0 | silent! set signcolumn=no | silent! set nonumber | setlocal listchars=eol:\\ ")
    vim.cmd("silent! set statusline=\\ \\ Outline" .. "\\ (" .. PCFG.outline_filetype .. ")")
    --vim.cmd("set winhl=Normal:TreeNormalNC,CursorLine:TreeCursorLine | hi nCursor blend=0")
    vim.cmd("hi nCursor blend=0")
    vim.cmd("silent! set statuscolumn=")
  --end)
end

--- on leave, write the permanent settings file
autocmd({ 'VimLeave' }, {
  callback = function()
    if CFG.plain == false then
      -- vim.system({ 'tmux', 'set', '-qg', 'allow-passthrough', 'off' }, { text = true })
      require("subspace.lib.permconfig").write_config()
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
    if Tweaks.theme.disable == false then
      CFG.theme.set()
    end
    -- support textwidth and formatoptions roperties via editorconfig files
    econfig.properties.textwidth = function(bufnr, val, _)
      vim.api.nvim_set_option_value("textwidth", tonumber(val), { buf = bufnr })
    end
    econfig.properties.formatoptions = function(bufnr, val, _)
      vim.api.nvim_set_option_value("formatoptions", val, { buf = bufnr })
    end
  end
})

--- this function configures the UI layout on UIEnter
local function main_layout()
  -- this should only run on initial UIEnter (nvim start), exactly ONCE. UIEnter is also
  -- fired when nvim resumes from suspend (Ctrl-Z) in which case this code is no longer needed
  -- because all the sub splits have already been created
  -- running this more than once will cause all kind of mayhem, so don't
  if did_UIEnter == true then
    return
  end

  did_UIEnter = true
  CGLOBALS.main_winid = vim.fn.win_getid()
  if CFG.plain == false then
    if PCFG.tree.active == true then
      CGLOBALS.open_tree()
    end
    if PCFG.terminal.active == true then
      vim.schedule(function() CGLOBALS.termToggle(PCFG.terminal.height) vim.fn.win_gotoid(CGLOBALS.main_winid) end)
    end
    -- create the WinResized watcher to keep track of the terminal split height.
    -- also call the resize handlers for the usplit/wsplit frames.
    -- keep track of tree/outline window widths
    autocmd({ "WinClosed", "WinResized" }, {
      callback = function(sizeevent)
        require("subspace.content.usplit").resize_or_closed(sizeevent)
        if sizeevent.event == "WinClosed" then
          if CGLOBALS.term.winid ~= nil and vim.api.nvim_win_is_valid(CGLOBALS.term.winid) == false then
            CGLOBALS.term.winid = nil
            CGLOBALS.term.visible = false
          end
          if Wsplit.winid ~= nil and vim.api.nvim_win_is_valid(Wsplit.winid) == false then
            Wsplit.winid = nil
          end
          if Usplit.winid ~= nil and vim.api.nvim_win_is_valid(Usplit.winid) == false then
            Usplit.winid = nil
          end
          local id = sizeevent.match
          local status, target = pcall(vim.api.nvim_win_get_var, tonumber(id), "termheight")
          if status and CGLOBALS.term.winid ~= nil then
            vim.schedule(function() vim.api.nvim_win_set_height(CGLOBALS.term.winid, tonumber(target)) end)
          end
        end
        if sizeevent.event == "WinResized" then
          if CGLOBALS.term.winid ~= nil then
            PCFG.terminal.height = vim.api.nvim_win_get_height(CGLOBALS.term.winid)
          end
          Wsplit.set_minheight()
          Wsplit.refresh("resize")
          local status = CGLOBALS.is_outline_open()
          local tree = CGLOBALS.findWinByFiletype(treeft)
          if status ~= false then
            PCFG.outline.width = vim.api.nvim_win_get_width(status)
          end
          if PCFG.outline.width < Tweaks.outline.width then
            PCFG.outline.width = Tweaks.outline.width
          end
          if #tree > 0 and tree[1] ~= nil then
            PCFG.tree.width = vim.api.nvim_win_get_width(tree[1])
            if PCFG.tree.width < Tweaks.tree.width then
              PCFG.tree.width = Tweaks.tree.width
            end
          end
        end
      end,
      group = agroup_views
    })
    vim.api.nvim_command("wincmd p")
    if PCFG.weather.active == true then
      Wsplit.content = PCFG.weather.content
      Wsplit.content_winid = CGLOBALS.main_winid
    end
    if PCFG.sysmon.active then
      Usplit.content = PCFG.sysmon.content
    end
    if PCFG.transbg == true then
      CFG.theme.set_bg()
    end
  end
  vim.fn.win_gotoid(CGLOBALS.main_winid)
end

-- on UIEnter show a terminal split and a left-hand nvim-tree file explorer. Unless the
-- environment variable or command line option forbids it for better startup performance and
-- a clean UI

autocmd({ "UIEnter" }, {
  callback = function()
    main_layout()
  end
})

-- force refresh lualine on ModeChanged event. This allows for higher debounce timers
-- (= better performance) and still get instant response for mode changes (which I feel
-- is important)
if Tweaks.statusline.version == "lualine" then
  autocmd( { "ModeChanged" }, {
    pattern = "*",
    callback = function()
      vim.schedule(function() require("lualine").refresh() end)
    end,
    group = agroup_views
  })
end

-- create a view to save folds when saving the file
autocmd({ 'bufwritepost' }, {
  pattern = "*",
  callback = function()
    if Tweaks.mkview_on_save == true then
      CGLOBALS.mkview()
    end
  end,
  group = agroup_views
})

-- when config.mkview_on_leave is true, create a view when a buffer loses focus
autocmd({ 'bufwinleave' }, {
  pattern = "*",
  callback = function()
    if Tweaks.mkview_on_leave == true then
      CGLOBALS.mkview()
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
    if vim.api.nvim_get_option_value("buftype", { buf = args.buf }) == '' then
      local val = CGLOBALS.get_buffer_var(args.buf, "tsc")
      if val == true then
        vim.schedule(function() Tsc.enable() end)
      else
        vim.schedule(function() Tsc.disable() end)
      end
      val = CGLOBALS.get_buffer_var(args.buf, "inlayhints")
      if val ~= nil and type(val) == "boolean" then
        vim.lsp.inlay_hint.enable(val, { bufnr = args.buf } )
      end
    end
    CGLOBALS.get_bufsize()
    if Wsplit.content == 'info' then
      vim.schedule(function() Wsplit.refresh("BufEnter (auto.lua)") end)
    end
    marks.BufWinEnterHandler(args) -- update marks in sign column
    vim.schedule(function() require("lualine").refresh() end)
  end,
  group = agroup_views
})

-- restore view when reading a file
autocmd({ 'BufReadPost' }, {
  pattern = "*",
  callback = function(args)
    vim.api.nvim_buf_set_var(0, "tsc", PCFG.treesitter_context)
    vim.api.nvim_buf_set_var(0, "inlayhints", PCFG.lsp.inlay_hints)
    if #vim.fn.expand("%") > 0 and vim.api.nvim_get_option_value("buftype", { buf = args.buf }) ~= 'nofile' then
      -- make sure parsing is complete before loading the view because restoring the folds
      -- would not work otherwise. This is only needed when using async parsing.
      if vim.g._ts_force_sync_parsing ~= true then
        local has, p = pcall(vim.treesitter.get_parser)
        if has and p ~= nil then p:parse() end
      end
      vim.cmd("silent! loadview")
    end
  end,
  group = agroup_views
})


-- handle treesitter configuration and start it on supported filetypes.
--autocmd({ "Filetype" }, {
--  pattern = CFG.treesitter_types,
--  callback = function()
--    vim.treesitter.start()
--  end,
--  group = agroup_hl
--})
-- generic FileType handler adressing common actions
-- see Tweaks.ft_patterns
autocmd({ "FileType" }, {
  pattern = "*",
  --pattern = { "SymbolsSidebar", "mail", "qf", "replacer",
  --  "vim", "nim", "python", "c", "cpp", "lua", "json", "html", "css", "dart", "go",
  --  "markdown", "telekasten", "liquid", "Glance", "scala", "sbt" },
  callback = function(args)
    local function in_pattern(p, ft)
      if p == false then return false end
      if p == true or vim.tbl_contains(p, ft) then
        return true
      end
      return false
    end

    if in_pattern(Tweaks.ft_patterns.spell, args.match) then
      if vim.bo.modifiable == true then
        vim.cmd("setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal textwidth=105 | setlocal ff=unix | setlocal fo+=nwqtc | setlocal foldmethod=manual")
      end
      if vim.bo.buftype == "" then
        vim.cmd("setlocal spell spelllang=en_us,de_de")
      end
    end
    if args.match == "SymbolsSidebar" then
      configure_outline_sidebar()
      vim.api.nvim_win_set_width(0, PCFG.outline.width)
    elseif args.match == "mail" then
      vim.cmd("setlocal foldcolumn=0 | setlocal fo-=c | setlocal fo+=w | setlocal ff=unix | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de")
    elseif args.match == "Glance" then
      vim.defer_fn(function() vim.cmd("setlocal cursorline") end, 400)
    elseif args.match == "qf" or args.match == "replacer" then
      vim.cmd("setlocal winhl=Normal:TreeNormalNC,CursorLine:Visual | setlocal fo-=t")
    elseif in_pattern(Tweaks.ft_patterns.tabstop, args.match) then
      vim.cmd(
      "setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal fo-=c")
    elseif in_pattern(Tweaks.ft_patterns.conceal, args.match) then
      vim.cmd("setlocal conceallevel=2 | setlocal concealcursor=nc | setlocal formatexpr=")
    elseif in_pattern(Tweaks.ft_patterns.indentkeys, args.match) then
      vim.cmd("setlocal indentkeys-=: | setlocal cinkeys-=:")
    elseif (args.match == "scala" or args.match == "sbt") and LSPDEF.advanced_config.scala == true then
      local cfg = require("metals").bare_config()
      cfg.capabilities = require("lsp.config").get_lsp_capabilities()
      cfg.on_attach = ON_LSP_ATTACH
      cfg.settings = {
        metalsBinaryPath = LSPDEF.server_bin["metals"]
      }
      require("metals").initialize_or_attach(cfg)
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

local old_mode

autocmd({ 'WinEnter' }, {
  pattern = '*',
  callback = function()
    if Wsplit.content == 'info' then
      CGLOBALS.get_bufsize()
      vim.schedule(function() Wsplit.refresh("WinEnter (auto.lua)") end)
    end

    local filetype = vim.bo.filetype
    if vim.tbl_contains(Tweaks.ft_patterns.enter_leave, filetype) then
      vim.cmd("setlocal winhl=CursorLine:TreeCursorLine,Normal:TreeNormalNC | hi nCursor blend=100")
    end
    -- HACK: NvimTree and outline windows will complain about the buffer being not modifiable
    -- when insert mode is active. So stop it and remember its state
    if filetype == "NvimTree" or filetype == "SymbolsSidebar" then
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
    if vim.tbl_contains(Tweaks.ft_patterns.enter_leave, filetype) then
      vim.cmd("hi nCursor blend=0")
    end
    -- HACK: restore the insert mode if it was active when changing to the NvimTree or outline
    -- split.
    if filetype == "neo-tree" or filetype == "NvimTree" or filetype == "SymbolsSidebar" then
      if old_mode == 'i' then
        old_mode = ''
        vim.cmd.startinsert()
      end
    end
  end,
  group = agroup_hl
})

--- refresh the outline view when a LSP server attaches
autocmd({ 'LspAttach' }, {
  pattern = "*",
  callback = function(args)
    if vim.bo[args.buf].ft == "razor" then
      vim.cmd("hi! link @lsp.type.field Member")
    end
    if Wsplit.content == "info" then Wsplit.refresh("LspAttach (auto.lua)") end
  end
})

local delcmd = nil
local _delayloaded = false

local function _delcmd()
  if delcmd ~= nil and _delayloaded == true then
    vim.api.nvim_del_autocmd(delcmd)
  end
end

-- one time setup tasks which must be done after the first
-- file has been loaded
delcmd = autocmd({ "BufReadPost" }, {
  callback = function()
    if _delayloaded == true then
      return
    end
    _delayloaded = true
    -- require("subspace.content.pairs").setup()
    require("subspace.content.move").setup()
    vim.g.setkey( "v", "<A-l>", function() MiniMove.move_selection("right") end)
    vim.g.setkey( "v", "<A-h>", function() MiniMove.move_selection("left") end)
    vim.g.setkey( "v", "<A-k>", function() MiniMove.move_selection("up") end)
    vim.g.setkey( "v", "<A-j>", function() MiniMove.move_selection("down") end)
    vim.g.setkey( "n", "<A-l>", function() MiniMove.move_line("right") end)
    vim.g.setkey( "n", "<A-h>", function() MiniMove.move_line("left") end)
    vim.g.setkey( "n", "<A-k>", function() MiniMove.move_line("up") end)
    vim.g.setkey( "n", "<A-j>", function() MiniMove.move_line("down") end)
    vim.defer_fn(function() require("plugins.commandpalette") end, 200)
    if PCFG.outline_view ~= false or PCFG.minimap_view > 0 then
      vim.defer_fn(function()
        if PCFG.outline_view ~= false then CGLOBALS.open_outline() end
        if PCFG.minimap_view > 0 then require("neominimap.api").toggle() end
      end, 1000)
    end
    vim.schedule(function() _delcmd() end)
  end
})

-- watches BufDelete and shuts down unused LSP servers
if LSPDEF.auto_shutdown then
  autocmd({ "BufDelete" }, {
    callback = function(_)
      vim.defer_fn(function() require("subspace.lib").StopLsp(true) end, 2000)
    end,
    group = agroup_views
  })
end

local lspcmd = nil
local lsp_done = false

lspcmd = autocmd({ "BufReadPre" --[[, "BufNewFile"]] }, {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or vim.bo[args.buf].buflisted == false then return end
    if not lsp_done then
      require("lsp.config").setup()
      lsp_done = true
    end
    vim.schedule(function()
      if lspcmd ~= nil and lsp_done == true then
        vim.api.nvim_del_autocmd(lspcmd)
      end
    end)
  end,
  group = agroup_views
})

autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
    local copy_to_unnamedplus = require("vim.ui.clipboard.osc52").copy("+")
    copy_to_unnamedplus(vim.v.event.regcontents)
    local copy_to_unnamed = require("vim.ui.clipboard.osc52").copy("*")
    copy_to_unnamed(vim.v.event.regcontents)
  end,
})

