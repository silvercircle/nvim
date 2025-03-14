# Oil (file manager)

[Oil](https://github.com/stevearc/oil.nvim) is one of the most popular Neovim plugins. It's a file 
manager that works different from others, provided by plugins like [NvimTree](nvimtree.md) or similar.

Oil handles directories like ordinary vim buffers. To delete a file, simply delete the line, to add one 
insert a new line, to rename just edit the file name. Oil does not commit your changes to the file system 
until you *save* the buffer representing the directory and it will ask you whether you really want to do 
the changes. So, as long as you do not save the Oil buffer and confirm the changes, nothing is changed on 
your file system.

## Using Oil in this config
The keyboard mapping ++ctrl+f8++ can be used in any buffer to open Oil with the directory of the file 
you're editing set as its base.

Additionally, some pickers like the [Zoxide picker](./fzf.md#zoxide-history-viewer) may offer shortcuts to 
open a directory with Oil.

## Leaving Oil
Since oil is an ordinary buffer (just an unlisted one), you don't really have to *close* it. You can, for 
example, use ++ctrl+e++ to select another buffer. Or just open another file by any means. Or go back in 
the history by using ++ctrl+o++ or ++ctrl+shift+left++.

## Configuring Oil
The [configuration file](https://github.com/silvercircle/nvim/blob/main/lua/plugins/oil.lua) is in 
`lua/plugins/oil.lua`. Please refer to the plugin documentation fore more information.
