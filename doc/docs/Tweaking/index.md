# Tweaking
Like any Neovim configuration, you can modify this to match your own needs. You can basically edit all 
files below the `lua` directory. The problem with this approach is that you would run into problems when 
updating the configuration by pulling changes from the repository. This would either merge them with 
changes you have made, overwrite your changes or result in merge conflicts. This is sub-optimal and there 
should be a way to tweak the configuration.

## How the tweaks-dist.lua mechanism works

The `lua/tweaks-dist.lua` contains a lot of user-tweakable settings. Most of which are somewhat explained 
and commented. However, this file would be overwritten when updating the repo via `git pull`, so there is 
a simple system to prevent this:

- Create a copy of `tweaks-dist.lua` and name it `mytweaks.lua`. **Name is important**, all lower case and it 
  must be in the `lua` folder. Just place it next to `tweaks-dist.lua` in the same folder.

- You can now modify settings in `mytweaks` and they will override corresponding settings in 
  `tweaks-dist.lua`. You can also delete everything you do not want to touch from `mytweaks.lua` but 
  leave the `-dist` alone. The `mytweaks.lua` is merged with the `tweaks-dist` at startup and all 
  settings in `mytweaks.lua` will overwrite the defaults.

It is important to maintain the file structure. Here is a sample for a valid `mytweaks.lua` file. It 
redefines exactly two settings. First, it activates `DEV mode` which currently does nothing. Second, it 
sets `Tweaks.completion.version` to "nvim-cmp". By default, this is set to "blink".


```lua linenums="1"
local Tweaks = {}

Tweaks.DEV = true
Tweaks.completion = {
  version = "nvim-cmp" -- # (1)
}
return Tweaks
```

!!!Note

    Please note line 1 and 8. Do not change them. When changing values, always use `tweaks-dist.lua` as a 
    reference. Do not change to many values at once, it will make it more difficult to find settings 
    responsible for problems.

The **most important** setting to edit in the tweaks is the `lsp` table, because this contains all the 
paths for the supported LSP server binaries. If you install them with Mason, you should not need to edit 
most of them, but remember, the config is only supported on Linux and if you are on Windows (native, not 
WSL) or macOS, you'll likely have to fix a lot.
{ .annotate }

## How do I override keymaps or define my own?

The default key mappings are defined in two places:

- `lua/keymaps/default.lua`

- `lua/plugins/commandpicker_addcommands`. This configures the [command palette](../Plugins/commandpalette.md)
  which also supports keyboard mapping.

- you can always put additional lua files in `lua/keymaps` and they will be executed after 
  `defaults.lua`, so you can override any default mapping.

```lua
local Utils = require('subspace.lib')
vim.g.setkey('n', '<f5>', function() require("oil").open(Utils.getroot_current()) end, "Open Oil file manager")
```

This would redefine the mapping that opens the [Oil](../Plugins/oil.md) file manager. `vim.g.setkey` is 
just a shortcut for `vim.keymap.set` and `Utils.getroot_current()` attempts to find the root directory 
for the current project.
