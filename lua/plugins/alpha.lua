if Config.plain == false then
  local theme = require("alpha.themes.startify")
  theme.section.top_buttons.val = {}
  for _,v in ipairs(vim.g.startify_top) do
    table.insert(theme.section.top_buttons.val, theme.button( v.key, v.text, v.command ))
  end
--  theme.section.header.val = {
--    "                                                     ",
--    "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
--    "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
--    "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
--    "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
--    "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
--    "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
--    "                                                     ",
--  }
  theme.section.header.val = require("ascii").art.text.neovim.dos_rebel
  theme.section.bottom_buttons.val = {}
  if vim.fn.has("linux") > 0 and (Config.fortunecookie ~= false and #Config.fortunecookie > 0) then
    local handle = io.popen("fortune science politics -s -n500 | cowsay -W 120")
    local result = {"",""}
    if handle ~= nil then
      local lines = handle:lines()
      for line in lines do
        table.insert(result, line)
      end
      handle:close()
      theme.section.header.val = result
    end
  end
  theme.config.opts.noautocmd = true
  require('alpha').setup(theme.config)
end
