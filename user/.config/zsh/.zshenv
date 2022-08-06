export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
# To let the Application launcher (such as ROFI)
# find distribution specific application files (including snap/flatpak installed applications)
# it is important to populate the XDG_DATA_DIRS, which is analogue to
# the XDG_DATA_HOME but for system wide stuff
export XDG_DATA_DIRS="$XDG_DATA_HOME/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/share/ubuntu:/usr/share/gnome:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop:$XDG_DATA_DIRS"


export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export USER_DOTFILES_LOCATION="$HOME/src/git/dparo/dotfiles"
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER="sh -c 'col -bx | bat -l man -p --paging always'"

export GPG_TTY="$(tty)"



# @NOTE: Path prepends WIN over standard /usr/bin and /usr/local/bin paths
# @NOTE: Path adds have LOWER precedence compared to standard /usr/bin and /usr/local/bin paths

pathadd() {
    # Forward iteration of function's args
    local p
    for p in "$@"; do
        if [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]]; then
            PATH="${PATH:+"$PATH:"}$p"
        fi
    done
    export PATH
}

pathprepend() {
    # Iterate args to function in reversed, C-style indexing
    local i
    local p
    for ((i = $#; i > 0; i--)); do
        # Expands to p=$i where is the current parameter index
        eval local p="\${$i}"
        if [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]]; then
            PATH="$p${PATH:+":$PATH"}"
        fi
    done
    export PATH
}


# pathprepend: Inserts higher precedence paths
pathprepend \
    "$USER_DOTFILES_LOCATION/core/vendor/fzf/bin" \
    "$XDG_DATA_HOME/bin" \
    "$HOME/.local/bin" \
    "${PYTHONUSERBASE:-$XDG_DATA_HOME/python}/bin" \
    "${GOPATH:-$XDG_DATA_HOME/go}/bin" \
    "${CARGO_HOME:-$XDG_DATA_HOME/cargo}/bin" \
    "${npm_config_prefix:-$HOME/.local/share/npm}/bin" \
    "${DENO_DIR:-$XDG_DATA_HOME/deno}/bin" \
    "${BUN_INSTALL:-$XDG_DATA_HOME/bun}/bin" \
    "$XDG_DATA_HOME/zig" \
    "${NIMBLE_DIR:-$XDG_DATA_HOME/nimble}/bin" \
    "$HOME/.local/jdt-language-server/bin"