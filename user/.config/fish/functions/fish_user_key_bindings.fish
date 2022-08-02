function fish_user_key_bindings
    fzf_key_bindings

    bind \eq exit

    # URXVT - Ctrl + Shift + Backspace
    bind \e\[6\? backward-kill-line kill-line

    # Urxvt: Ctrl + K. Should be already bounded to kill-line by default in fish
    bind \v      kill-line

    # CTRL + Backspace
    bind \e\[5\? backward-kill-path-component

    # Sift enter
    bind \e\[13\;2u execute
    # Ctrl enter
    bind \e\[13\;5u execute

    # Shift arros
    bind \e\[1\;2A ''
    bind \e\[1\;2B ''
    bind \e\[1\;2C forward-bigword
    bind \e\[1\;2D backward-bigword

    # Ctrl Shift arrows
    bind \e\[1\;6A ''
    bind \e\[1\;6B ''
    bind \e\[1\;6C forward-bigword
    bind \e\[1\;6D backward-bigword

    # Ctrl Arrows
    bind \e\[1\;5A ''
    bind \e\[1\;5B ''
    bind \e\[1\;5C forward-word
    bind \e\[1\;5D backward-word

end
