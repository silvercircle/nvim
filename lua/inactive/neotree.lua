local highlights = require("neo-tree.ui.highlights")
local function find_buffer_by_name(name)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if name == vim.api.nvim_buf_get_name(buf) then
      return buf
    end
  end
  return -1
end
require("neo-tree").setup({
  sources = {
    "filesystem",
    --"git_status",
    "buffers"
  },
  enable_opened_markers = true,   -- Enable tracking of opened files. Required for `components.name.highlight_opened_files`
  enable_refresh_on_write = true, -- Refresh the tree when a file is written. Only used if `use_libuv_file_watcher` is false.
  git_status_async = true,
  add_blank_line_at_top = false,
  close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
  popup_border_style = "single",
  enable_git_status = Tweaks.tree.use_git,
  use_popups_for_input = false,
  enable_diagnostics = true,
  sort_case_insensitive = false, -- used when sorting files and directories in the tree
  sort_function = nil, -- use a custom function for sorting files and directories in the tree
  -- sort_function = function (a,b)
  --       if a.type == b.type then
  --           return a.path > b.path
  --       else
  --           return a.type > b.type
  --       end
  --   end , -- this sorts files and directories descendantly
  --
  source_selector = {
    winbar = false, -- toggle to show selector on winbar
    statusline = false, -- toggle to show selector on statusline
    show_scrolled_off_parent_node = false, -- this will replace the tabs with the parent path
    -- of the top visible node when scrolled down.
    sources = { -- falls back to source_name if nil
      filesystem = "  Files ",
      buffers = "  Buffers ",
      git_status = "  Git ",
      diagnostics = " 裂Diagnostics ",
    },
    content_layout = "start", -- only with `tabs_layout` = "equal", "focus"
    --                start  : |/ 裡 bufname     \/...
    --                end    : |/     裡 bufname \/...
    --                center : |/   裡 bufname   \/...
    tabs_layout = "equal", -- start, end, center, equal, focus
    --             start  : |/  a  \/  b  \/  c  \            |
    --             end    : |            /  a  \/  b  \/  c  \|
    --             center : |      /  a  \/  b  \/  c  \      |
    --             equal  : |/    a    \/    b    \/    c    \|
    --             active : |/  focused tab    \/  b  \/  c  \|
    truncation_character = "…", -- character to use when truncating the tab label
    tabs_min_width = nil, -- nil | int: if int padding is added based on `content_layout`
    tabs_max_width = nil, -- this will truncate text even if `text_trunc_to_fit = false`
    padding = 0, -- can be int or table
    -- padding = { left = 2, right = 0 },
    -- separator = "▕", -- can be string or table, see below
    separator = { left = "", right = "" },
    -- separator = { left = "/", right = "\\", override = nil },     -- |/  a  \/  b  \/  c  \...
    -- separator = { left = "/", right = "\\", override = "right" }, -- |/  a  \  b  \  c  \...
    -- separator = { left = "/", right = "\\", override = "left" },  -- |/  a  /  b  /  c  /...
    -- separator = { left = "/", right = "\\", override = "active" },-- |/  a  / b:active \  c  \...
    -- separator = "|",                                              -- ||  a  |  b  |  c  |...
    separator_active = nil, -- set separators around the active tab. nil falls back to `source_selector.separator`
    show_separator_on_edge = false,
    --                       true  : |/    a    \/    b    \/    c    \|
    --                       false : |     a    \/    b    \/    c     |
    highlight_tab = "StatusLine",
    highlight_tab_active = "Accent",
    highlight_background = "StatusLine",
    highlight_separator = "StatusLine",
    highlight_separator_active = "StatusLine",
  },
  default_component_configs = {
    container = {
      enable_character_fade = false,
    },
    indent = {
      indent_size = 2,
      padding = 0, -- extra padding on left hand side
      -- indent guides
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
      -- expander config, needed for nesting files
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "",
      -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
      -- then these will never be used.
      default = "* ",
      highlight = "NeoTreeFileIcon",

    },
    modified = {
      symbol = "[+]",
      highlight = "NeoTreeModified",
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
      highlight = "NeoTreeFileName",
      highlight_opened_files = true
    },
    file_size = {
      enabled = false,
    },
    type = {
      enabled = false,
    },
    last_modified = {
      enabled = false,
    },
    created = {
      enabled = false,
    },
    symlink_target = {
      enabled = false,
    },
    git_status = {
      symbols = {
        -- Change type
        added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
        modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
        deleted = "󰮉", -- this can only be used in the git_status source
        renamed = "󰑕", -- this can only be used in the git_status source
        -- Status type
        untracked = "",
        ignored = "",
        unstaged = "󰊢",
        staged = "",
        conflict = "",
      },
    },
  },
  window = {
    position = "left",
    popup = { -- settings that apply to float position only
      size = { height = "70%", width = "60" },
      position = "50%", -- 50% means center it
    },
    width = CGLOBALS.perm_config.tree.width,
    mapping_options = {
      noremap = true,
      nowait = true,
    },
    mappings = {
      ["<space>"] = {
        "toggle_node",
        nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
      },
      ["<2-LeftMouse>"] = "open",
      ["<cr>"] = "open",
      ["<esc>"] = "revert_preview",
      ["P"] = { "toggle_preview", config = { use_float = true } },
      ["S"] = "open_split",
      ["s"] = "open_vsplit",
      -- ["S"] = "split_with_window_picker",
      -- ["s"] = "vsplit_with_window_picker",
      ["t"] = "open_tabnew",
      -- ["<cr>"] = "open_drop",
      -- ["t"] = "open_tab_drop",
      ["w"] = "open_with_window_picker",
      --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
      ["C"] = "close_node",
      ["z"] = "close_all_nodes",
      --["Z"] = "expand_all_nodes",
      ["a"] = {
        "add",
        -- some commands may take optional config options, see `:h neo-tree-mappings` for details
        config = {
          show_path = "none", -- "none", "relative", "absolute"
        },
      },
      ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add".
      ["d"] = "delete",
      ["r"] = "rename",
      ["y"] = "copy_to_clipboard",
      ["x"] = "cut_to_clipboard",
      ["p"] = "paste_from_clipboard",
      ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
      -- ["c"] = {
      --  "copy",
      --  config = {
      --    show_path = "none" -- "none", "relative", "absolute"
      --  }
      --}
      ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
      ["q"] = "close_window",
      ["R"] = "refresh",
      ["?"] = "show_help",
      ["<"] = "prev_source",
      [">"] = "next_source",
    },
  },
  nesting_rules = {},
  filesystem = {
    components = {
      name = function(config, node, _)
        local result = {
          -- add some padding
          text = " " .. node.name
        }
        if node.type == "file" then
          local rc = find_buffer_by_name(node.path)
          if rc >= 0 and vim.api.nvim_buf_is_loaded(rc) then
            result.highlight = "NeoTreeFilenameOpened"
          else
            result.highlight = config.highlight
          end
        elseif node.type == "directory" then
          result.highlight = highlights.DIRECTORY_ICON
        else
          result.highlight = "NeoTreeMessage"
        end
        return result
      end
    },
    bind_to_cwd = true,
    filtered_items = {
      visible = false, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = false,
      hide_gitignored = true,
      hide_hidden = true, -- only works on Windows for hidden files/directories
      hide_by_name = {
        --"node_modules"
      },
      hide_by_pattern = { -- uses glob style patterns
        --"*.meta",
        --"*/src/*/tsconfig.json",
      },
      always_show = { -- remains visible even if other settings would normally hide it
        ".gitignore",
        ".editorconfig"
      },
      never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
        --".DS_Store",
        --"thumbs.db"
      },
      never_show_by_pattern = { -- uses glob style patterns
        --".null-ls_*",
      },
    },
    follow_current_file = { enabled = false }, -- This will find and focus the file in the active buffer every
    -- time the current file is changed while the tree is open.
    group_empty_dirs = false, -- when true, empty folders will be grouped together
    hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
    -- in whatever position is specified in window.position
    -- "open_current",  -- netrw disabled, opening a directory opens within the
    -- window like netrw would, regardless of window.position
    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
    use_libuv_file_watcher = true, -- When true, it will use the OS level file watchers to detect changes
                                    -- instead of relying on nvim autocmd events.
    window = {
      mappings = {
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
        ["H"] = "toggle_hidden",
        ["/"] = "fuzzy_finder",
        ["D"] = "fuzzy_finder_directory",
        ["f"] = "filter_on_submit",
        ["<c-x>"] = "clear_filter",
        ["[g"] = "prev_git_modified",
        ["]g"] = "next_git_modified",
      },
    },
  },
  event_handlers = {
    {
      event = "neo_tree_window_after_open",
      handler = function(_) CGLOBALS.tree_open_handler() end
    },
    {
      event = "neo_tree_window_after_close",
      handler = function() CGLOBALS.tree_close_handler() end
    },
    {
      event = "neo_tree_popup_input_ready",
      ---@param args { bufnr: integer, winid: integer }
      handler = function(args)
        vim.cmd("stopinsert")
        vim.keymap.set("i", "<esc>", vim.cmd.stopinsert, { noremap = true, buffer = args.bufnr })
      end,
    }
  },
  buffers = {
    follow_current_file = { enabled = true }, -- This will find and focus the file in the active buffer every
    -- time the current file is changed while the tree is open.
    group_empty_dirs = true, -- when true, empty folders will be grouped together
    show_unloaded = true,
    window = {
      position = "float",
      popup = {
        size = { height = 40, width = 50 },
      },
      mappings = {
        ["bd"] = "buffer_delete",
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
      },
    },
  },
  git_status = {
    window = {
      position = "left",
      mappings = {
        ["A"] = "git_add_all",
        ["gu"] = "git_unstage_file",
        ["ga"] = "git_add_file",
        ["gr"] = "git_revert_file",
        ["gc"] = "git_commit",
        ["gp"] = "git_push",
        ["gg"] = "git_commit_and_push",
      },
    },
  },
})

local nc = require("neo-tree.command")
vim.g.setkey({'n', 'v'}, '<leader>r', function()
  nc.execute( {action="show", reveal=true, reveal_force_cwd=true, source="filesystem" } )
end, "Change NvimTree cwd to current project root")
vim.g.setkey('n', '<leader>,', function()
  nc.execute( {action="focus", toggle=true, position="left"})
end, "Toggle NvimTree")
vim.g.setkey('n', '<leader>R', function()
  CGLOBALS.sync_tree()
end, "Change NvimTree cwd to current project root")
