require("obsidian").setup({
  workspaces = {
    {
      name = "personal",
      path = "~/Documents/zettelkasten",
    },
  },
  completion = {
    -- Enables completion using nvim_cmp
    nvim_cmp = false,
    -- Enables completion using blink.cmp
    blink = true,
    -- Trigger completion at 2 chars.
    min_chars = 2,
  },
  picker = {
    -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', 'mini.pick' or 'snacks.pick'.
    name = "snacks.pick",
    -- Optional, configure key mappings for the picker. These are the defaults.
    -- Not all pickers support all mappings.
    note_mappings = {
      -- Create a new note from your query.
      new = "<C-x>",
      -- Insert a link to the selected note.
      insert_link = "<C-l>",
    },
    tag_mappings = {
      -- Add tag(s) to current note.
      tag_note = "<C-x>",
      -- Insert a tag at the current location.
      insert_tag = "<C-l>",
    },
  }
})
