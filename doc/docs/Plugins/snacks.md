# [Snacks](https://github.com/folke/snacks.nvim)
Snacks is a collection of modules published as a single, relatively large, plugin. Individual modules can 
be enabled or stay disabled.

The configuration file can be found in [lua/plugins/snacks_setup.lua](https://github.com/silvercircle/nvim/blob/main/lua/plugins/snacks_setup.lua)

As of now, the following modules are activated for this config:

## Snacks.indent
Provides indent guidelines, including scope visualization. Can be tweaked via `Tweaks.indent`. There are 
two utility keyboard shortcuts to control this feature:

- `utility key` + ++o++ toggle all indent guides in all buffers on/off

- `utility_key` + ++u++ toggle the indent guides for the current buffer

## Snacks.lazygit
This integrates [LazyGit](https://github.com/jesseduffield/lazygit) into your Neovim. You must install 
LazyGit and make sure, its executable is available in your `$PATH`. By default, it is bound to the ++f6++ keyboard 
shortcut and will open a LazyGit window as a floating popup covering about 90% of your Neovim Window.

## Snacks.picker
The picker is an alternative to *Telescope* or [Fzf-Lua](fzf.md), which this configuration uses as its 
primary picker. Snacks is mainly used for some custom pickers and simple UI selection dialogs
