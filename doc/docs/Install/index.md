# Installing and initial configuration

These `dotfiles` are targeted at software development, mainly with LSP and CMP as a completion engine. 
Many Plugins are optional and not loaded on startup for quick startup time. This happens all under 
control of the [lazy plugin manager](https://github.com/folke/lazy.nvim) and should not require additional configuration.

## Requirements

* [Neovim](https://neovim.io) version 0.11 or later. Older versions will not work. You can install this 
  in a variety of ways, using your local package management, compile from source or using a 
  prebuilt binary installation. This is, however, not topic in these docs.
* A working [git](https://git-scm.com) Installation.
* A supported terminal. On Windows, I recommend [WezTerm](https://wezterm.org), but others will work. On 
  Linux, [kitty](https://sw.kovidgoyal.net/kitty/) is my favorite and macOS users may look into Ghostty 
  or iTerm2 for best results.

## First start

After cloning the repo to `~/.config/nvim` (or the equivalent on Windows or macOS), you should start Neovim 
for the first time with the command:
```
nvim --headless -c 'Lazy! sync' +qa
```
This will start Neovim without the UI (`--headless`), install all the plugins using the plugin manager and 
then quit. Usually, this should complete without errors unless your system lacks prerequisites like a 
working GIT installation.

!!! Note

    Note that this is **ONLY** required for a fresh install. Once all plugins are installed, you can launch 
    Neovim normally without parameters.

## Review settings

Please take some time and review the basic settings. They're all found in `lua/config.lua` and 
`lua/options.lua`. The first file holds non-Vim specific settings like theme options and such while 
`options.lua` defines vim options and some auto commands. Also relevant is `init.vim` which is still not 
100% Lua, bust mostly contains auto commands and a few legacy vimscript functions. Custom keymappings are 
all in `lua/keymap.lua` and `lua/plugins/command_center.lua`.

## Configuring LSP

This will need most of your attention. The configuration is built with **manual LSP server installation** in 
mind. You can use `Mason` to install servers, but as bare minimum, you have to check the contents of 
the `vim.g.lsp_server_bin` table in `config.lua`. This defines paths (and filenames ) of the supported LSP 
servers and is used in `plugins/lsp.lua` to setup LSP servers.

## Plain mode

For those who prefer a clean environment (or for quick-editing single files) the plain mode is available. 
When active, certain plugins like the **file tree** are not loaded on startup. They are still available, 
but they do not clutter the UI by default and do not take time on startup. The same applies to the 
terminal split. The plain mode starts faster and offers a clean UI with just a single window. Most 
features (like CMP completion, LSP, Tree-sitter, Mason etc.) are still available and will be activated on 
demand.

To start plain mode, there are two options: Set the environment variable `NVIM_PLAIN` or start with `--cmd "let g:want_plain=v:true"`
on the command line. The content of the environment variable does not matter, it can be set to anything. 
The options to activate the filetree (`leader,`) or the terminal split (`f11`) are still available. LSP 
will work and CMP will be loaded when you first enter *InsertMode*. 

## Keymapping

For the description and configuration options, see [this file](keymap.md). There are many custom keyboard 
commands available.

## CMP completion

CMP `autocompletion` is, by default, disabled in this config. Manual completion is available with `C-Space` 
in Insert mode and the command line. Autocomplete can be enabled by setting 
`vim.g.config.cmp_autocomplete` to true in `config.lua`. For everything else cmp-related, tweaking the 
settings in file `lua/plugins/cmp.lua` is the only available method.


