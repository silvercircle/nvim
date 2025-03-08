local M = {}
Utils = require("subspace.lib")
Fzf = require("fzf-lua")

-- this tries to perform a smart files or grep operation using the fzf-lua picker
-- it is somewhat smart, because it tries to deduce the project type from the current
-- filetype and creates filters for running the pickers.
-- for example, if the current file is a .cpp file, then it would only search for common
-- c/c++ files. Like .h, .hpp, .cpp, .c, .cxx and so on

local project_types = {
  { "lua" },
  { "c", "cpp", "cxx", "h", "hxx", "hpp", "cc" },
  { "tex", "sty" }
}

M.smartfiles_or_grep = function(opts)
  opts = opts or { useroot = false, op = "files" }
  local fd_opts_default = "--color=never --type f --hidden --follow --exclude .git --regex -- "
  local rg_opts_default = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -g '!.git'"

  local cwd = opts.useroot and Utils.getroot_current() or vim.fn.expand("%:p:h")
  local ext = vim.fn.expand("%:e")
  local result = nil

  vim.iter(project_types):map(function(k)
    if vim.tbl_contains(k, ext) then result = vim.fn.join(k, opts.op == "files" and "|" or ",") return end
  end)

  if result == nil then
    vim.notify("No valid smartpicker configuration for the current filetype found.")
    return
  end

  if opts.op == "files" then
    -- build the regex
    result = "'.*\\.(" .. result .. ")$'"
    fd_opts_default = fd_opts_default .. result
    Fzf.files( { formatter = "path.filename_first", cwd = cwd, fd_opts = fd_opts_default,
      winopts = FWO("very_narrow_no_preview", "Smart files (Search for: " .. result .. ")") })
  elseif opts.op == "grep" then
    rg_opts_default = rg_opts_default .. " -g '*.{" .. result .. "}' -e"
    Fzf.live_grep({ cwd = cwd, query = Utils.get_selection(), rg_opts = rg_opts_default,
      winopts = FWO("std_preview_top", "Live Grep " .. cwd .. " (Search in: " .. result .. ")")} )
  end
end

return M
