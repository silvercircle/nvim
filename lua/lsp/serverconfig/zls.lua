return {
  cmd = { "zls", "--config-path", "zls.json" },
  filetypes = { "zig", "zir" },
  root_markers = { "zls.json", "build.zig", ".git" },
  single_file_support = true,
}
