return {
  cmd = { LSPDEF.serverconfigs['kotlin'].cmd[1], "--stdio" },
  root_markers = { "build.gradle", "build.gradle.kts", "pom.xml" },
  filetypes = { 'kotlin' },
}
