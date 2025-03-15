local util = require('lspconfig.util')

return {
  default_config = {
    cmd = { "ccls" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_dir = function(fname)
      return util.root_pattern("compile_commands.json", ".ccls", "configure.ac")(fname) or
      vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
    end,
    offset_encoding = "utf-32",
    -- ccls does not support sending a null root directory
    single_file_support = false,
    capabilities = CGLOBALS.lsp_capabilities
  }
}
