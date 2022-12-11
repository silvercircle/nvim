-----------------------------
-- unused features and code segments, mainly from lsp configuration
-----------------------------
-- we use Glance and Telescope plugins for peek and friends
_G.PeekDefinition = function(lsp_request_method)
  local params = vim.lsp.util.make_position_params()
  local definition_callback = function(_, result, ctx, config)
    -- This handler previews the jump location instead of actually jumping to it
    -- see $VIMRUNTIME/lua/vim/lsp/handlers.lua, function location_handler
    if result == nil or vim.tbl_isempty(result) then
      print("PeekDefinition: " .. "cannot find the definition.")
      return nil
    end
    --- either Location | LocationLink
    --- https://microsoft.github.io/language-server-protocol/specification#location
    local def_result = result[1]

    -- Peek defintion. Currently, use quickui but a better alternative should be found.
    -- vim.lsp.util.preview_location(result[1])
    local def_uri = def_result.uri or def_result.targetUri
    local def_range = def_result.range or def_result.targetSelectionRange
    vim.fn["quickui#preview#open"](vim.uri_to_fname(def_uri), {
      cursor = def_range.start.line + 1,
      number = 1, -- show line number
      persist = 0,
    })
  end
  -- Asynchronous request doesn't work very smoothly, so we use synchronous one with timeout;
  -- return vim.lsp.buf_request(0, 'textDocument/definition', params, definition_callback)
  lsp_request_method = lsp_request_method or "textDocument/definition"
  local results, err = vim.lsp.buf_request_sync(0, lsp_request_method, params, 1000)
  if results then
    for client_id, result in pairs(results) do
      definition_callback(client_id, result.result)
    end
  else
    print("PeekDefinition: " .. err)
  end
end

do -- Commands and Keymaps for PeekDefinition
  vim.cmd([[
    command! -nargs=0 PeekDefinition      :lua _G.PeekDefinition()
    command! -nargs=0 PreviewDefinition   :PeekDefinition
    " Preview definition.
    nmap <leader>K     <cmd>PeekDefinition<CR>
    nmap <silent> gp   <cmd>lua _G.PeekDefinition()<CR>
    " Preview type definition.
    nmap <silent> gT   <cmd>lua _G.PeekDefinition('textDocument/typeDefinition')<CR>
  ]])
end

-- configuration for formatter.nvim
local util = require("formatter.util")

require("formatter").setup({
  -- Enable or disable logging
  logging = true,
  -- Set the log level
  log_level = vim.log.levels.WARN,
  -- All formatter configurations are opt-in
  filetype = {
    -- Formatter configurations for filetype "lua" go here
    -- and will be executed in order
    lua = {
      -- "formatter.filetypes.lua" defines default configurations for the
      -- "lua" filetype
      require("formatter.filetypes.lua").stylua,

      -- You can also define your own configuration
      function()
        -- Supports conditional formatting
        if util.get_current_buffer_file_name() == "special.lua" then
          return nil
        end

        -- Full specification of configurations is down below and in Vim help
        -- files
        return {
          exe = "stylua",
          args = {
            "--search-parent-directories",
            "--stdin-filepath",
            util.escape_path(util.get_current_buffer_file_path()),
            "--",
            "-",
          },
          stdin = true,
        }
      end,
    },

    -- Use the special "*" filetype for defining formatter configurations on
    -- any filetype
    ["*"] = {
      -- "formatter.filetypes.any" defines default configurations for any
      -- filetype
      require("formatter.filetypes.any").remove_trailing_whitespace,
    },
  },
})
-- end formatter.nvim

