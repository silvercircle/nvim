
# Custom key mappings

There are many custom keymappings in this config. The majority is defined in `plugins/command_center` 
forming a command palette which can be activated by `A-p`. This is similar to the command palette known 
in other editors. It shows keymappings and command descriptions, is divided into categories and 
searchable.

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

| key             | modes | meaning                                                 |
|-----------------|:-----:|---------------------------------------------------------|
| F11             | n     | Toggle the terminal frame at the bottom |

