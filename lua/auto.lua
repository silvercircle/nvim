-- this file handles all auto commands and event handling.

-- autogroups
local autocmd = vim.api.nvim_create_autocmd
local agroup_views = vim.api.nvim_create_augroup("views", {})
local agroup_hl = vim.api.nvim_create_augroup("hl", {})
local Wsplit = require("subspace.content.wsplit")
Wsplit.freeze = true
local Usplit = require("subspace.content.usplit")
local Tsc = require("treesitter-context")
local marks = require("subspace.lib.marks")
local treeft = Tweaks.tree.filetype

-- local ibl = require('indent_blankline')

local function refresh_outline_providerinfo()
  local _o = CGLOBALS.findWinByFiletype("Outline")
  if #_o > 0 and _o[1] ~= nil then
    local p = require("outline")._get_sidebar().provider
    local name = (p and p.name) and p.name or "No provider"
    vim.api.nvim_win_set_option(_o[1], "statusline", "  Outline (" .. name .. ")")
  end
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
      vim.api.nvim_buf_set_option(bufnr, "textwidth", tonumber(val))
    end
    econfig.properties.formatoptions = function(bufnr, val, _)
      vim.api.nvim_buf_set_option(bufnr, "formatoptions", val)
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
          Wsplit.refresh()
          local status = CGLOBALS.is_outline_open()
          local tree = CGLOBALS.findWinByFiletype(treeft)
          if status.outline ~= 0 then
            PCFG.outline.width = vim.api.nvim_win_get_width(status.outline)
          end
          if status.aerial ~= 0 then
            PCFG.outline.width = vim.api.nvim_win_get_width(status.aerial)
          end
          if PCFG.outline.width < CFG.outline_width then
            PCFG.outline.width = CFG.outline_width
          end
          if #tree > 0 and tree[1] ~= nil then
            PCFG.tree.width = vim.api.nvim_win_get_width(tree[1])
            if PCFG.tree.width < CFG.filetree_width then
              PCFG.tree.width = CFG.filetree_width
            end
          end
        end
      end,
      group = agroup_views
    })
    vim.api.nvim_command("wincmd p")
    if PCFG.weather.active == true then
      Wsplit.freeze = true
      Wsplit.content = PCFG.weather.content
      Wsplit.content_set_winid(CGLOBALS.main_winid)
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
    if vim.api.nvim_buf_get_option(args.buf, "buftype") == '' then
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
    Wsplit.content_set_winid(vim.fn.win_getid())
    if Wsplit.content == 'info' then
      vim.schedule(function() Wsplit.refresh() end)
    end
    marks.BufWinEnterHandler(args) -- update marks in sign column
    vim.schedule(function() require("lualine").refresh() end)
    vim.schedule(function() refresh_outline_providerinfo() end)
  end,
  group = agroup_views
})

