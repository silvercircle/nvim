
# Custom key mappings

There are many custom keymappings in this config. The majority is defined in `plugins/command_center.lua` 
forming a command palette which can be activated by `A-p`. This is similar to the command palette known 
in other editors. It shows keymappings and command descriptions, is divided into categories and 
searchable like any other Telescope picker.

Some essential commands are defined in `keymap.lua`, particularly those that should always be available 
even when the command palette is not (yet) loaded.

`Alt-Cursorkey` is used to navigate windows, so `A-Left` goes to the left window, `A-Down` to the split 
below the current and so on.

Key notation is in the Vim format without angle brackets. So `leader n` means to hit the leader key 
followed by `n`, `C-n` means `Ctrl-n` and so on.

Some keymaps use the notation of a `root directory`. This is defined as the project root directory for 
the active buffer. To find it, various utility functions are used for a *best guess* approach. If the 
file is under **GIT** version control, then the `GIT root` will be used. If it is not, a pattern approach 
similar to LSP config will be used to find typical project root patterns. Note that this might fail and 
return `nil` in which case the directory of the active buffer will be used.

## File pickers (Telescope)

| key             | modes | meaning                                                 |
|-----------------|:-----:|---------------------------------------------------------|
|C-p              | n     | Select recent file (Telescope oldfiles)                 |
|C-e              | n,i   | Select buffer (loaded or unloaded, Telescope buffers)   |
|F8               | n     | Find files in the `root` directory of the active buffer |

## Keys related to Nvim-Tree or Neotree

| key             | modes | meaning                                                 |
|-----------------|:-----:|---------------------------------------------------------|
|leader ,         | n     | Toggle the tree on the left side                        |
|leader r         | n     | Find the current file in the tree                       |
|leader R         | n     | Sync the tree with the project root directory of the current  file    |
|leader nr        | n     | sync tree with the parent folder of the current file    |

## keys related to the terminal frame

The terminal split is always opened below the current one. This works as toggle, if it's open, it will be 
closed. See the [docs](configuration.md) of how to avoid opening a terminal on startup.

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

Note that this also works when the editor was started in plain mode without an active file tree and 
terminal split.

## Various navigation helpers

| key             |  modes  | meaning                                                 |
|-----------------|:-------:|---------------------------------------------------------|
| A-Backspace     | n,i     | Activate the jumplist (recent edit locations)    |
| A-S-Left        | n,i     | Go back to previous edit location (like C-o)     |
| A-S-Right       | n,i     | Go to next edit location (like C-i)              |

## Quickfix mapping

| key             |  modes  | meaning                                                 |
|-----------------|:-------:|---------------------------------------------------------|
| A-S-Down        | n,i     | Next quickfix location                           |
| A-S-Up          | n,i     | Previous quickfix location                       |
| C-f c           | n,i     | Close quickfix split                             |

## Various keys

| key             |  modes  | meaning                                                 |
|-----------------|:-------:|---------------------------------------------------------|
| F1              | i       | LSP Symbol hover information                     |
| S-F1            | i       | LSP parameter (signature) help                   |
| F4              | n,i     | Save a view of the current file (persistent folds)|
| F5              | n,i     | clear search highlights (also those from hlslens |

## Format paragraph

| key             |  modes  | meaning                                                 |
|-----------------|:-------:|---------------------------------------------------------|
| A-C-w           | i,n     | Format paragraph to current text width. Use soft line breaks|

## CMP (completion) mapping.

These mappings are defined in `lua/plugins/cmp.lua` which contains all cmp-related configuration. 
Standard keybindings are used to activate manual completion (`C-Space`) and select completion suggestions 
(`Tab`).

