if type -q direnv
  function __direnv_export_eval --on-variable PWD
    status --is-command-substitution; and return
    eval (direnv export fish)
  end
else
  echo "Install direnv first! Check http://direnv.net" 2>&1
end



# Stop showing the greeting message: "Welcome to fish, the friendly interactive shell"
set -U fish_greeting ""

if test (type -P exa)

# Exa for some reasons crashes under certain scenarios, if these happens
# run ls as replacement
    function ls
        exa $argv 2> /dev/null; or command ls --color=auto -h $argv
    end
    function la
        exa -lah $argv 2> /dev/null; or command ls --color=auto -lah $argv
    end
    function ll
        exa -laFh $argv 2> /dev/null; or command ls --color=auto -laFh $argv
    end
else
    alias ls='ls --color=auto -h'
    alias la='ls -lah --color=auto -h'
    alias ll='ls -laFh --color=auto -h'
end



if test (type -P bat)
    alias cat='bat'
    alias less='bat'
end

if test (type -P fdfind)
    alias fd='fdfind'
end



## I don't know, this alias seems wild and unsafe
##
# alias fish='exec bash -c "source ~/.config/zsh/.zshenv && fish"'


if test (type -P mimeopen)
    alias open='mimeopen'
    alias xdg-open='mimeopen'
end


alias :q='exit'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ag='ag -i --follow --hidden --no-heading --ignore \'^(\\.ccls-cache)\''
alias rg='rg -i --follow --hidden --no-heading -g !.git -g !.ccls-cache'
alias ec='emacsclient --create-frame'
alias cls='printf "\033c"'
alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'
alias gdb='gdb -nh -x \"$XDG_CONFIG_HOME/gdb/init\"'
alias svn='svn --config-dir \"$XDG_CONFIG_HOME/subversion\"'
alias vim='nvim'
alias dragon='dragon -x -a'
alias fm="run nemo "(pwd)""
alias gksu='pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY'

alias watchmake=watchman-make

alias rm='rmtrash'
alias rmdir='rmdirtrash'


function gcca
    git add --all; and git commit -m ""; and git push
end



if test -d "$HOME/anaconda3/bin";
    source "$HOME/anaconda3/etc/fish/conf.d/conda.fish"
end
