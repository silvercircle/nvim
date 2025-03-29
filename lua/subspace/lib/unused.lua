--- supporting function for mini.pick
--- returns a window config table to center a mini.picker with desired width and height
--- on screen
--- @param width integer      desired width of the picker window
--- @param height integer     desired height of the picker window
--- @param col_anchor number  vertical anchor in percentage. 0.5 centers
---                           lower values shift upwards, higher downwards
--- @ return table            a valid window config that can be passed to the picker
local function mini_pick_center(width, height, col_anchor)
  local _ca = col_anchor or 0.5
  if width > 0 and width < 1 then
    width = math.floor(width * vim.o.columns)
  end
  if height > 0 and height < 1 then
    height = math.floor(height * vim.o.lines)
  end
  return {
    anchor = "NW",
    height = height,
    width = width,
    row = math.floor(_ca * (vim.o.lines - height)),
    col = math.floor(0.5 * (vim.o.columns - width)),
    border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" }
  }
end


--- this handles ufo-nvim fold preview.
local function ufo_virtual_text_handler(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = (' 󰁂 %d '):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, { suffix, 'MoreMsg' })
  return newVirtText
end

