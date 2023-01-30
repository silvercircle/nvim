"  neovide configuration. You can delete this if you do not use neovide
if exists("g:neovide")
    let g:neovide_remember_window_size = v:true
    let g:neovide_fullscreen = v:false
    let g:neovide_scroll_animation_length = 0.3
    let g:neovide_cursor_vfx_mode = "railgun"
    let g:neovide_transparency = 1
    let g:neovide_floating_blur_amount_x = 0
    let g:neovide_floating_blur_amount_y = 0
    set guifont=Iosevka:h11:#e-subpixelantialias:#h-full

    nnoremap <C-v> "+p
    inoremap <S-Insert> "+p
    nnoremap <S-Insert> "+p
    inoremap <c-v> <c-r>+
    inoremap <S-Insert> <c-r>+
    cnoremap <c-v> <c-r>+
endif
