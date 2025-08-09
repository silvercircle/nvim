-- wx provider for the wsplit

-- this translates condition codes (single letters) to actual readable conditions. This is API specific
-- and right now only implemented for the VC (visual crossing) and CC (tomorrow.io, formerly climacell)
-- this also requires a NERD font.
local conditions = {
  VC = {
    c = "󰖕 Partly Cloudy",
    a = "󰖙 Clear",
    e = "󰖐 Cloudy",
    j = "󰖖 Rain",
    o = "󰼶 Snow",
    g = "󰖗 Showers",
    k = "󰖓 Thunderstorm",
  },
  CC = {
    c = "󰖕 Partly Cloudy",
    b = "󰖕 Mostly Clear",
    a = "󰖙 Clear",
    e = "󰖐 Cloudy",
    f = "󰖐 Cloudy",
    d = "󰖐 Mostly Cloudy",
    j = "󰖖 Heavy Rain",
    o = "󰼶 Snow",
    w = "󰼶 Snow",
    k = "󰖓 Thunderstorm",
    x = " Sleet/Drizzle",
    g = " Light Rain",
    ['0'] = " Fog",
    ['9'] = " Wind",
    ['2'] = " Strong wind",
    ['3'] = " Strong wind",
  },
  OWM = {
    c = "󰖕 Partly Cloudy",
    b = "󰖕 Mostly Clear",
    a = "󰖙 Clear",
    e = "󰖐 Cloudy",
    f = "󰖐 Cloudy",
    d = "󰖐 Mostly Cloudy",
    j = "󰖖 Heavy Rain",
    s = "󰖖 Rain",
    o = "󰼶 Snow",
    w = "󰼶 Snow",
    k = "󰖓 Thunderstorm",
    x = " Sleet/Drizzle",
    g = " Light Rain",
    ['0'] = " Fog",
    ['9'] = " Wind",
    ['2'] = " Strong wind",
    ['3'] = " Strong wind",
  },
  OWM3 = {
    c = "󰖕 Partly Cloudy",
    b = "󰖕 Mostly Clear",
    a = "󰖙 Clear",
    e = "󰖐 Cloudy",
    f = "󰖐 Cloudy",
    d = "󰖐 Mostly Cloudy",
    j = "󰖖 Heavy Rain",
    s = "󰖖 Rain",
    o = "󰼶 Snow",
    w = "󰼶 Snow",
    k = "󰖓 Thunderstorm",
    x = " Sleet/Drizzle",
    g = " Light Rain",
    ['0'] = " Fog",
    ['9'] = " Wind",
    ['2'] = " Strong wind",
    ['3'] = " Strong wind",
  }
}

--- set a highlight group for the given temperature
--- @param temp string: the temperature
--- @return string: the hl group
--- TODO: make this customizable via a setup() method
local function temp_to_hl(temp)
  local t = tonumber(string.gsub(temp, "°C", ""), 10)
  if t <= 0 then
    return "Purple"
  elseif t <= 5 then
    return "Blue"
  elseif t > 5 and t < 10 then
    return "Green"
  elseif t >= 10 and t <= 20 then
    return "Yellow"
  elseif t > 20 and t <= 27 then
    return "Brown"
  elseif t > 27 and t < 35 then
    return "Red"
  else
    return "DarkPurple"
  end
end

--- set a highlight group for the wind speed
--- @param wind string: wind speed (assumed in km/h)
--- @return string: A hl group
local function wind_to_hl(wind)
  local w = tonumber(string.gsub(wind, "km/h", ""), 10)
  if w < 5 then
    return "Green"
  elseif w < 10 then
    return "Blue"
  elseif w < 25 then
    return "Yellow"
  elseif w < 50 then
    return "Brown"
  elseif w < 70 then
    return "Red"
  else
    return "Purple"
  end
end

---@class subspace.providers.Wx
---@field owner wsplit
---@field ws    table,
---@field min_height integer
local Wx = {}
Wx.__index = Wx

