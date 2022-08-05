# .zprofile is for login shells. It is basically the same as .zlogin except
# that it's sourced before .zshrc whereas .zlogin is sourced after .zshrc.
# According to the zsh documentation, ".zprofile is meant as an alternative to .zlogin
# for ksh fans; the two are not intended to be used together,
# although this could certainly be done if desired."


# NOTE(dparo): login shells do not source the zshrc regardless.
#           So .zprofile and .zlogin run one after the other,
#           and are basically identical


# User specific environment and startup programs
export LANGUAGE="en_US"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"


# Setup programs default config location to avoid cluttering the HOME directory
export XINITRC="$XDG_CONFIG_HOME/X11/xinitrc"
export XSERVERRC="$XDG_CONFIG_HOME/X11/xserverrc"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
export LESSHISTFILE="$XDG_CACHE_HOME/lesshst"
export ASPELL_CONF="per-conf $XDG_CACHE_HOME/aspell/aspell.conf; personal $XDG_CACHE_HOME/aspell/en.pws; repl $XDG_CACHE_HOME/aspell/en.prepl"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export KDEHOME="$XDG_CONFIG_HOME/kde"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_DIR="$XDG_DATA_HOME/npm"
export DENO_DIR="$XDG_DATA_HOME/deno"
export DENO_INSTALL_ROOT="$XDG_DATA_HOME/deno/bin"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export CONDARC="$XDG_CONFIG_HOME/conda/condarc"
export PYLINTHOME="${XDG_CACHE_HOME}/pylint"
export MYPY_CACHE_DIR="$XDG_CACHE_HOME/mypy"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GOPATH="$XDG_DATA_HOME/go"
export NIMBLE_DIR="$XDG_DATA_HOME/nimble"
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history"
export TEXMFHOME="$XDG_DATA_HOME/texmf"
export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
export TEXMFCONFIG="$XDG_CONFIG_HOME/texlive/texmf-config"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export __GL_SHADER_DISK_CACHE_PATH="$XDG_CACHE_HOME/nv"
export ANDROID_HOME="$XDG_DATA_HOME/android"
export WINEPREFIX="$XDG_DATA_HOME/wine"

# Supported only from Maven 4
export MAVEN_ARGS="-s $XDG_CONFIG_HOME/maven/settings.xml"
# For compatibility with maven-wrapper scripts (https://github.com/takari/maven-wrapper)
export MAVEN_CONFIG="-s $XDG_CONFIG_HOME/maven/settings.xml"


# Default CMAKE_GENERATOR
export CMKAE_GENERATOR=Ninja
##
## This is the typical DBUS session address that is used when DBUS
## is started from systemd.
## Question to myself??? Do some applications require this environment
## variable to be exposed, or they can access it implicitly by systemd integration???
# NOTE(dparo): See .xinitrc, we export it there
# export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID/bus"


export STEAM_FRAME_FORCE_CLOSE=1
#export VISUAL="nvim -R -m -M"         # Does not work :(


export MANWIDTH=80
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'



export FZF_DEFAULT_COMMAND='rg -S --files --hidden -g !.ccls-cache -g !.git -g !.vcs -g !.svn'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='find -type d'

export MAKEFLAGS=--no-print-directory


# Use the gpg-agent provided SSH emulation.
#    gpg-agent is nicer, because on Arch Linux it can be started
#    through systemd and has socket activation support.
#    Ask the gpg-agent connection directly for which ssh socket
#    is it listening to.
# The env variable SSH_AUTH_SOCK, is required to make ssh utilities,
# such as `ssh-add` to work.
unset SSH_AGENT_PID
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"


##
## Better font rendering for Java applications, useful if not running xsettings daemon
##
export JDK_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

# See: https://wiki.archlinux.org/title/java#Gray_window,_applications_not_resizing_with_WM,_menus_immediately_closing
export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit


if systemctl -q is-active graphical.target \
	&& [ -z "${DISPLAY}" ] && [ -z "$SSH_CLIENT" ]
    ( [ "$(tty)" = "/dev/tty1" ] || [ "$(tty)" = "/dev/tty2" ] || [ "$(tty)" = "/dev/tty3" ] || [ "$(tty)" = "/dev/tty4" ]); then
	exec startx "${XDG_CONFIG_HOME:-$HOME/.config}/X11/xinitrc"
fi
