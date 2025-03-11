# Oil (file manager)

[Oil](https://github.com/stevearc/oil.nvim) is one of the most popular Neovim plugins. It's a file 
manager that works different from others, provided by plugins like [NvimTree](nvimtree.md) or similar.

Oil allows to manipulate directories like ordinary vim buffers. To delete a file, simply delete the line, 
to add one insert a new line and so on. Oil does not commit your changes to the file system until you *save* 
the buffer representing the directory and it will ask you whether you really want to do the changes.

## Using Oil in this config
The keyboard mapping ++ctrl+f8++ can be used in any buffer to open Oil with the directory of the file 
you're editing set as its base.

Additionally, some pickers like the [Zoxide picker](./fzf.md#zoxide-history-viewer) may offer shortcuts to 
open a directory with Oil.

## Leaving Oil
Since oil is an ordinary buffer (just an unlisted one), you don't really have to *close* it. You can, for 
example, use ++ctrl+e++ to select another buffer. Or go back in the history by using +++ctrl+o++ or 
++ctrl+shift+left++.
