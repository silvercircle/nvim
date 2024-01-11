-- simple function to select from a list of configured mail addresses and replace
-- a From: header (if present)
-- useful for composing mails

local Utils = require("local_utils")
-- configure your mail addresses here. As many as you want.
local adresses = {
  {
    name = "",
    mail = "",
  },
  {
    name = "",
    mail = "",
  },
}

function Mail_selectFrom()
  local lines = {}
  local i = 1
  for _, v in ipairs(adresses) do
    lines[i] = '"' .. v.name .. '" ' .. v.mail
    i = i + 1
  end
  vim.ui.select(lines, {
    prompt = "Select From adress",
    format_item = function(item)
      return Utils.pad(item, 60, " ")
    end,
  }, function(choice)
    if choice ~= nil and #choice > 1 then
      vim.cmd("%s/^From: .*/From: " .. choice)
      return choice
    end
  end)
end


