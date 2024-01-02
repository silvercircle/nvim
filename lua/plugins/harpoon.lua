local harpoon = require("harpoon")
harpoon:setup({
  settings = {
    encode = false,
    decode = false
  }
})
vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)

local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end

  require("telescope.pickers").new(__Telescope_vertical_dropdown_theme({
    prompt_prefix = require("local_utils").getTelescopePromptPrefix(),
    layout_config = Config.minipicker_layout
  }), {
    prompt_title = "Harpoon",
    finder = require("telescope.finders").new_table({
      results = file_paths,
    }),
    previewer = conf.file_previewer({}),
    sorter = conf.generic_sorter({}),
  }):find()
end
vim.keymap.set({"n", "i"}, "<A-e>", function() toggle_telescope(harpoon:list()) end, {desc = "Open harpoon window" })
