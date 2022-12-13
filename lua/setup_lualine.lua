--[[
--count words in either the entire document or the current visual mode
--selection. This is for a custom lualine section (see below)
--]]
local function getWordsV2()
  local wc = vim.fn.wordcount()
  if wc["visual_words"] then -- text is selected in visual mode
    return wc["visual_words"] .. " Words (Selection)"
  else -- all of the document
    return wc["words"] .. " Words"
  end
end

require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = "my_powerline",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = { "Outline", "neo-tree" },
      winbar = {},
      tabline = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 2000,
      tabline = 3000,
      winbar = 5000,
    },
  },
  sections = {
    lualine_a = { "mode", "o:formatoptions", " : ", "o:textwidth" }, -- display textwidth after formattingoptions
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename", "searchcount" },
    lualine_x = {
      "encoding",
      {
        -- show unicode for character under cursor in hex and decimal
        "%05B - %06b",
        fmt = function(str)
          return string.format("U:0x%s", str)
        end,
      },
      "fileformat",
      "filetype",
    },
    lualine_y = { "progress" },
    -- word counter via custom function
    lualine_z = { { getWordsV2 }, "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {
    lualine_a = { { "buffers", mode = 2 } },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "tabs" },
  },
  winbar = {},
  inactive_winbar = {},
  extensions = {},
})