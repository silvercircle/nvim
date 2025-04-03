" Set configuration variables
lua << EOB
local disabled_plugins = {
  "gzip", "zip", "zipPlugin", "tar", "tarPlugin", "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
  "tutor_mode_plugin", "tohtml"
}

vim.iter(disabled_plugins):map(function(k)
  vim.g['loaded_' .. k] = 1
end)

vim.loader.enable()
-- package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
-- package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- bootstrap lazy
vim.g._ts_force_sync_parsing = true
require('config')
require("subspace.lib.permconfig").restore_config()
PCFG = require("subspace.lib.permconfig").perm_config
CGLOBALS.set_statuscol(PCFG.statuscol_current)

if (Tweaks.DEV and Tweaks.DEV ~= false) or os.getenv("NVIM_DEV_PRIVATE") then
  assert = function(...) return ... end
end

if vim.g.neovide then
  -- vim.o.guifont = "MonoLisa:h10.2:w-.4:#e-subpixelantialias:#h-full"
  vim.opt.linespace = -1
  vim.g.neovide_text_gamma = 1.0
  vim.g.neovide_text_contrast = .4
  vim.g.neovide_padding_top = 7
  vim.g.neovide_padding_bottom = 7
  vim.g.neovide_padding_right = 2
  vim.g.neovide_padding_left = 2
  vim.g.neovide_floating_corner_radius = 0.0
  vim.g.neovide_cursor_trail_size = 0.0
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_underline_stroke_scale = 3.0
  vim.cmd("map! <S-Insert> <C-R>+")
end

if not vim.uv.fs_stat(lazypath) then
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
require("keymaps.default")
local _,_ = pcall(require, "keymaps.user")
EOB

run macros/justify.vim
filetype on
syntax on
filetype plugin indent on
set noshowmode

command C Kwbd
cabbrev botright below

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

" simple function to multiply the number under the cursor with a given factor
function! Mult(fact)
    let oldv = getreg("v")

    call search('\d\([^0-9\.]\|$\)', 'cW')
    normal v
    call search('\(^\|[^0-9\.]\d\)', 'becW')

    normal "vygv

    execute "normal c" . float2nr(@v * a:fact)
    call setreg("v", oldv)
endfunction


