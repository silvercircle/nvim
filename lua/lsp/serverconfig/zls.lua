vim.g.zig_fmt_parse_errors = 0
vim.g.zig_fmt_autosave = 0

return {
  on_new_config = function(new_config, new_root_dir)
    if vim.fn.filereadable(vim.fs.joinpath(new_root_dir, "zls.json")) ~= 0 then
      new_config.cmd = { LSPDEF.serverconfigs["zls"].bin[1], "--config-path", "zls.json" }
    end
  end,
  filetypes = { "zig", "zir" },
  root_markers = { "zls.json", "build.zig", ".git" },
  single_file_support = true,
}
