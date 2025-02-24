Config = {
  -- map symbol types to highlight groups for telescope since telescope does not use lspkind
  telescope_symbol_highlights = {
    Package   = "@namespace",
    Module    = "@include",
    Function  = "@function",
    Constant  = "@constant",
    Field     = "@field",
    Property  = "@property",
    Constructor = "@constructor",
    Method    = "@method",
    Class     = "@lsp.type.class",
    Struct    = "@lsp.type.struct",
    Namespace = "@namespace",
    Enum      = "@lsp.type.enum_name",
    Enummember= "@lsp.type.enum_member_name"
  },
  telescope_fname_width = tweaks.telescope_fname_width,
  telescope_vertical_preview_layout = tweaks.telescope_vertical_preview_layout,
  telescope_dropdown='bottom',                  -- position for the input box in the dropdown theme. 'bottom' or 'top'
  cpalette_dropdown = 'top',                    -- same for the command palette
  -- the minipicker is the small telescope picker used for references, symbols and
  -- treesitter-symbols. It also works in insert mode.
  minipicker_symbolwidth = tweaks.telescope_symbol_width,
  minipicker_layout = {
    height = 0.85,
    width = tweaks.telescope_mini_picker_width,
    preview_height =10,
    anchor = "N",
  },
}

-- telescope field widths. These depend on the characters per line in the terminal
-- setup. So it needs to be tweakable
Tweaks.telescope_symbol_width = 60
Tweaks.telescope_fname_width = 120
-- the width for the vertical layout with preview on top
Tweaks.telescope_vertical_preview_layout = {
  width = 120,
  preview_height = 15
}
-- the overall width for the "mini" telescope picker. These are used for LSP symbols
-- and references.
Tweaks.telescope_mini_picker_width = 76
-- length of the filename in the cokeline winbar
--
-----------------------------------------------------------------
--- TELESCOPE stuff, some global themes that are needed elsewhere
-----------------------------------------------------------------

-- perm_config.telescope_borders decides which style is used. It can be
-- "squared", "rounded" or "none"
local border_layout_prompt_top = {
  single = {
    results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
    prompt =  { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
  },
  rounded = {
    results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
    prompt  = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  },
  thicc = {
    results = { "━", "┃", "━", "┃", "┣", "┫", "┛", "┗" },
    prompt =  { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
    preview = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" }
  },
  none = {
    results = { " ", " ", " ", " ", " ", " ", " ", " " },
    prompt  = { " ", " ", " ", " ", " ", " ", " ", " " },
    preview = { " ", " ", " ", " ", " ", " ", " ", " " }
  }
}

local border_layout_prompt_bottom = {
  single = {
    results = { "─", "│", "─", "│", "┌", "┐", "┤", "├" },
    prompt =  { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
  },
  rounded = {
    results = { "─", "│", "─", "│", "╭", "╮", "┤", "├" },
    prompt =  { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  },
  thicc = {
    results = { "━", "┃", "━", "┃", "┏", "┓", "┫", "┣" },
    prompt =  { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
    preview = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" }
  },
  none = {
    results = { " ", " ", " ", " ", " ", " ", " ", " " },
    prompt  = { " ", " ", " ", " ", " ", " ", " ", " " },
    preview = { " ", " ", " ", " ", " ", " ", " ", " " }
  }
}

function Utils.Telescope_dropdown_theme(opts)
  local lopts = opts or {}
  local defaults = require("telescope.themes").get_dropdown({
    -- borderchars = Config.telescope_dropdown == 'bottom' and border_layout_bottom_vertical or border_layout_top_center,
    borderchars = Config.telescope_dropdown == "bottom" and border_layout_prompt_bottom[CGLOBALS.perm_config.telescope_borders]
      or border_layout_prompt_top[CGLOBALS.perm_config.telescope_borders],
    layout_config = {
      anchor = "N",
      width = lopts.width or 0.5,
      height = lopts.height or 0.5,
      prompt_position = Config.telescope_dropdown,
    },
    -- layout_strategy=Config.telescope_dropdown == 'bottom' and 'vertical' or 'center',
    previewer = false,
    winblend = vim.g.float_winblend,
  })
  if lopts.cwd ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.cwd
  end
  if lopts.path ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.path
  end
  return vim.tbl_deep_extend("force", defaults, lopts)
end

local border_layout_vertical_dropdown = {
  single = {
    results = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
    prompt =  { "─", "│", "─", "│", "├", "┤", "┘", "└" },
    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
  },
  rounded = {
    results = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
    prompt =  { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
    preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  },
  thicc = {
    results = { "━", "┃", " ", "┃", "┏", "┓", "┃", "┃" },
    prompt =  { "━", "┃", "━", "┃", "┣", "┫", "┛", "┗" },
    preview = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" }
  },
  none = {
    results = { " ", " ", " ", " ", " ", " ", " ", " " },
    prompt  = { " ", " ", " ", " ", " ", " ", " ", " " },
    preview = { " ", " ", " ", " ", " ", " ", " ", " " }
  }
}

--- a dropdown theme with vertical layout strategy
--- @param opts table of valid telescope options
function Utils.Telescope_vertical_dropdown_theme(opts)
  local lopts = opts or {}
  local defaults = require("telescope.themes").get_dropdown({
    borderchars = border_layout_vertical_dropdown[CGLOBALS.perm_config.telescope_borders],
    fname_width = Config["telescope_fname_width"],
    sorting_strategy = "ascending",
    layout_strategy = "vertical",
    path_display = { shorten = 10 },
    symbol_width = Config.minipicker_symbolwidth,
    layout_config = {
      width = lopts.width or 0.8,
      height = lopts.height or 0.9,
      preview_height = lopts.preview_width or 0.4,
      prompt_position = "bottom",
      scroll_speed = 2,
    },
    winblend = vim.g.float_winblend,
  })
  if lopts.search_dirs ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.search_dirs[1]
  end
  if lopts.cwd ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.cwd
  end
  if lopts.path ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.path
  end
  return vim.tbl_deep_extend("force", defaults, lopts)
end

-- custom theme for the command_center Telescope plugin
-- reason: I have square borders everywhere
function Utils.command_center_theme(opts)
  local lopts = opts or {}
  local defaults = require("telescope.themes").get_dropdown({

    borderchars = border_layout_prompt_top[CGLOBALS.perm_config.telescope_borders],
    layout_config = {
      anchor = "N",
      width = lopts.width or 120,
      height = lopts.height or 0.4,
      prompt_position = Config.cpalette_dropdown,
    },
    -- layout_strategy=Config.telescope_dropdown == 'bottom' and 'vertical' or 'center',
    previewer = false,
    winblend = vim.g.float_winblend,
  })
  if lopts.cwd ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.cwd
  end
  if lopts.path ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.path
  end
  return vim.tbl_deep_extend("force", defaults, lopts)
end

  -- create custom telescope themes as globals
  __Telescope_dropdown_theme = utils.Telescope_dropdown_theme
  __Telescope_vertical_dropdown_theme = utils.Telescope_vertical_dropdown_theme
