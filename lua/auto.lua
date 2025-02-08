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

--- this function configures the UI layout on UIEnter
local function main_layout()
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
      --local timer = vim.uv.new_timer()
      --timer:start(500, 0, vim.schedule_wrap(function() __Globals.open_tree() vim.fn.win_gotoid(__Globals.main_winid) end))
      __Globals.open_tree()
    end
    if __Globals.perm_config.terminal.active == true then
      vim.schedule(function() __Globals.termToggle(__Globals.perm_config.terminal.height) vim.fn.win_gotoid(__Globals.main_winid) end)
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
if vim.g.tweaks.statusline.version == "lualine" then
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
    vim.schedule(function() require("lualine").refresh() end)
  end,
  group = agroup_views
})

-- restore view when reading a file
if Config.nightly then
  autocmd({ 'BufReadPost' }, {
    pattern = "*",
    callback = function(args)
      vim.api.nvim_buf_set_var(0, "tsc", __Globals.perm_config.treesitter_context)
      if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(args.buf, "buftype") ~= 'nofile' then
        -- this is ugly, but it apparently works with the async parser for now.
        vim.treesitter.get_parser():parse(true, function() vim.cmd("silent! loadview") end)
        --vim.cmd("silent! loadview")
      end
    end,
    group = agroup_views
  })
else
  autocmd({ 'BufReadPost' }, {
    pattern = "*",
    callback = function(args)
      vim.api.nvim_buf_set_var(0, "tsc", __Globals.perm_config.treesitter_context)
      if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(args.buf, "buftype") ~= 'nofile' then
        vim.cmd("silent! loadview")
      end
    end,
    group = agroup_views
  })
