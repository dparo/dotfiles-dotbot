function s:AddTerminalNavigation()
    if &filetype ==# 'toggleterm'
        "" Allow <Esc> to reach normal mode within terminal buffers
        ""   but disable this binding for fzf buffers, since <Esc> bind should be handled
        ""   directly from fzf.vim plugin in order to quit the window.
        tnoremap <buffer> <silent> <Esc> <c-\><c-n>
        nnoremap <buffer> <silent> <Esc> i
    endif
endfunction


" Strip trailing whitespaces and restore cursor
function! <SID>StripTrailingWhitespaces()
    " Save the current search and cursor position
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Strip TrailingWhitespaces including Windows newlines
    silent execute '%s/\s*\(\s\|\r\)$//e'
    "" Strip un-necessary newlines before EOF
    silent execute '%s/\(\n\)\+\%$//e'
    " Restore the saved search and cursor position
    let @/=_s
    call cursor(l, c)
endfun

augroup dparo_wrap_and_spell
autocmd!
autocmd FileType gitcommit setlocal wrap
autocmd FileType gitcommit,markdown setlocal spell
augroup end

augroup DPARO
    " Resets all autocommands in this group. Useful for resourcing the .vimrc file
    autocmd!

    autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
    " Removes trailing whitespaces before saving file
    autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

    " Reload the buffer if it was changed externally
    autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
    " notification after file change
    autocmd FileChangedShellPost *
    \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

    " reset cursor when vim exits
    autocmd VimLeave * silent !echo -ne "\033]112\007"

    " Reset cursor when vim exits
    autocmd VimLeave * silent !echo -ne "\033]112\007"

    " Readjusts window dimension when vim changes size.
    autocmd VimResized * tabdo wincmd =

    autocmd WinEnter * set cursorline
    autocmd WinLeave * set nocursorline


    " Insert pragma once for h, and hpp files
    autocmd BufNewFile *.{h} 0r ~/.config/nvim/dparo/skeletons/c.h
    autocmd BufNewFile *.{hpp} 0r ~/.config/nvim/dparo/skeletons/c.hpp
    autocmd BufNewFile *.{js} 0r ~/.config/nvim/dparo/skeletons/js.js
    autocmd BufNewFile *.{py} 0r ~/.config/nvim/dparo/skeletons/python.py
    autocmd BufNewFile *.{sh,bash} 0r ~/.config/nvim/dparo/skeletons/sh.sh
    autocmd BufNewfile .envrc,.direnvrc,direnvrc 0r ~/.config/nvim/dparo/skeletons/.envrc
    autocmd BufNewfile Makefile 0r ~/.config/nvim/dparo/skeletons/Makefile

    autocmd BufNewfile,BufRead  .envrc,.direnvrc,direnvrc set filetype=sh

    "" Stop comment continuation when entering a new line inside a comment
    autocmd BufNewFile,BufRead * setlocal formatoptions-=cro


    " Create parent directory of file when saving if it does not exist
    autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")

    autocmd BufRead,BufNewFile *mutt-*              setfiletype mail
    autocmd BufNewFile,BufRead *./config/i3/config  set filetype=i3config
    autocmd BufWritePost *.config/i3/config silent !i3-msg restart
    autocmd BufWritePost *.config/sxhkd/sxhkdrc silent !pkill -USR1 -x sxhkd

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim) and for a commit message (it's
    " likely a different one than last time).
    " NOTE(dparo): 5 Jan 2022:
    "     Disabled, since it conflicts with cmdline syntax `$> nvim +{line} <file>`
    "     and thus I cannot spawn neovim from the command line at a specific line location
    "     (eg useful when using gdb, or external shell scripts)
    " " " " " " " "
    " autocmd BufReadPre *
    "   \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    "   \ |   exe "normal! g`\""
    "   \ | endif


    autocmd QuickfixCmdPost make lua dparo.post_build()

    autocmd TermOpen  * call s:AddTerminalNavigation()

    autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Search', timeout = 200})
augroup END
