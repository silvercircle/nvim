local M = {}

function M.rgbtohsv(red, green, blue, inpercent)
  local factor = inpercent == true and 100 or 1
  local r = red/255 or 0
  local g = green/255 or 0
  local b = blue/255 or 0
  local H

  local cmax = math.max(r, g, b)
  local cmin = math.min(r, g, b)
  local delta = cmax - cmin

  local V = cmax

  if cmax == cmin then
    return { 0.0, 0.0, V * factor}
  end

  local S = (delta) / cmax

  local rc = (cmax - r) / delta
  local gc = (cmax - g) / delta
  local bc = (cmax - b) / delta

  if r == cmax then
    H = 0.0 + bc - gc
  elseif g == cmax then
    H = 2.0 + rc - bc
  elseif b == cmax then
    H = 4.0 + gc - rc
  end
  H = H / 6.0 * 360
  return { h = H < 1 and (360 - math.abs(H)) or H, s = S * factor, v = V * factor }
end

--- @param hue number color hue (0 <= hue <= 360)
--- @param sat number color saturation (0 <= sat <= 1.0)
--- @param val number color value (brightness) (0 <= val <= 1.0)
--- @param opts? table
--- opts.spercent ~= nil: assume sat given percent
--- opts.vpercent ~= nil: assume val given in percent
function M.hsvtorgb(hue, sat, val, opts)
  opts = opts or {}

  local h = (hue >= 0 and hue <= 360) and hue/360 or 1
  local s, v = math.abs(sat), math.abs(val)

  s = opts.spercent and (s <= 100 and s/100 or 1.0) or
    (s <= 1.0 and s or 1.0)

  v = opts.vpercent and (v <= 100 and v/100 or 1.0) or
    (v <= 1.0 and v or 1.0)

  local i = math.floor(h * 6)
  local f = h * 6 - i
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t = v * (1 - (1 - f) * s)

  local _r = {
    [0] = { v, t, p },
    [1] = { q, v, p },
    [2] = { p, v, t },
    [3] = { p, q, v },
    [4] = { t, p, v },
    [5] = { v, p, q }
  }

  local rr = _r[math.fmod(i, 6)]
  local result = {
    red   = rr[1] * 255,
    green = rr[2] * 255,
    blue  = rr[3] * 255,
  }
  result['hex'] = string.format("%02x%02x%02x", result.red, result.green, result.blue)
  return result
end

--- modify the hex color under the cursor
--- hue is retained, saturation and/or brightness are changed
--- @param ds number saturation delta -1 <= ds <= 1
--- @param dv number brightness delta -1 <= dv <= 1
function M.modifycolor(ds, dv)
  ds = math.abs(ds) <= 1 and ds or 0.0
  dv = math.abs(dv) <= 1 and dv or 0.0

  vim.cmd.stopinsert()
  local hex = vim.fn.expand("<cword>")
  local r, g, b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
  local hsv = M.rgbtohsv(r, g, b)
  local new = M.hsvtorgb(hsv.h, hsv.s + ds, hsv.v + dv)
  vim.fn.feedkeys("ciw")
  vim.fn.feedkeys(new.hex)
  vim.cmd.stopinsert()
end

return M