-- restore view when reading a file
autocmd({ 'BufReadPost' }, {
  pattern = "*",
  callback = function(args)
    vim.api.nvim_buf_set_var(0, "tsc", PCFG.treesitter_context)
    vim.api.nvim_buf_set_var(0, "inlayhints", PCFG.lsp.inlay_hints)
    if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(args.buf, "buftype") ~= 'nofile' then
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

-- for these file types we want spellcheck
autocmd({ 'FileType' }, {
  pattern = { 'tex', 'markdown', 'text', 'telekasten', 'liquid', 'typst' },
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
--autocmd({ "Filetype" }, {
--  pattern = Config.treesitter_types,
--  callback = function()
--    vim.treesitter.start()
--  end,
--  group = agroup_hl
--})
-- pattern for which the indent and tabstop options must be set.
local tabstop_pattern = { 'vim', 'nim', 'python', 'lua', 'json', 'html', 'css', 'dart', 'go' }
-- filetypes for which we want conceal enabled
local conceal_pattern = { "markdown", "telekasten", "liquid" }

-- generic FileType handler adressing common actions
autocmd({ 'FileType' }, {
  pattern = { "Outline", "mail", "qf", "replacer", "Trouble",
    'vim', 'nim', 'python', 'lua', 'json', 'html', 'css', 'dart', 'go',
    "markdown", "telekasten", "liquid", "Glance", "scala", "sbt" },
  callback = function(args)
    if args.match == "Outline" then
      vim.cmd(
      "silent! setlocal foldcolumn=0 | silent! setlocal signcolumn=no | silent! setlocal nonumber | silent! setlocal statusline=\\ \\ Outline" ..
      "\\ (" ..
      PCFG.outline_filetype ..
      ") | setlocal winhl=Normal:TreeNormalNC,CursorLine:TreeCursorLine | hi nCursor blend=0")
      -- aerial can set its own statuscolumn
      vim.cmd("silent! setlocal statuscolumn=")
      vim.api.nvim_win_set_width(0, PCFG.outline.width)
    elseif args.match == "mail" then
      vim.cmd("setlocal foldcolumn=0 | setlocal fo-=c | setlocal fo+=w | setlocal ff=unix | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de")
    elseif args.match == "Glance" then
      vim.defer_fn(function() vim.cmd("setlocal cursorline") end, 400)
    elseif args.match == "qf" or args.match == "replacer" then
      --if #__Globals.findwinbyBufType("sysmon") > 0 or #__Globals.findwinbyBufType("weather") > 0 then
      --  vim.cmd("setlocal statuscolumn=%#TreeNormalNC#\\  | setlocal signcolumn=no | setlocal nonumber | wincmd J")
      --else
      --  vim.cmd("setlocal statuscolumn=%#TreeNormalNC#\\  | setlocal signcolumn=no | setlocal nonumber")
      --end
      vim.cmd("setlocal winhl=Normal:TreeNormalNC,CursorLine:Visual | setlocal fo-=t")
      -- vim.api.nvim_win_set_height(__Globals.term.winid, PCFG.terminal.height)
    elseif args.match == "Trouble" then
      if CGLOBALS.term.winid ~= nil then
        vim.api.nvim_win_set_var(0, "termheight", PCFG.terminal.height)
      end
    elseif vim.tbl_contains(tabstop_pattern, args.match) then
      vim.cmd(
      "setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal fo-=c")
    elseif vim.tbl_contains(conceal_pattern, args.match) then
      vim.cmd("setlocal conceallevel=2 | setlocal concealcursor=nc | setlocal formatexpr=")
    -- metals, attach on filetype
    elseif args.match == "scala" or args.match == "sbt" then
      require("metals").initialize_or_attach({
        capabilities = CGLOBALS.get_lsp_capabilities(),
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
local enter_leave_filetypes = { "Outline", "NvimTree", "neo-tree", 'snacks_picker_list'  }
local old_mode

autocmd({ 'WinEnter' }, {
  pattern = '*',
  callback = function()
    Wsplit.content_set_winid(vim.fn.win_getid())
    if Wsplit.content == 'info' then
      CGLOBALS.get_bufsize()
      vim.schedule(function() Wsplit.refresh() end)
    end

    local filetype = vim.bo.filetype
    if vim.tbl_contains(enter_leave_filetypes, filetype) then
      vim.cmd("setlocal winhl=CursorLine:TreeCursorLine,Normal:TreeNormalNC | hi nCursor blend=100")
    end
    -- HACK: NvimTree and outline windows will complain about the buffer being not modifiable
    -- when insert mode is active. So stop it and remember its state
    if filetype == "neo-tree" or filetype == "NvimTree" or filetype == "Outline" then
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
    if filetype == "neo-tree" or filetype == "NvimTree" or filetype == "Outline" then
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
    require("outline").refresh()
    vim.schedule(function() refresh_outline_providerinfo() end)
  end
})

local delcmd = nil
local _delayloaded = false

local function _delcmd()
  if delcmd ~= nil and _delayloaded == true then
    vim.api.nvim_del_autocmd(delcmd)
  end
end

delcmd = autocmd( { 'BufReadPost' }, {
  callback = function()
    if _delayloaded == true then
      return
    end
    _delayloaded = true
    vim.defer_fn(function() require("plugins.commandpicker_addcommands") end, 200)
    if CFG.plain == false then
      --vim.system({ 'tmux', 'set', '-qg', 'allow-passthrough', 'all' }, { text = true })
    end
    vim.schedule(function() _delcmd() end)
  end
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

--- LSP progress handler for snacks.notifier
if Tweaks.notifier == "snacks" then
  local progress = vim.defaulttable()
  vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
      if not client or type(value) ~= "table" then
        return
      end
      local p = progress[client.id]

      for i = 1, #p + 1 do
        if i == #p + 1 or p[i].token == ev.data.params.token then
          p[i] = {
            token = ev.data.params.token,
            msg = ("`%3d%%` %s%s"):format(
              value.kind == "end" and 100 or value.percentage or 100,
              value.title or "",
              value.message and (" **%s**"):format(value.message) or ""
            ),
            done = value.kind == "end",
          }
          break
        end
      end

      local msg = {} ---@type string[]
      progress[client.id] = vim.tbl_filter(function(v)
        return table.insert(msg, v.msg) or not v.done
      end, p)

      local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
      vim.notify(table.concat(msg, "\n"), "info", {
        id = "lsp_progress",
        title = client.name,
        opts = function(notif)
          notif.icon = #progress[client.id] == 0 and " "
            or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
        end,
      })
    end,
  })
end
