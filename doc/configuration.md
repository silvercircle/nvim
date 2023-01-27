
# Configuring and options

These `dotfiles` are targeted at software development, mainly with LSP and CMP as a completion engine. 
Many Plugins are optional and not loaded on startup for quick startup time. This happens all under 
control of the [lazy plugin manager](https://github.com/folke/lazy.nvim) and should not require additional configuration.

## Configuring LSP

This will need most of your attention. The configuration is built with **manual LSP server installation** in 
mind. You can use `Mason` to install servers, but as bare minimum, you have to check the contents of 
the `vim.g.lsp_server_bin` table in `config.lua`. This defines paths (and filenames ) of the supported LSP 
servers and is used in `plugins/lsp.lua` to setup LSP servers.

## Plain mode

For those who prefer a clean environment (or for quick-editing single files) the plain mode is available. 
When active, certain plugins like the **file tree** are not loaded on startup. They are still available, but 
they do not clutter the UI by default. The same applies to the terminal split. The plain mode starts 
faster and offers a clean UI with just a single window. Most features (like CMP completion, LSP, 
Tree-sitter, Mason etc.) are still available and will be activated on demand.

To start plain mode, there are two options: Set the environment variable `NVIM_PLAIN` or start with `--cmd "let g:want_plain=v:true"`
on the command line. The content of the environment variable does not matter, it can be set to anything. 
The options to activate the filetree (`leader,`) or the terminal split (`f11`) are still available. LSP 
will work and CMP will be loaded when you first enter *InsertMode*. 

## Keymapping

For the description and configuration options, see [this file](keymap.md). There are many custom keyboard 
commands available.

## CMP completion

`autocompletion` is, by default, disabled in this config.

