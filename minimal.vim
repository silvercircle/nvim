lua << EOB
vim.o.statuscolumn='%s%=%{printf("%4d", v:lnum)} %C%#IndentBlankLineChar#│ '
vim.o.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+]]
EOB
set foldcolumn=1
set signcolumn=yes:3
set numberwidth=5

