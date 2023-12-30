# How the Tweaks file works:

The `lua/tweaks-dist.lua` contains a lot of user-tweakable settings. Most of which are somewhat explained 
and commented. However, this file would be overwritten when updating the repo via `git pull`, so there is 
a simple system to prevent this:

* Create a copy of `tweaks-dist.lua` and name it `mytweaks.lua`. Name is important, all lower case and it 
  must be in the `lua` folder. Just where `tweaks-dist.lua` is.

* You can now modify settings in `mytweaks` and they will override corresponding settings in 
  `tweaks-dist.lua`. You can also delete everything you do not want to touch from `mytweaks.lua` but 
  leave the `-dist` alone.

The **most important** setting to edit in the tweaks is the `lsp` table, because this contains all the 
paths 
