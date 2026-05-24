local lib = require("subspace.lib")

return {
  filetypes = { 'kotlin', 'java' },
  cmd = { LSPDEF.serverconfigs['kotlin-lsp'].cmd[1], "--smart", "--root=" .. lib.getroot_current() },
  single_file_support = true,
  -- cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(9999)),
  root_markers = {
    'settings.gradle', -- Gradle (multi-project)
    'settings.gradle.kts', -- Gradle (multi-project)
    'pom.xml', -- Maven
    'build.gradle', -- Gradle
    'build.gradle.kts' -- Gradle
  },
  settings = {
    sourcePaths = {vim.fn.expand("~/.kotlin-lsp/sources")}
  }
}
