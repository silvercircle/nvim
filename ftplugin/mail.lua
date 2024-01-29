-- simple function to select from a list of configured mail addresses and replace
-- a From: header (if present)
-- useful for composing mails

local Utils = require("local_utils")
-- configure your mail addresses here. As many as you want.
local adresses = {
  --{
  --  name = "foo",
  --  mail = "foo@bar.com"
  --},
  --{
  --  ...
  --}
}

-- include personal stuff.
local st, personal = pcall(require, "personal")

if st == true then
  adresses = vim.tbl_deep_extend("force", adresses, personal.mail)
end

function Mail_selectFrom()
  local lines = {}
  local i = 1
  if #adresses == 0 then
    vim.notify("No adresses defined", vim.log.levels.WARN)
    return
  end
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


