# My Neovim Config


## Coc
I still use coc for LSP support and all the fancy features like auto-complete, code navigation and other 
things. The following extensions are installed using the **CocInstall** command

*  @yaegassy/coc-pylsp Current version 0.7.1 is up to date.
*  coc-json Current version 1.7.0 is up to date.
*  coc-clangd Current version 0.27.0 is up to date.
*  coc-texlab Current version 3.2.0 is up to date.
*  coc-dictionary Current version 1.2.2 is up to date.
*  coc-snippets Current version 3.1.5 is up to date.
*  coc-css Current version 2.0.0 is up to date.
*  coc-dlang Current version 1.1.2 is up to date.
*  coc-yaml Current version 1.9.0 is up to date.
*  coc-html Current version is up to date

Nim support is manually installed via nimlsp.

## Custom mappings:

|  KEY      |      Mode(s)       | Function |
|<C-x><C-q> | Normal, Insert     | Save (if modified), close buffer       |
|<C-x><C-s> | Normal, Insert     | Save (if modified)                     |
|<C-x><C-c> | Normal, Insert     | Close buffer (will warn when modified) |
|<C-x><C-h> | Normal, Insert     | execute nohl (cancel highlights)       |
|TSH        | Normal             | Show Treesitter highlight class        |
|<C-f><C-a> | Insert             | Toggle autowrap (a formatoption)       |
|<C-f><C-w> | Insert             | Toggle w format option                 |
|<C-f><C-t> | Insert             | Toggle t format option                 |
|<C-f>1     | Insert             | autowrap on (+a+w)                     |
|<C-f>2     | Insert             | Autowrap off (-a-w)                    |
|<C-f>a     | Insert             | Full autorwrap                         |
|<C-f>f     | Insert             | Disable all Autowrap modes             |