---@return subspace.providers.Wx
---@param  _owner wsplit
function Wx:new(_owner)
  return setmetatable({
    content = "test",
    owner    = _owner,
    ws       = require("subspace.content.wsplit"),
    min_height = 14
  }, self)
end

function Wx:render()
  local results = {}
  vim.api.nvim_buf_clear_namespace(self.owner.id_buf, -1 --[[self.ws.nsid]], 0, -1)
  if vim.fn.filereadable(self.ws.weatherfile) then
    local lines = {}
    local file = io.open(self.ws.weatherfile)
    local index = 1
    local hl
    if file ~= nil then
      local l = file:lines()
      for line in l do
        results[tostring(index)] = line
        index = index + 1
      end
      io.close(file)
      local lcond = conditions[results["37"]][string.lower(results["2"])]
      table.insert(lines, " ")
      table.insert(lines, self.ws.prepare_line("  " .. results["26"], " " .. results["28"], 0))
      table.insert(lines, self.ws.prepare_line(" " .. lcond, results["33"], -1))
      table.insert(lines, "  ")
      table.insert(lines, self.ws.prepare_line(" Temp: " .. results["3"], "Feels: " .. results["16"], 0))
      table.insert(lines, self.ws.prepare_line(" Min:  " .. results["29"], "Max:   " .. results["30"], 0))
      table.insert(lines, self.ws.prepare_line(" Dew:  " .. results["17"], " " .. results["21"], 0))
      table.insert(lines, self.ws.prepare_line(" API:  " .. results["37"], " " .. results["31"], 0))
      table.insert(
        lines,
        self.ws.prepare_line(
          "   " .. results["25"] .. " at " .. results["20"] .. "  ",
          " Vis: " .. results["22"],
          0
        )
      )
      table.insert(lines, self.ws.prepare_line(" Pressure: " .. results["19"], " " .. results["18"], 0))
      table.insert(lines, self.ws.prepare_line("   " .. results["23"], "  " .. results["24"], -3))
      local cond = conditions[results["37"]][string.lower(results["4"])]
      if cond == nil then
        cond = "N/A"
      end
      table.insert(lines, "  ")
      table.insert(
        lines,
        self.ws.prepare_line(
          " " .. results["7"] .. ": " .. cond,
          "   " .. results["5"] .. "°C  " .. results["6"] .. "°C",
          -1
        )
      )
      -- set highlights. Use the max expected temp to highlight general conditions or specific
      -- temps (like the Dew Point)
      hl = temp_to_hl(results["6"])
      vim.api.nvim_buf_set_lines(self.owner.id_buf, 0, -1, false, lines)
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 12, 0, { hl_group = hl, end_col = #lines[13] })

      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 1, 0, { hl_group = "Function", end_col = #lines[2] })
      -- temp
      hl = temp_to_hl(results["3"]) -- the current temperature, also colorize the condition string
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 2, 0, { hl_group = hl, end_col = self.owner.width })
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 4, 0, { hl_group = hl, end_col = 21 })
      hl = temp_to_hl(results["16"])
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 4, 20, { hl_group = hl, end_col = #lines[5] })

      hl = temp_to_hl(results["29"])
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 5, 0, { hl_group = hl, end_col = 22 })
      hl = temp_to_hl(results["30"])
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 5, 20, { hl_group = hl, end_col = #lines[6] })
      hl = temp_to_hl(results["17"])
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 6, 0, { hl_group = hl, end_col = 22 })

      hl = wind_to_hl(results["20"])
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 8, 0, { hl_group = hl, end_col = 22 })
      vim.api.nvim_set_option_value("modified", false, { buf = self.owner.id_buf })
    end
  end
end

function Wx:destroy()
  vim.api.nvim_buf_clear_namespace(self.owner.id_buf, -1 --[[self.ws.nsid]], 0, -1)
end

local M = {}

---@return subspace.providers.Wx
---@param owner wsplit
function M.new(owner)
  return Wx:new(owner)
end

return M
