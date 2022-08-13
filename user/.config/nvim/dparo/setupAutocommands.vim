function s:AddTerminalNavigation()
    if &filetype ==# 'toggleterm'
        "" Allow <Esc> to reach normal mode within terminal buffers
        ""   but disable this binding for fzf buffers, since <Esc> bind should be handled
        ""   directly from fzf.vim plugin in order to quit the window.
        tnoremap <buffer> <silent> <Esc> <c-\><c-n>
        nnoremap <buffer> <silent> <Esc> i
    endif
endfunction


augroup DPARO
    " Resets all autocommands in this group. Useful for resourcing the .vimrc file
    autocmd!


    " Create parent directory of file when saving if it does not exist
    autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")

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
