
# Custom key mappings

There are many custom keymappings in this config. The majority is defined in `plugins/command_center` 
forming a command palette which can be activated by `A-p`. This is similar to the command palette known 
in other editors. It shows keymappings and command descriptions, is divided into categories and 
searchable.

Some essential commands are defined in `keymap.lua`, particularly those that should always be available 
even when the command palette is not (yet) loaded.

`Alt-Cursorkey` is used to navigate windows, so `A-Left` goes to the left window, `A-Down` to the split 
below the current and so on.


Key notation is in the Vim format without angle brackets. So `leader n` means to hit the leader key 
followed by n, `C-n` means `Ctrl-n` and so on.

## Keys related to Nvim-Tree or Neotree

| key             | modes | meaning                                                 |
|-----------------|:-----:|---------------------------------------------------------|
|leader ,         | n     | Toggle the tree on the left side                        |
|leader r         | n     | Find the current file in the tree                       |
|leader R         | n     | Sync the tree with the project root directory of the current  file    |
|leader nr        | n     | sync tree with the parent folder of the current file    |

## keys related to the terminal frame

The terminal split is always opened below the current one. This works as toggle, if it's open, it will be 
closed.

| key             | modes | meaning                                                 |
|-----------------|:-----:|---------------------------------------------------------|
| F11             | n     | Toggle the terminal frame at the bottom |

## Navigating the main areas (aka split)

The main window is basically divided into four areas. The file tree on the left side, the main editor 
window in the center, a terminal split right below it and an optional outline view on the right side of 
the main editor area. There are quick navigation keys to focus these frames as follows:

| key             |  modes  | meaning                                                 |
|-----------------|:-------:|---------------------------------------------------------|
| A-1             | n,i,t,v | Focus the left frame (file tree) |
| A-2             | n,i,t,v | Focus the main text area |
| A-3             | n,i,t,v | Open or Focus the symbol outline tree (when available)|
| A-4             | n,i,t,v | Open or focus the terminal|
