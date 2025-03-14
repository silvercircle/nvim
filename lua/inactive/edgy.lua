require("edgy").setup({
  options = {
    left = { size = CGLOBALS.perm_config.tree.width },
  },
  wo = {
    winbar = false
  },
  animate = {
    enabled = false
  },
  left = {
    -- Neo-tree filesystem always takes half the screen height
    {
      title = "Neo-Tree",
      ft = "neo-tree",
      filter = function(buf)
        return vim.b[buf].neo_tree_source == "filesystem"
      end
      --size = { height = 0.6 },
    },
    --{
    --  title = "Neo-Tree Git",
    --  ft = "neo-tree",
    --  filter = function(buf)
    --    return vim.b[buf].neo_tree_source == "git_status"
    --  end,
    --  pinned = true,
    --  open = "Neotree position=right git_status",
    --},
    {
      title = "Neo-Tree Buffers",
      ft = "neo-tree",
      filter = function(buf)
        return vim.b[buf].neo_tree_source == "buffers"
      end,
      pinned = true,
      open = "Neotree position=top buffers",
      size = { height = 20 }
    },
    "neo-tree"
  }
})
