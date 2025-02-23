require("nvim-treesitter.configs").setup({
  auto_install = true,
  ensure_installed = { "c", "cpp", "lua", "vimdoc" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false
  },
})

-- treesitter is first started (in auto.lua)
local function configure_treesitter()
  vim.treesitter.language.register("markdown", { "telekasten", "liquid" } )
  vim.treesitter.language.register("css", "scss")
  vim.treesitter.language.register("html", "jsp")
  vim.treesitter.language.register("ini", "editorconfig")
  -- disable injections for these languages, because they can be slow
  -- can be tweaked
  vim.treesitter.query.set("javascript", "injections", "")
  vim.treesitter.query.set("typescript", "injections", "")
  vim.treesitter.query.set("vimdoc", "injections", "")
  -- enable/disable treesitter-context plugin
  -- jump to current context start
end

configure_treesitter()
vim.treesitter.start()

