-- this file handles all auto commands and event handling.

-- autogroups
local autocmd = vim.api.nvim_create_autocmd
local agroup_views = vim.api.nvim_create_augroup("views", {})
local agroup_hl = vim.api.nvim_create_augroup("hl", {})
local Wsplit = require("subspace.content.wsplit")
local Tsc = require("treesitter-context")
local marks = require("subspace.lib.marks")
local treeft = Tweaks.tree.filetype

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
local function main_layout(curtab)
  if CFG.plain == false then
    if PCFG.terminal.active == true then
      vim.schedule(function() TABM.termToggle(PCFG.terminal.height) vim.fn.win_gotoid(TABM.T[curtab].id_main) end)
    end
    if PCFG.tree.active == true then
      TABM.open_tree()
    end
    -- create the WinResized watcher to keep track of the terminal split height.
    -- also call the resize handlers for the usplit/wsplit frames.
    -- keep track of tree/outline window widths
    autocmd({ "WinClosed", "WinResized" }, {
      callback = function(sizeevent)
        require("subspace.content.usplit").resize_or_closed(sizeevent)
        local ct = vim.api.nvim_get_current_tabpage()
        local usplit_id_win = TABM.T[ct].usplit.id_win
        local wsplit_id_win = TABM.T[ct].wsplit.id_win
        if sizeevent.event == "WinClosed" then
          if TABM.T[ct].term.id_win ~= nil and vim.api.nvim_win_is_valid(TABM.T[ct].term.id_win) == false then
            TABM.T[ct].term.id_win = nil
            TABM.T[ct].term.visible = false
          end
          if wsplit_id_win ~= nil and vim.api.nvim_win_is_valid(wsplit_id_win) == false then
            TABM.T[ct].wsplit.id_win = nil
          end
          if usplit_id_win ~= nil and vim.api.nvim_win_is_valid(usplit_id_win) == false then
            TABM.T[ct].usplit.id_win = nil
          end
          local id = sizeevent.match
          local status, target = pcall(vim.api.nvim_win_get_var, tonumber(id), "termheight")
          if status and TABM.T[ct].term.id_win ~= nil then
            vim.schedule(function() vim.api.nvim_win_set_height(TABM.T[ct].term.id_win, tonumber(target)) end)
          end
        end
        if sizeevent.event == "WinResized" then
          if TABM.T[ct].term.id_win ~= nil then
            PCFG.terminal.height = vim.api.nvim_win_get_height(TABM.T[ct].term.id_win)
            TABM.T[ct].term.height = vim.api.nvim_win_get_height(TABM.T[ct].term.id_win)
          end
          Wsplit.set_minheight()
          Wsplit.refresh("resize")
          local status = TABM.is_outline_open()
          local tree = TABM.findWinByFiletype(treeft)
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
      TABM.T[curtab].wsplit.content = PCFG.weather.content
      TABM.T[curtab].wsplit.content_id_win = TABM.T[TABM.active].id_main
    end
    if PCFG.sysmon.active then
      TABM.T[curtab].usplit.content = PCFG.sysmon.content
    end
    if PCFG.transbg == true then
      CFG.theme.set_bg()
    end
  end
  vim.fn.win_gotoid(TABM.T[curtab].id_main)
end

-- on UIEnter show a terminal split and a left-hand nvim-tree file explorer. Unless the
-- environment variable or command line option forbids it for better startup performance and
-- a clean UI

autocmd({ "UIEnter" }, {
  callback = function()
    if did_UIEnter == true then
      return
    end
    did_UIEnter = true
    local curtab = vim.api.nvim_get_current_tabpage()
    TABM.active = curtab
    TABM.new(curtab)
    TABM.T[curtab].id_main = vim.fn.win_getid()
    main_layout(curtab)
  end
})

-- force refresh lualine on ModeChanged event. This allows for higher debounce timers
-- (= better performance) and still get instant response for mode changes (which I feel
-- is important)
--
local cline_hl_groups = {
  ["i"] = "CursorLineInsert",
  ["v"] = "CursorLineVisual"
}

autocmd({ "ModeChanged" }, {
  pattern = "*",
  callback = function()
    vim.schedule(function()
      local mode = vim.fn.mode()
      vim.api.nvim_set_hl(0, "CursorLine", { link = cline_hl_groups[mode] or "CursorLineNC" })
      require("lualine").refresh()
    end)
  end,
  group = agroup_views
})

-- create a view to save folds when saving the file
autocmd( {'BufWritePost' }, {
  pattern = "*",
  callback = function()
    if Tweaks.mkview_on_save == true then
      CGLOBALS.mkview()
    end
  end,
  group = agroup_views
})

-- when config.mkview_on_leave is true, create a view when a buffer loses focus
autocmd({'BufWinLeave'}, {
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
    if TABM.T[TABM.active] and TABM.T[TABM.active].wsplit.content == 'info' then
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

-- generic FileType handler adressing common actions
-- see Tweaks.ft_patterns
autocmd({ "FileType" }, {
  pattern = "*",
  --pattern = { "SymbolsSidebar", "mail", "qf", "replacer",
  --  "vim", "nim", "python", "c", "cpp", "lua", "json", "html", "css", "dart", "go",
  --  "markdown", "telekasten", "liquid", "Glance", "scala", "sbt" },
  callback = function(args)
    if vim.tbl_contains(CFG.treesitter_types, args.match) or vim.tbl_contains(CFG.treesitter_types_builtin, args.match) then
      vim.treesitter.start()
    end
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
      cfg.init_options.statusBarProvider = "off"
      cfg.capabilities = require("lsp.config").get_lsp_capabilities()
      cfg.on_attach = ON_LSP_ATTACH
      cfg.settings = {
        enableSemanticHighlighting = true,
        showImplicitArguments = true,
        excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
        metalsBinaryPath = vim.fn.expand(LSPDEF.server_bin["metals"]),
        --serverProperties = {
        --  "-Xmx1G", "-XX:+UseParallelGC", "-XX:MaxGCPauseMillis=200", "-XX:+ScavengeBeforeFullGC", "-XX:+UseStringDeduplication",
        --  "-XX:MaxHeapFreeRatio=85", "-XX:ConcGCThreads=2", "-XX:ParallelGCThreads=2", "-XX:ReservedCodeCacheSize=256m",
        --  "-XX:+AlwaysPreTouch", "-XX:+UseCompressedOops", "-XX:SoftRefLRUPolicyMSPerMB=50"
        --},
        serverProperties = {
          "-Xmx1G", "-XX:+UseSerialGC", "-XX:MaxGCPauseMillis=200", "-XX:+ScavengeBeforeFullGC",
          "-XX:MaxHeapFreeRatio=85", "-XX:ReservedCodeCacheSize=256m", "-XX:+UseStringDeduplication",
          "-XX:+AlwaysPreTouch", "-XX:+UseCompressedOops", "-XX:SoftRefLRUPolicyMSPerMB=50"
        },
        --serverProperties = {
        --  "-Xms512M", "-Xmx768M", "--add-modules=jdk.incubator.vector", "-XX:+UseG1GC", "-XX:+ParallelRefProcEnabled",
        --  "-XX:MaxGCPauseMillis=200", "-XX:+UnlockExperimentalVMOptions", "-XX:+DisableExplicitGC", "-XX:+AlwaysPreTouch",
        --  "-XX:G1HeapWastePercent=5", "-XX:G1MixedGCCountTarget=4", "-XX:InitiatingHeapOccupancyPercent=15",
        --  "-XX:G1MixedGCLiveThresholdPercent=90", "-XX:G1RSetUpdatingPauseTimePercent=5", "-XX:SurvivorRatio=32",
        --  "-XX:+PerfDisableSharedMem", "-XX:MaxTenuringThreshold=1", "-XX:G1NewSizePercent=30", "-XX:G1MaxNewSizePercent=40",
        --  "-XX:G1HeapRegionSize=8M", "-XX:G1ReservePercent=20"
        --},
        inlayHints = {
          byNameParameters = { enable = true },
          hintsInPatternMatch = { enable = true },
          implicitArguments = { enable = true },
          implicitConversions = { enable = true },
          inferredTypes = { enable = true },
          typeParameters = { enable = true },
        }
      }
      require("metals").initialize_or_attach(cfg)
    end
  end,
  group = agroup_hl
})

autocmd( {'CmdlineEnter' }, {
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
    if TABM.T[TABM.active] and TABM.T[TABM.active].wsplit.content == 'info' then
      CGLOBALS.get_bufsize()
      vim.schedule(function() Wsplit.refresh("WinEnter (auto.lua)") end)
    end

    local filetype = vim.bo.filetype
    if vim.tbl_contains(Tweaks.ft_patterns.enter_leave, filetype) then
      vim.cmd("setlocal winhl=CursorLine:TreeCursorLine,Normal:TreeNormalNC | hi nCursor blend=100")
    end
    -- HACK: NvimTree and outline windows will complain about the buffer being not modifiable
    -- when insert mode is active. So stop it and remember its state
    if filetype == Tweaks.tree.filetype or filetype == "SymbolsSidebar" then
      old_mode = vim.api.nvim_get_mode().mode
      vim.cmd.stopinsert()
    end
    local tab = TABM.get()
    if tab.id_page == vim.api.nvim_get_current_tabpage() then
      tab.id_cur = vim.fn.win_getid()
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
    if filetype == Tweaks.tree.filetype or filetype == "SymbolsSidebar" then
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
    if TABM.T[TABM.active].wsplit.content == "info" then Wsplit.refresh("LspAttach (auto.lua)") end
    if TABM.T[TABM.active].id_tree and Tweaks.tree.version == "Neo" then
      if require("neo-tree.sources.manager").get_state_for_window(TABM.T[TABM.active].id_tree).name == "document_symbols" then
        vim.cmd("Neotree source=document_symbols show")
      end
    end
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
    require("subspace.content.move").setup()
    CGLOBALS.configure_treesitter()
    vim.g.setkey( "v", "<A-l>", function() MiniMove.move_selection("right") end)
    vim.g.setkey( "v", "<A-h>", function() MiniMove.move_selection("left") end)
    vim.g.setkey( "v", "<A-k>", function() MiniMove.move_selection("up") end)
    vim.g.setkey( "v", "<A-j>", function() MiniMove.move_selection("down") end)
    vim.g.setkey( "n", "<A-l>", function() MiniMove.move_line("right") end)
    vim.g.setkey( "n", "<A-h>", function() MiniMove.move_line("left") end)
    vim.g.setkey( "n", "<A-k>", function() MiniMove.move_line("up") end)
    vim.g.setkey( "n", "<A-j>", function() MiniMove.move_line("down") end)
    vim.defer_fn(function() require("plugins.commandpalette") end, 200)
    if PCFG.outline_view ~= false or PCFG.minimap_view ~= false then
      vim.defer_fn(function()
        if PCFG.outline_view ~= false then TABM.open_outline() end
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

autocmd("TabNew", {
  callback = function()
    local curtab = vim.api.nvim_get_current_tabpage()
    TABM.new(curtab)
    TABM.T[curtab].id_main = vim.fn.win_getid()
    TABM.T[curtab].id_cur = vim.fn.win_getid()
  end,
  group = agroup_views
})

autocmd("TabClosed", {
  callback = function(_)
    vim.schedule(function() TABM.cleaner() end)
  end,
  group = agroup_views
})

autocmd("TabEnter", {
  callback = function()
    TABM.set_active()
  end,
  group = agroup_views
})

autocmd("WinNew", {
  callback = function()
    vim.schedule(function()
      if vim.b.hover_preview ~= nil and vim.api.nvim_win_get_config(vim.b.hover_preview).relative == "win" then
        vim.api.nvim_set_option_value("foldcolumn", "0", { win = vim.b.hover_preview })
      end
    end)
  end,
  group = agroup_views
})
