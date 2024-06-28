" Set configuration variables

let g:bookmark_no_default_key_mappings = 1
let g:bookmark_auto_save_file = stdpath("state") .. '/bookmarks'
let g:bookmark_sign = ' '
let g:bookmark_highlight_lines = 1
let g:bookmark_annotation_sign = " "

let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_frontmatter = 1
let g:rnvimr_enable_picker = 1
let g:rnvimr_draw_border = 1
let g:VM_theme = 'sand'

" Customize the initial layout
" Rnvimr plugin (ranger filemanager integration)
" Activate with <C-f8>
let g:rnvimr_layout = {
            \ 'relative': 'editor',
            \ 'width': float2nr(round(0.9 * &columns)),
            \ 'height': float2nr(round(0.9 * &lines)),
            \ 'col': float2nr(round(0.05 * &columns)),
            \ 'row': float2nr(round(0.05 * &lines)),
            \ 'style': 'minimal'
            \ }

lua << EOB
vim.loader.enable()
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- bootstrap lazy
require('config')
__Globals.restore_config()
__Globals.set_statuscol(__Globals.perm_config.statuscol_current)
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require('options')
require('load_lazy')
require("auto")
--require('plugins.default')
require('keymap')

if vim.g.neovide then
  -- font configuration is outsourced to ~/.config/neovide/config.toml
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.opt.linespace = -2
  vim.g.neovide_padding_top = 4
  vim.g.neovide_padding_right = 4
  vim.g.neovide_padding_left = 4
  vim.g.neovide_remember_window_size = false
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_cursor_vfx_mode = "none"
  vim.g.neovide_transparency = 1
  vim.g.transparency = 0
  vim.g.neovide_background_color = "#ffff00ff"
  vim.g.neovide_theme = "dark"
  -- vim.g.neovide_unlink_border_highlights = true
end
EOB

" set guifont=JetBrains\ Mono\ Medium:h9:#e-subpixelantialias:#h-full
" let g:neovide_fullscreen = v:true

run macros/justify.vim
filetype on
syntax on
filetype plugin indent on
set noshowmode

command C Kwbd

" This is for adding fortune cookies. User will be prompted for a section
" (multiple sections can be entered separated with spaces) and the fortune
" cookie will be inserted at the current cursor position.
" This is for nostalgic reasons, it's a usenet thing.
function! Fortune()
    let section = input("Section: ")
    execute 'read !fortune -s ' . section
endfunction

command Fortune call Fortune()

" for plaintext mail / news postings..
" ensure all paragraphs are softwrapped with \s\n sequences to comply
" with format=flowed specification
"
" see: http://vim.wikia.com/wiki/Correct_format-flowed_email_function
function! Fixflowed()
  let pos = getpos(".")
  silent! %s/\([^]> :]\)\ze\n>[> ]*[^> ]/\1 /g
  silent! %s/ \+\ze\n[> ]*$//
  silent! %s/ \{2,}$/ /
  silent! %s/^[> ]*>\ze[^> ]/& /
  while search('^>\+ >', 'w') > 0
    s/^>\+\zs >/>/
  endwhile
  call setpos('.',pos)
endfunction

command Fixq call Fixflowed()

command! Jsonf :execute '%!python -c "import json,sys,collections,re; sys.stdout.write(re.sub(r\"\\\u[0-9a-f]{4}\", lambda m:m.group().decode(\"unicode_escape\").encode(\"utf-8\"),json.dumps(json.load(sys.stdin, object_pairs_hook=collections.OrderedDict), indent=2)))"'
" see https://jackdevries.com/post/vimRipgrep
if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

function! Mult(fact)
    let oldv = getreg("v")

    call search('\d\([^0-9\.]\|$\)', 'cW')
    normal v
    call search('\(^\|[^0-9\.]\d\)', 'becW')

    normal "vygv

    execute "normal c" . float2nr(@v * a:fact)
    call setreg("v", oldv)
endfunction


