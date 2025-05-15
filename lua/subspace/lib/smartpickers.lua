local M = {}
Utils = require("subspace.lib")
Fzf = require("fzf-lua")

-- this tries to perform a smart files or grep operation using the fzf-lua picker
-- it is only somewhat smart, because it tries to deduce the project type from the current
-- filetype and creates filters for running the pickers.
-- for example, if the current file is a .cpp file, then it would only search for common
-- c/c++ files. Like .h, .hpp, .cpp, .c, .cxx and so on

---@class project_types[]
---@field ext table a list of filename extensions
---@field names? table an (optional) list of full filenames
local project_types = {
  lua = { ext = { "lua", "md", "vim" }, names = {"init.vim"} },
  c = { ext = { "c", "cpp", "cxx", "h", "hxx", "hpp", "cc" }, names = {"CMakeLists.txt", "Makefile", "CMakePresets.json"} },
  tex = { ext = { "tex", "sty" } }
}

M.smartfiles_or_grep = function(opts)
  opts = opts or { useroot = false, op = "files" }
  local fd_opts_default = "--color=never --type f --hidden --follow --exclude .git --regex -- "
  local rg_opts_default = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -g '!.git'"

  local cwd = opts.useroot and Utils.getroot_current() or vim.fn.expand("%:p:h")
  local ext, name = vim.fn.expand("%:e"), vim.fn.expand("%:t")
  local result, fresult = nil, nil

  if Tweaks.smartpicker.project_types then
    project_types = vim.tbl_deep_extend("force", project_types, Tweaks.smartpicker.project_types)
  end

  for _,v in pairs(project_types) do
    if type(v.ext) ~= "table" or (v.names ~= nil and type(v.names) ~= "table") then
      goto continue
    end
    if vim.tbl_contains(v.ext, ext) or (v.names ~= nil and vim.tbl_contains(v.names, name) or false) then
      result = vim.fn.join(v.ext, opts.op == "files" and "|" or ",")
      if v.names then
        fresult = vim.fn.join(v.names, opts.op == "files" and "|" or ",")
      end
    end
    ::continue::
  end

  if result == nil then
    vim.notify("No valid smartpicker configuration for the current filetype found.")
    return
  end

  if opts.op == "files" then
    -- build the regex
    result = "'(.*\\.(" .. result .. ")$"
    if fresult then
      result = result .. "|(" .. fresult .. ")"
    end
    result = result .. ")'"
    fd_opts_default = fd_opts_default .. result
    if opts.debug then
      vim.notify(fd_opts_default)
    end
    local title = Utils.truncate("Smart files (Search for: " .. result .. ")", vim.o.columns - 10)
    Fzf.files( { formatter = "path.filename_first", cwd = cwd, fd_opts = fd_opts_default,
      winopts = FWO("very_narrow_no_preview",
      { title = title, width = vim.fn.strwidth(title) > 80 and vim.fn.strwidth(title) + 4 or Tweaks.fzf.winopts.very_narrow_no_preview.width }) })
  elseif opts.op == "grep" then
    rg_opts_default = rg_opts_default .. " -g '*.{" .. result .. "}'"
    if fresult then
      rg_opts_default = rg_opts_default .. " -g '{" .. fresult .. "}'"
    end
    rg_opts_default = rg_opts_default .. " -e"
    if opts.debug then
      vim.notify(rg_opts_default)
    end
    local title = Utils.truncate("Live Grep " .. cwd .. " (Search in: " .. result ..(fresult and ("," .. fresult) or "") .. ")", vim.o.columns - 10)

    Fzf.live_grep({ cwd = cwd, query = Utils.get_selection(), rg_opts = rg_opts_default,
      winopts = FWO("std_preview_top",
      { title = title, width = vim.fn.strwidth(title) > 80 and vim.fn.strwidth(title) + 4 or Tweaks.fzf.winopts.std_preview_top.width } )} )
  end
end

return M
