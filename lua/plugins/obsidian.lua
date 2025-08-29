local function setup()
  require("obsidian").setup({
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/zettelkasten",
      },
    },
    legacy_commands = false,
    preferred_link_style = "wiki",
    completion = {
      -- Enables completion using nvim_cmp
      nvim_cmp = Tweaks.completion.version == "nvim-cmp" and true or false,
      -- Enables completion using blink.cmp
      blink = Tweaks.completion.version == "blink" and true or false,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },
    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = "dailies",
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = "%Y-%m-%d",
      -- Optional, if you want to change the date format of the default alias of daily notes.
      alias_format = "%B %-d, %Y",
      -- Optional, default tags to add to each new daily note created.
      default_tags = { "daily-notes" },
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = nil,
      -- Optional, if you want `Obsidian yesterday` to return the last work day or `Obsidian tomorrow` to return the next work day.
      workdays_only = false
    },
    picker = {
      -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', 'mini.pick' or 'snacks.pick'.
      name = "fzf-lua",
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
    },
    ui = {
      update_debounce = 1000
    },
    footer = {
      enabled = false
    }
  })
end

setup()

