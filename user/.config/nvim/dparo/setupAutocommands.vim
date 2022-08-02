function! s:CHeaderTemplate()
    execute "normal! i#pragma once"
    execute "normal! o"
    execute "normal! o"


    execute "normal! i#if __cplusplus\n"
    execute "normal! iextern \"C\" {\n"
    execute "normal! i#endif\n\n\n\n\n\n"
    execute "normal! i#if __cplusplus\n"
    execute "normal! i}\n"
    execute "normal! i#endif"

    execute "normal! kkkkkk"
endfunction

function! s:EnvrcTemplate()
    execute "normal! i#!/usr/bin/env sh\n"
    execute "normal! i# -*- coding: utf-8 -*-\n"
    execute "normal! i\n\n"
endfunction


function! s:MakefileTemplate()
    execute "normal! i.DEFAULT_GOAL := all\n"
    execute "normal! i.PHONY: all release clean\n"
    execute "normal! i\n\all:\necho Hello world\n"
    execute "normal! i\n\n"
endfunction


function! s:BashTemplate()
    execute "normal! i#!/usr/bin/env bash\n"
    execute "normal! i# -*- coding: utf-8 -*-\n"
    execute "normal! i\n"
    execute "normal! icd \"$(dirname \"$0\")\" || exit 1\n"
    execute "normal! i\n\n"
endfunction


function! s:PythonTemplate()
    execute "normal! i#!/usr/bin/env python3\n"
    execute "normal! i# -*- coding: utf-8 -*-\n"
    execute "normal! i\n\n\n\n"
    execute "normal! idef main():\npass\n"
    execute "normal! i\n\n"
    execute "normal! iif __name__ == '__main__':\nmain()\n"
endfunction

function! s:JsTemplate()
    execute "normal! i#!/usr/bin/env node"
    execute "normal! o"
    execute "normal! i\"use strict\";"
    execute "normal! o"
    execute "normal! o"
endfunction



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
    autocmd BufNewFile *.{h,hpp} call <SID>CHeaderTemplate()
    autocmd BufNewFile *.{js} call <SID>JsTemplate()
    autocmd BufNewFile *.{py} call<SID>PythonTemplate()
    autocmd BufNewFile *.{sh,bash} call<SID>BashTemplate()

    autocmd BufNewfile .envrc,.direnvrc,direnvrc call <SID>EnvrcTemplate(); set filetype=sh
    autocmd BufNewfile Makefile call <SID>MakefileTemplate()
    autocmd BufNewfile,BufRead .envrc,.direnvrc,direnvrc set filetype=sh


    "" Stop comment continuation when entering a new line inside a comment
    autocmd BufNewFile,BufRead * setlocal formatoptions-=cro


    " Create parent directory of file when saving if it does not exist
    autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")

    autocmd BufRead,BufNewFile *mutt-*              setfiletype mail
    autocmd BufNewFile,BufRead *./config/i3/config  set filetype=i3config
    autocmd BufWritePost *.config/i3/config silent !i3-msg restart

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
