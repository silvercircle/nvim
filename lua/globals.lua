-- global variables for plugins
local g = vim.g

g.mapleader = ','

-- sonokai theme
g.sonokai_menu_selection_background='red'
g.sonokai_style='atlantis'
g.sonokai_transparent_background=1
g.sonokai_disable_italic_comment=1
g.sonokai_cursor = "auto"
g.sonokai_diagnostic_text_highlight=0
g.sonokai_diagnostic_line_highlight=0

g.scratch_persistence_file = "~/vim-scratch.txt"
g.scratch_height = 20
g.coc_max_treeview_width = 30

-- multicursor
g.VM_Mono_hl   = 'DiffText'
g.VM_Extend_hl = 'DiffAdd'
g.VM_Cursor_hl = 'Visual'
g.VM_Insert_hl = 'DiffChange'
g.tex_conceal = ''

-- NERDTree stuff
g.NERDTreeMinimalUI = 0
g.NERDTreeDirArrows = 1
g.NERDTreeShowHidden = 1
g.NERDTreeShowBookmarks = 1
g.NERDTreeSortHiddenFirst = 1
g.NERDTreeChDirMode = 2
g.NERDTreeMapOpenSplit='$'
g.NERDTreeFileExtensionHighlightFullName = 1
g.NERDTreeRespectWildIgnore=1

vim.cmd [[silent! colorscheme my_sonokai]]