----------------------------------------
-- Formatting, Linting, and Code actions
-- this uses null-ls
----------------------------------------
if pcall(require, "null-ls") then
  local null_ls = require("null-ls")
  local h = require("null-ls.helpers")
  -- @see https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md
  -- @see https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
  -- @see ~/.vim/plugged/null-ls.nvim/lua/null-ls/builtins

  -- @see BUILTINS.md#conditional-registration
  local _cond = function(cmd, source)
    if vim.fn.executable(cmd) > 0 then
      return source
    else
      return nil
    end
  end
  local _exclude_nil = function(tbl)
    return vim.tbl_filter(function(s)
      return s ~= nil
    end, tbl)
  end

  null_ls.setup({
    sources = _exclude_nil({
      -- [[ Auto-Formatting ]]
      -- @python (pip install yapf isort)
      _cond("yapf", null_ls.builtins.formatting.yapf),
      _cond("isort", null_ls.builtins.formatting.isort),
      -- @javascript
      null_ls.builtins.formatting.prettier,

      -- Linting (diagnostics)
      -- @python: pylint, flake8
      _cond(
        "pylint",
        null_ls.builtins.diagnostics.pylint.with({
          method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
          condition = function(utils)
            -- https://pylint.pycqa.org/en/latest/user_guide/run.html#command-line-options
            return (utils.root_has_file("pylintrc") or utils.root_has_file(".pylintrc"))
              or utils.root_has_file("setup.cfg")
          end,
        })
      ),
      _cond(
        "flake8",
        null_ls.builtins.diagnostics.flake8.with({
          method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
          -- Activate when flake8 is available and any project config is found,
          -- per https://flake8.pycqa.org/en/latest/user/configuration.html
          condition = function(utils)
            return (
              utils.root_has_file("setup.cfg")
              or utils.root_has_file("tox.ini")
              or utils.root_has_file(".flake8")
            )
          end,
          -- Ignore some too aggressive errors (indentation, lambda, etc.)
          -- @see https://pycodestyle.pycqa.org/en/latest/intro.html#error-codes
          extra_args = { "--extend-ignore", "E111,E114,E731" },
          -- Override flake8 diagnostics levels
          -- @see https://github.com/jose-elias-alvarez/null-ls.nvim/issues/538
          on_output = h.diagnostics.from_pattern(
            [[:(%d+):(%d+): ((%u)%w+) (.*)]],
            { "row", "col", "code", "severity", "message" },
            {
              severities = {
                E = h.diagnostics.severities["warning"], -- Changed to warning!
                W = h.diagnostics.severities["warning"],
                F = h.diagnostics.severities["information"],
                D = h.diagnostics.severities["information"],
                R = h.diagnostics.severities["warning"],
                S = h.diagnostics.severities["warning"],
                I = h.diagnostics.severities["warning"],
                C = h.diagnostics.severities["warning"],
              },
            }
          ),
        })
      ),
      -- @rust
      _cond(
        "rustfmt",
        null_ls.builtins.formatting.rustfmt.with({
          extra_args = { "--edition=2018" },
        })
      ),
    }),

    should_attach = function(bufnr)
      -- Excludes some files on which it doesn't not make a sense to use linting.
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      if bufname:match("^git://") then
        return false
      end
      if bufname:match("^fugitive://") then
        return false
      end
      if bufname:match("/lib/python%d%.%d+/") then
        return false
      end
      return true
    end,

    -- Debug mode: Use :NullLsLog for viewing log files (~/.cache/nvim/null-ls.log)
    debug = false,
  })

  if vim.lsp.buf.format == nil then
    -- For neovim < 0.8.0, use the legacy formatting_sync API as fallback
    vim.lsp.buf.format = function(opts)
      return vim.lsp.buf.formatting_sync(opts, opts.timeout_ms)
    end
  end

  -- Commands for LSP formatting. :Format
  -- FormattingOptions: @see https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#formattingOptions
  vim.cmd([[
    command! LspFormatSync        lua vim.lsp.buf.format({timeout_ms = 5000})
    command! -range=0 Format      LspFormat
  ]])

  -- Automatic formatting
  -- see ~/.vim/after/ftplugin/python.vim for filetype use
  vim.cmd([[
    augroup LspAutoFormatting
    augroup END
    command! -nargs=? LspAutoFormattingOn      lua _G.LspAutoFormattingStart(<q-args>)
    command!          LspAutoFormattingOff     lua _G.LspAutoFormattingStop()
  ]])
  _G.LspAutoFormattingStart = function(misc)
    vim.cmd([[
    augroup LspAutoFormatting
      autocmd!
      autocmd BufWritePre *    :lua _G.LspAutoFormattingTrigger()
    augroup END
    ]])
    local msg = "Lsp Auto-Formatting has been turned on."
    if misc and misc ~= "" then
      msg = msg .. string.format("\n(%s)", misc)
    end
    msg = msg .. "\n\n" .. "To disable auto-formatting, run :LspAutoFormattingOff"
    vim.notify(msg, "info", { title = "nvim/lua/config/lsp.lua", timeout = 1000 })
  end
  _G.LspAutoFormattingTrigger = function()
    -- Disable on some files (e.g., site-packages or python built-ins)
    -- Note that `-` is a special character in Lua regex
    if vim.api.nvim_buf_get_name(0):match("/lib/python3.%d+/") then
      return false
    end
    -- TODO: Enable only on the current project specified by PATH.
    local formatting_clients = vim.tbl_filter(function(client)
      return client.server_capabilities.documentFormattingProvider
    end, vim.lsp.get_active_clients({ bufnr = 0 }))
    if vim.tbl_count(formatting_clients) > 0 then
      vim.lsp.buf.format({ timeout_ms = 2000 })
      return true
    end
    return false
  end
  _G.LspAutoFormattingStop = function()
    vim.cmd([[ autocmd! LspAutoFormatting ]])
    vim.notify("Lsp Auto-Formatting has been turned off.", "warn")
  end
end -- if null-ls

-- Show diagnostics in a pop-up window on hover
-- this was part of lspnew.lua. I prefer manual diagnostics
do
  _G.LspDiagnosticsPopupHandler = function()
    local current_cursor = vim.api.nvim_win_get_cursor(0)
    local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }

    -- Show the popup diagnostics window,
    -- but only once for the current cursor location (unless moved afterwards).
    if not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2]) then
      vim.w.lsp_diagnostics_last_cursor = current_cursor
      local _, winnr = _G.LspDiagnosticsShowPopup()
      if winnr ~= nil then
        -- opacity/alpha for diagnostics
        vim.api.nvim_win_set_option(winnr, "winblend", 0)
      end
    end
  end
  vim.cmd([[
  augroup LSPDiagnosticsOnHover
    autocmd!
    autocmd CursorHold *   lua _G.LspDiagnosticsPopupHandler()
  augroup END
  ]])
end