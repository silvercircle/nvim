local Util = require('lsp.utils')
return {
  cmd = { LSPDEF.serverconfigs["ada_ls"].cmd[1] },
  filetypes = { "ada" },
  root_dir = Util.root_pattern("Makefile", ".git", "*.gpr", "*.adc"),
  lspinfo = function(cfg)
    local extra = {}
    local function find_gpr_project()
      local function split(inputstr)
        local t = {}
        for str in string.gmatch(inputstr, "([^%s]+)") do
          table.insert(t, str)
        end
        return t
      end
      local projectfiles = split(vim.fn.glob(cfg.root_dir .. "/*.gpr"))
      if #projectfiles == 0 then
        return "None (error)"
      elseif #projectfiles == 1 then
        return projectfiles[1]
      else
        return "Ambiguous (error)"
      end
    end
    table.insert(extra, "GPR project:     " .. ((cfg.settings.ada or {}).projectFile or find_gpr_project()))
    return extra
  end
}