end

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
      vim.cmd("setlocal winhl=CursorLine:TreeCursorLine | hi nCursor blend=100 | set statuscolumn=")
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
local enter_leave_filetypes = { "DressingSelect", "aerial", "Outline", "NvimTree", "neo-tree", 'snacks_picker_list'  }
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
  callback = function()
    require("outline").refresh()
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
    local timer = vim.uv.new_timer()
    timer:start(1000, 0, vim.schedule_wrap(function()
      local fkeys = vim.g.fkeys
      local fzf_tweaks = vim.g.tweaks.fzf
      local fzf = require("fzf-lua")
      local lutils = require("local_utils")
      local lsputil = require("lspconfig.util")
      local Terminal  = require('toggleterm.terminal').Terminal
      -- require("telescope")
      local noremap = true
      require("local_utils.cmdpalette").setup({
        keys = {
          {
            desc = "Show notification history",
            cmd = function() require("local_utils").notification_history() end,
            keys = {
              { "n", vim.g.tweaks.keymap.utility_key .. "<C-n>", noremap },
              { "i", vim.g.tweaks.keymap.utility_key .. "<C-n>", noremap }
            },
            category = "@Notifications"
          },
          {
            desc = "Show all bookmarks (Snacks picker)",
            cmd = function()
              local layout = __Globals.gen_snacks_picker_layout({
                preset = "select",
                preview = true,
                width = 120,
                height = 0.7,
                psize = 12,
                input = "bottom",
                title = "Select Bookmark"
              })
              require("plugins.bookmarkspicker").open({ layout = layout })
            end,
            keys = {
              { "n", "<A-b>", noremap },
              { "i", "<A-b>", noremap },
            },
            category = "@Bookmarks"
          },
          {
            desc = "Show favorite folders",
            cmd = function() require "quickfavs".Quickfavs(false) end,
            keys = { "n", "<f12>", },
            category = "@Bookmarks"
          },
          {
            desc = "Show favorite folders (rescan fav file)",
            cmd = function() require "quickfavs".Quickfavs(true) end,
            keys = { "n", fkeys.s_f12, },
            category = "@Bookmarks"
          },
          {
            desc = "LSP server info",
            cmd = "LspInfo",
            keys = { "n", "lsi", noremap },
            category = "@LSP"
          },
          {
            desc = "Peek definitions (Glance plugin)",
            cmd = function() require("glance").open("definitions") end,
            keys = { "n", fkeys.s_f4, noremap },
            category = "@LSP"
          },
          {
            desc = "Peek references (Glance plugin)",
            cmd = function() require("glance").open("references") end,
            keys = { "n", "<f4>", noremap },
            category = "@LSP"
          },
          {
            desc = "LSP diagnostics",
            cmd = function() vim.diagnostic.setloclist() end,
            keys = { "n", "le", noremap },
            category = "@LSP"
          },
          {
            desc = "LSP jump to type definition",
            cmd = function() vim.lsp.buf.type_definition() end,
            keys = {
              { "n", "<C-x>t", noremap },
              { "i", "<C-x>t", noremap }
            },
            category = "@LSP"
          },
          {
            desc = "Shutdown LSP server",
            cmd = function() lutils.StopLsp() end,
            keys = { "n", "lss", noremap },
            category = "@LSP"
          },
          -- LSP Diagnostics
          {
            desc = "Show diagnostic popup",
            cmd = function() vim.diagnostic.open_float() end,
            keys = { "n", "DO", noremap },
            category = "@LSP Diagnostics"
          },
          {
            desc = "Go to next diagnostic",
            cmd = function() vim.diagnostic.goto_next() end,
            keys = { "n", "DN", noremap },
            category = "@LSP Diagnostics"
          },
          {
            desc = "Go to previous diagnostic",
            cmd = function() vim.diagnostic.goto_prev() end,
            keys = { "n", "DP", noremap },
            category = "@LSP Diagnostics"
          },
          {
            desc = "Code action",
            cmd = function() vim.lsp.buf.code_action() end,
            keys = { "n", "DA", },
            category = "@LSP Diagnostics"
          },
          {
            desc = "Reset diagnostics",
            cmd = function() vim.diagnostic.reset() end,
            keys = { "n", "DR", },
            category = "@LSP Diagnostics"
          },
          {
            -- open a float term with lazygit.
            -- use the path of the current buffer to find the .git root. The LSP utils are useful here
            desc = "FloatTerm lazygit",
            cmd = function()
              local path = lsputil.root_pattern(".git")(vim.fn.expand("%:p"))
              path = path or "."
              local lazygit = Terminal:new({
                cmd = "lazygit",
                direction = "float",
                dir = path,
                -- refresh neo-tree display to reflect changes in git status
                -- TODO: implement for nvim-tree?
                on_close = function()
                  if vim.g.tweaks.tree.version == "Neo" then
                    vim.schedule(function() require("neo-tree.command").execute({ action = "show" }) end)
                  end
                end,
                hidden = false
              })
              lazygit:toggle()
            end,
            keys = {
              { "n", "<f6>", noremap },
              { "i", "<f6>", noremap },
            },
            category = "@GIT"
          },
          {
            -- open a markdown preview using IMD
            desc = "Floatterm IMD",
            cmd = function()
              local path = vim.fn.expand("%:p")
              local cmd = "imd '" .. path .. "'"
              local imd = Terminal:new({
                cmd = cmd,
                direction = "float",
                float_opts = {
                  width = 150
                },
                hidden = false
              })
              imd:toggle()
            end,
            keys = { -- Shift-F6
              { "n", fkeys.s_f6, noremap },
              { "i", fkeys.s_f6, noremap },
            },
            category = "@Markdown"
          },
          {
            -- open a markdown preview using lightmdview
            desc = "View Markdown in GUI viewer (" .. vim.g.tweaks.mdguiviewer .. ")",
            cmd = function()
              local path = vim.fn.expand("%:p")
              local cmd = "silent !" .. vim.g.tweaks.mdguiviewer .. " '" .. path .. "' &"
              vim.cmd.stopinsert()
              vim.schedule(function() vim.cmd(cmd) end)
            end,
            keys = { -- Ctrl-F6
              { "n", fkeys.c_f6, noremap },
              { "i", fkeys.c_f6, noremap },
            },
            category = "@Markdown"
          },
          {
            -- open a document viewer zathura view and view the tex document as PDF
            desc = "View LaTeX result (" .. vim.g.tweaks.texviewer .. ")",
            cmd = lutils.view_latex(),
            keys = { -- shift-f9
              { "n", fkeys.s_f9, noremap },
              { "i", fkeys.s_f9, noremap },
            },
            category = "@LaTeX"
          },
          {
            -- recompile the .tex document using lualatex
            desc = "Recompile LaTeX document",
            cmd = lutils.compile_latex(),
            keys = {
              { "n", "<f9>", noremap },
              { "i", "<f9>", noremap },
            },
            category = "@LaTeX"
          },
          -- format with the LSP server
          -- note: ranges are not supported by all LSP
          {
            desc = "LSP Format document or range",
            cmd = function() vim.lsp.buf.format() end,
            keys = { -- shift-f7
              { "n", fkeys.s_f7, noremap },
              { "i", fkeys.s_f7, noremap },
              { "v", fkeys.s_f7, noremap },
            },
            category = "@Formatting"
          },
          {
            desc = "Inspect auto word list (wordlist plugin)",
            cmd = function() require(vim.g.tweaks.completion.version == "nvim-cmp" and "cmp_wordlist" or "blink-cmp-wordlist").autolist() end,
            keys = { "n", "<leader>zw", noremap },
            category = "@Neovim"
          },
          {
            desc = "Colorizer Toggle",
            cmd = function()
              local c = require("colorizer")
              if c.is_buffer_attached(0) then c.detach_from_buffer(0) else c.attach_to_buffer(0) end
            end,
            keys = { "n", "ct", noremap },
            category = "@Neovim"
          },
          {
            desc = "Debug toggle",
            cmd = function()
              __Globals.toggle_debug()
            end,
            keys = { "n", "dbg", noremap },
            category = "@Neovim"
          },
          {
            desc = "Treesitter tree",
            cmd = function()
              vim.treesitter.inspect_tree({ command = "rightbelow 36vnew" })
              vim.o.statuscolumn = ""
            end,
            keys = { "n", "tsp", noremap },
            category = "@Neovim"
          },
          {
            desc = "GitSigns next hunk",
            cmd = function() require("gitsigns").next_hunk() end,
            keys = {
              { "n", "<C-x><Down>", noremap },
              { "i", "<C-x><Down>", noremap }
            },
            category = "@GIT"
          },
          {
            desc = "GitSigns previous hunk",
            cmd = function() require("gitsigns").prev_hunk() end,
            keys = {
              { "n", "<C-x><Up>", noremap },
              { "i", "<C-x><Up>", noremap }
            },
            category = "@GIT"
          },
          {
            desc = "GitSigns preview hunk",
            cmd = function() require("gitsigns").preview_hunk() end,
            keys = {
              { "n", "<C-x>h", noremap },
              { "i", "<C-x>h", noremap }
            },
            category = "@GIT"
          },
          {
            desc = "GitSigns diff this",
            cmd = function() require("gitsigns").diffthis() end,
            keys = {
              { "n", "<C-x><C-d>", noremap },
              { "i", "<C-x><C-d>", noremap }
            },
            category = "@GIT"
          },
          {
            desc = "Configure CMP layout",
            cmd = function() require("plugins.cmp_setup").select_layout() end,
            keys = {
              { "n", "<leader>cc", noremap },
            },
            category = "@Setup"
          },
          {
            desc = "Toggle CMP autocomplete",
            cmd = function() __Globals.toggle_autocomplete() end,
            keys = {
              { "n", "<leader>ca", noremap },
            },
            category = "@Setup"
          },
          {
            desc = "ZK tags",
            cmd = function()
              require("telescope").extensions.zk.tags(__Telescope_vertical_dropdown_theme({ layout_config = { preview_height = 0.7, width = 0.5, height = 0.9 } }))
            end,
            keys = {
              { "n", "zkt", noremap },
            },
            category = "@ZK"
          },
          {
            desc = "ZK notes",
            cmd = function()
              require("telescope").extensions.zk.notes(__Telescope_vertical_dropdown_theme({ layout_config = { preview_height = 15, width = 0.5, height = 0.9 } }))
            end,
            keys = {
              { "n", "zkn", noremap },
            },
            category = "@ZK"
          },
          {
            desc = "Command history (FZF)",
            cmd = function() require("snacks").picker.command_history({ layout = __Globals.gen_snacks_picker_layout({ input = "top", width = 140, height = 0.7, row = 7, preview = false }) }) end,
            keys = { "n", "<A-C>", noremap },
            category = "@FZF"
          },
          {
            desc = "Command list (FZF)",
            cmd = function() require("snacks").picker.commands({ layout = __Globals.gen_snacks_picker_layout({ input = "top", width = 80, height = 0.8, row = 7, preview = false }) }) end,
            keys = { "n", "<A-c>", noremap },
            category = "@FZF"
          },
          {
            desc = "Show notification history",
            cmd = function() require("local_utils").notification_history() end,
            keys = {
              { "n", vim.g.tweaks.keymap.utility_key .. "<C-n>" },
              { "i", vim.g.tweaks.keymap.utility_key .. "<C-n>" }
            },
            category = "@Notifications"
          },
          {
            desc = "Function without keys",
            cmd = function() vim.notify("that does nothing") end,
            category = "@Notifications"
          }
        },
        columns = {
          desc = {width = 43, hl = "Fg"}
        },
        width = 120,
        height = 10
      })
      require("local_utils.cmdpalette").add({
        {
          desc = "FZF-LUA resume",
          cmd = function()
            fzf.resume({ winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "i", vim.g.tweaks.keymap.fzf_prefix .. "r",  noremap },
            { "n", vim.g.tweaks.keymap.fzf_prefix .. "r",  noremap }
          },
          category = "@FZF"
        },
        {
          desc = "FZF-LUA quickfix list",
          cmd = function()
            fzf.quickfix({ winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "i", vim.g.tweaks.keymap.fzf_prefix .. "q",  noremap },
            { "n", vim.g.tweaks.keymap.fzf_prefix .. "q",  noremap }
          },
          category = "@FZF"
        },
        {
          desc = "FZF-LUA commands",
          cmd = function()
            fzf.builtin({ prompt = "Commands: ", winopts = fzf_tweaks.winopts.mini_list })
          end,
          keys = {
            { "i", vim.g.tweaks.keymap.fzf_prefix .. "<space>",  noremap },
            { "n", vim.g.tweaks.keymap.fzf_prefix .. "<space>",  noremap }
          },
          category = "@FZF"
        },
        {
          desc = "Zettelkasten files",
          cmd = function()
            fzf.files({ prompt = "Zettelkasten files: ", cwd = vim.fn.expand(vim.g.tweaks.zk.root_dir), fd_opts =
            "--type f --hidden --follow --exclude .obsidian --exclude .git --exclude .zk", winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "i", vim.g.tweaks.keymap.fzf_prefix .. "<C-z>",  noremap },
            { "n", vim.g.tweaks.keymap.fzf_prefix .. "<C-z>",  noremap }
          },
          category = "@ZK"
        },
        {
          desc = "Zettelkasten live grep",
          cmd = function()
            local wo = fzf_tweaks.winopts.std_preview_top
            fzf.live_grep({ prompt = "Zettelkasten live grep: ", cwd = vim.fn.expand(vim.g.tweaks.zk.root_dir), winopts = wo })
          end,
          keys = {
            { "i", vim.g.tweaks.keymap.fzf_prefix .. "z",  noremap },
            { "n", vim.g.tweaks.keymap.fzf_prefix .. "z",  noremap }
          },
          category = "@ZK"
        },
        {
          desc = "Spell suggestions",
          cmd = function() fzf.spell_suggest({ winopts = { height = 0.5, width = 60, preview = { hidden = "hidden" } } }) end,
          keys = {
            { "n", "<A-s>", noremap },
            { "i", "<A-s>", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "FZF Jumplist",
          cmd = function() fzf.jumps({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
          keys = {
            { "n", "<A-Backspace>", noremap },
            { "i", "<A-Backspace>", noremap },
          },
          category = "@FZF"
        },
        {
          desc = "Registers (FZF)",
          cmd = function() fzf.registers({ winopts = fzf_tweaks.winopts.std_preview_none }) end,
          keys = {
            { "i", "<C-x><C-r>", noremap },
            { "n", "<C-x><C-r>", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "Fuzzy search in current buffer",
          cmd = function()
            fzf.blines({ winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "n", "<C-x><C-f>", noremap },
            { "i", "<C-x><C-f>", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "Fuzzy search in all open buffers",
          cmd = function()
            fzf.lines({ winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "n", "<C-x>f", noremap },
            { "i", "<C-x>f", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "Todo list (current file)",
          cmd = function()
            local dir = vim.fn.expand("%:p:h")
            require("todo-comments.fzf").todo({
              cwd = dir, query = vim.fn.expand("%:t"), winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "n", "tdf",                                 noremap },
            { "i", vim.g.tweaks.keymap.fzf_prefix .. "f", noremap }
          },
          category = "@Neovim"
        },
        {
          desc = "Todo list (current directory)",
          cmd = function()
            local dir = vim.fn.expand("%:p:h")
            require("todo-comments.fzf").todo({
              cwd = dir, winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "n", "tdo",                                 noremap },
            { "i", vim.g.tweaks.keymap.fzf_prefix .. "t", noremap }
          },
          category = "@Neovim"
        },
        {
          desc = "Todo list (project root)",
          cmd = function()
            require("todo-comments.fzf").todo({
              cwd = lutils.getroot_current(), winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "n", "tdp",                                      noremap },
            { "i", vim.g.tweaks.keymap.fzf_prefix .. "<C-t>",  noremap }
          },
          category = "@Neovim"
        },
        {
          desc = "List all highlight groups (FZF)",
          cmd = function()
            fzf.highlights({
              winopts = fzf_tweaks.winopts.narrow_small_preview
            })
          end,
          keys = { "n", "thl", noremap },
          category = "@Neovim"
        },
        {
          desc = "FZF grep cword (current directory)",
          cmd = function() fzf.grep_cword({ cwd = vim.fn.expand("%:p:h"), winopts = fzf_tweaks.winopts.std_preview_top }) end,
          keys = {
            { "n", "<C-x><CR>", noremap },
            { "i", "<C-x><CR>", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "FZF grep cword (project root)",
          cmd = function()
            fzf.grep_cword({ cwd = lutils.getroot_current(), winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "n", "<C-x><Backspace>", noremap },
            { "i", "<C-x><Backspace>", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "FZF live grep (current directory)",
          cmd = function()
            fzf.live_grep({ query = lutils.get_selection(), cwd = vim.fn.expand("%:p:h"), winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "n", "<C-x>g", noremap },
            { "i", "<C-x>g", noremap },
            { "v", "<C-x>g", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "FZF live grep (project root)",
          cmd = function()
            fzf.live_grep({ query = lutils.get_selection(), cwd = lutils.getroot_current(), winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "n", "<C-x><C-g>", noremap },
            { "i", "<C-x><C-g>", noremap },
            { "v", "<C-x><C-g>", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "FZF live grep resume",
          cmd = function() fzf.live_grep_resume({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
          keys = {
            { "n", "<C-x>G", noremap },
            { "i", "<C-x>G", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "FZF find files (current directory)",
          cmd = function() fzf.files({ cwd = vim.fn.expand("%:p:h"), winopts = fzf_tweaks.winopts.big_preview_top }) end,
          keys = {
            { "i", fkeys.s_f8, noremap },
            { "n", fkeys.s_f8, noremap }
          },
          category = "@FZF"
        },
        {
          desc = "FZF files (project root)",
          cmd = function()
            fzf.files({
              cwd = lutils.getroot_current(),
              winopts = fzf_tweaks.winopts.big_preview_top
            })
          end,
          keys = {
            { "n", "<f8>", noremap },
            { "i", "<f8>", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "FZF marks",
          cmd = function()
            fzf.marks({
              winopts = fzf_tweaks.winopts.mini_with_preview,
            })
          end,
          keys = {
            { "n", "<C-x>m", noremap },
            { "i", "<C-x>m", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "FZF Helptags",
          cmd = function()
            fzf.helptags({
              winopts = fzf_tweaks.winopts.big_preview_topbig,
            })
          end,
          keys = {
            { "n", "<C-x><C-h>", noremap },
            { "i", "<C-x><C-h>", noremap }
          },
          category = "@FZF"
        },
        {
          desc = "GIT status (FZF)",
          cmd = function()
            fzf.git_status({
              cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
              winopts = fzf_tweaks.winopts.big_preview_topbig
            })
          end,
          keys = { "n", "tgs", noremap },
          category = "@GIT"
        },
        {
          desc = "GIT commits (project) (FZF)",
          cmd = function()
            fzf.git_commits({
              cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
              winopts = fzf_tweaks.winopts.big_preview_topbig
            })
          end,
          keys = { "n", "tgc", noremap },
          category = "@GIT"
        },
        {
          desc = "GIT commits (buffer) (FZF)",
          cmd = function()
            fzf.git_bcommits({ winopts = fzf_tweaks.winopts.big_preview_topbig })
          end,
          keys = { "n", "tgb", noremap },
          category = "@GIT"
        },
        {
          desc = "GIT files (FZF)",
          cmd = function()
            fzf.git_files({
              cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
              winopts = fzf_tweaks.winopts.big_preview_topbig
            })
          end,
          keys = { "n", "tgf", noremap },
          category = "@GIT"
        },
        {
          desc = "GIT branches (FZF)",
          cmd = function()
            fzf.git_branches({
              cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
              winopts = fzf_tweaks.winopts.big_preview_topbig
            })
          end,
          keys = { "n", "tgb", noremap },
          category = "@GIT"
        },
        {
          desc = "GIT tags (FZF)",
          cmd = function()
            fzf.git_tags({
              cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
              winopts = fzf_tweaks.winopts.big_preview_topbig
            })
          end,
          keys = { "n", "tgt", noremap },
          category = "@GIT"
        },
        {
          desc = "Jump to definition (FZF)",
          cmd = function() fzf.lsp_definitions({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
          keys = {
            { "n", "<C-x>d", noremap },
            { "i", "<C-x>d", noremap }
          },
          category = "@LSP FZF"
        },
        {
          desc = "Run diagnostics (workspace)",
          cmd = function()
            fzf.diagnostics_workspace({ cwd = lutils.getroot_current(), winopts = fzf_tweaks.winopts.big_preview_top })
          end,
          keys = {
            { "i", vim.g.tweaks.keymap.fzf_prefix .. "<C-d>", noremap },
            { "n", vim.g.tweaks.keymap.fzf_prefix .. "<C-d>", noremap }
          },
          category = "@LSP FZF"
        },
        {
          desc = "Run diagnostics (document)",
          cmd = function()
            fzf.diagnostics_document({ winopts = fzf_tweaks.winopts.big_preview_top })
          end,
          keys = {
            { "i", vim.g.tweaks.keymap.fzf_prefix .. "d", noremap },
            { "n", vim.g.tweaks.keymap.fzf_prefix .. "d", noremap }
          },
          category = "@LSP FZF"
        },
        {
          desc = "Dynamic workspace symbols (FZF)",
          cmd = function() fzf.lsp_live_workspace_symbols({ winopts = fzf_tweaks.winopts.big_preview_top }) end,
          keys = { "n", "tds", noremap },
          category = "@LSP FZF"
        },
        {
          desc = "Workspace symbols (FZF)",
          cmd = function() fzf.lsp_workspace_symbols({ winopts = fzf_tweaks.winopts.big_preview_top }) end,
          keys = { "n", "tws", noremap },
          category = "@LSP FZF"
        },
        {
          desc = "Incoming calls (FZF)",
          cmd = function() fzf.lsp_incoming_calls({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
          keys = {
            { "n", "<C-x>i", noremap },
            { "i", "<C-x>i", noremap },
          },
          category = "@LSP FZF"
        },
        {
          desc = "Outgoing calls (FZF)",
          cmd = function() fzf.lsp_outgoing_calls({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
          keys = {
            { "n", "<C-x>o", noremap },
            { "i", "<C-x>o", noremap },
          },
          category = "@LSP FZF"
        },
        {
          desc = "Document symbols (FZF)",
          cmd = function() fzf.lsp_document_symbols({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
          keys = {
            { "n", "<A-a>", noremap },
            { "i", "<A-a>", noremap }
          },
          category = "@LSP FZF"
        },
        {
          desc = "Mini document references (FZF)",
          cmd = function()
            fzf.lsp_references({ winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "i", "<A-r>", noremap },
            { "n", "<A-r>", noremap }
          },
          category = "@LSP FZF"
        },
        {
          desc = "Mini document symbols (FZF)",
          cmd = function()
            fzf.lsp_document_symbols({ winopts = fzf_tweaks.winopts.mini_with_preview })
          end,
          keys = {
            { "n", "<A-o>", noremap },
            { "i", "<A-o>", noremap }
          },
          category = "@LSP FZF"
        },
        {
          desc = "LSP finder (FZF)",
          cmd = function()
            fzf.lsp_finder({ winopts = fzf_tweaks.winopts.std_preview_top })
          end,
          keys = {
            { "n", "<A-f>", noremap },
            { "i", "<A-f>", noremap }
          },
          category = "@LSP FZF"
        }
      })
      vim.schedule(function() _delcmd() end)
    end))
  end
})

