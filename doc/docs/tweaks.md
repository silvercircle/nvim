# How the Tweaks file works:

The `lua/tweaks-dist.lua` contains a lot of user-tweakable settings. Most of which are somewhat explained 
and commented. However, this file would be overwritten when updating the repo via `git pull`, so there is 
a simple system to prevent this:

* Create a copy of `tweaks-dist.lua` and name it `mytweaks.lua`. **Name is important**, all lower case and it 
  must be in the `lua` folder. Just place it next to `tweaks-dist.lua` in the same folder.

* You can now modify settings in `mytweaks` and they will override corresponding settings in 
  `tweaks-dist.lua`. You can also delete everything you do not want to touch from `mytweaks.lua` but 
  leave the `-dist` alone. The `mytweaks.lua` is merged with the `tweaks-dist` at startup

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
{ .annotate }

{==

Test and more

==}

The **most important** setting to edit in the tweaks is the `lsp` table, because this contains all the 
paths for the supported LSP server binaries. If you install them with Mason, you should not need to edit 
most of them, but remember, the config is only supported on Linux and if you are on Windows (native, not 
WSL) or macOS, you'll likely have to fix a lot.
{ .annotate }

$$
\cos x=\sum_{k=0}^{\infty}\frac{(-1)^k}{(2k)!}x^{2k}
$$

T~end~
