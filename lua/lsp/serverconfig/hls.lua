return {
  cmd = { LSPDEF.serverconfigs["hls"].cmd[1], "--lsp" },
  filetypes = { "haskell", "lhaskell" },
  root_markers = { "hie.yaml", "stack.yaml", "cabal.project", "*.cabal", "package.yaml" },
  single_file_support = true,
  settings = {
    haskell = {
      formattingProvider = "ormolu",
      cabalFormattingProvider = "cabalfmt",
    },
  },
  lspinfo = function(cfg)
    local extra = {}
    local function on_stdout(_, data, _)
      local version = data[1]
      table.insert(extra, "version:   " .. version)
    end

    local opts = {
      cwd = cfg.cwd,
      stdout_buffered = true,
      on_stdout = on_stdout,
    }
    local chanid = vim.fn.jobstart({ cfg.cmd[1], "--version" }, opts)
    vim.fn.jobwait { chanid }
    return extra
  end
}
