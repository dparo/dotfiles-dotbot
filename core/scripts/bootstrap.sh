#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"
mkdir -p ".cache"


source scripts/source.sh

EOF


pkg_install git gcc build-essential emacs gcov lcov watchman nodejs npm \
	cmake cmake-curses-gui cmake-qt-gui ninja-build tmux ruby clang zsh \
	rxvt-unicode kitty qterminal rofi suckless-tools i3 i3lock i3status xclip xsel numlockx xsettingsd fd-find \
	neovim neovim-qt fonts-powerline polybar cloc linux-tools-common linux-tools-generic coz-profiler hotspot heaptrack \
	python3-dev python3-devel meld scite trash-cli copyq agrep shellcheck \
	python3-pip p7zip-full unrar htop mpv kakoune zathura zathura-pdf-poppler light editorconfig \
	fish direnv maim flameshot feh imv sxiv nitrogen ranger nnn vifm jq w3m-img scrot dunst silversearcher-ag ripgrep compton \
	numix-gtk-theme adwaita-icon-theme-full numix-icon-theme arandr curl gparted pandoc gimp \
	mpc ncmpcpp synaptic dvipng imagemagick filezilla git-cola \
	alttab fonts-terminus lm-sensors qt5ct breeze-icon-theme gnome-icon-theme \
	fonts-material-design-icons-iconfont fonts-materialdesignicons-webfont fonts-font-awesome \
	net-tools i3blocks wmctrl xautolock autoconf qpdfview \
	libssl-dev libcurl4-openssl-dev librust-openssl-dev clangd bear ccls \
	pavucontrol audacity graphviz sqlite3 xss-lock seahorse gpg-agent keychain \
	libgtk-3-dev thunar catfish searchmonkey spacefm-gtk3 dbus exa dconf-cli mutt neomutt isync msmtp \
	qtcreator clang-tidy clang-tools clang-format valgrind gperf \
	solaar blueman bluez-tools golang-go libtool libtool-bin libtool-dev gettext \
	libcurl4-openssl-dev librust-openssl-dev r-base \
	qt5-default libglfw3-dev libsdl2-dev libstartup-notification0-dev libxcb-xkb-dev \
	libxcb-xinerama0-dev libxcb-randr0-dev libxcb-util-dev libxcb-ewmh-dev \
	libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-cursor-dev libxcb-xrm-dev \
	libxkbcommon-x11-dev libyajl-dev libcairo2-dev libpango1.0-dev libev-dev \
	lbevdev-dev libconfuse-dev libnl-genl-3-dev \
	texlive-base texlive-full texlive-extra-utils texlive-science latexmk texlive-plain-generic texlive-xetex texlive-luatex \
	gstreamer-1.0 gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad playerctl python3-gst-1.0 \
	libgirepository1.0-dev libsystemd-dev \
	universal-ctags entr httpie rsync \
	python-is-python3 docker automake autoconf \
	libsass-dev libssl-dev \
	doxygen doxygen-gui \
	qemu qemu-utils qemu-system-x86 ovmf \
	cppcheck aspell-it tokei \
	brightnessctl


pkg_install rust-src


pip3 install -U \
	pywal colorz virtualenv \
	numpy matplotlib pandas plotly \
	Pillow notebook jupyterlab scikit-learn \
	i3ipc neovim-remote pynvim tmuxp \
    pycodestyle flake8 autopep8 autoflake \
    black yapf \
	pylint mypy pyre-check \
    'python-lsp-server[all]' pylsp-mypy pyls-isort pyls-black python-lsp-black pyls-memestra \
    jedi jedi-language-server \
    rope \
    debugpy \
	codespell cmakelang cmake-language-server gitlint vim-vint proselint \
	autorandr \
	streamlink spotdl yt-dlp

npm_install() {
	npm install -g --force "$@"
}

npm_install yarn
npm_install typescript @types/node ts-node eslint prettier
npm_install neovim indium
npm_install pyright bash-language-server vscode-langservers-extracted vim-language-server typescript-language-server javascript-typescript-langserver vscode-json-languageserver yaml-language-server vls
npm_install pdf2doi
npm_install tree-sitter-cli
npm_install gramma              # Command line grammar checker: Checks markdown files against the `https://languagetool.org/` api, or by hosting languagetool locally
npm_install nativefier          # Generates "native apps" for website by wrapping the URL in an electron application
npm_install @marp-team/marp-cli # Presentation mode for markdown files. Support conversions to HTML interactive presentations (through electron) or native static PDF presentations.
npm_install write-good

mkdir -p "$HOME/Downloads/dparo-bootstrap"
mkdir -p "$HOME/git-clone"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/Software"

if false; then
	# Install light:
	# https://github.com/haikarainen/light
	pushd "$USER_DOTFILES_LOCATION/core/vendor/light"
	if [ -f "./autogen.sh" ]; then
		./autogen.sh
	fi
	./configure.sh && make
	sudo make install
	popd
fi

# Install RUST
cd "$HOME/Downloads/dparo-bootstrap"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

########### Allow display manager to list and exec user xinitrc file

cat <<'EOF' | sudo tee /usr/local/bin/xinitrcsession-run
#!/bin/bash

entry=""

if [ -n "$XINITRC" ]; then
	entry="$XINITRC"
elif [ -f "$XDG_CONFIG_HOME/X11/xinitrc" ]; then
	entry="$XDG_CONFIG_HOME/X11/xinitrc"
elif [ -f "$HOME/.config/X11/xinitrc" ]; then
	entry="$HOME/.config/X11/xinitrc"
elif [ -f "$HOME/.xinitrc" ]; then
	entry="$HOME/.xinitrc"
fi

if [ -n "$entry" ]; then
	exec "$entry"
fi
EOF

sudo chmod 0775 /usr/local/bin/xinitrcsession-run

cat <<'EOF' | sudo tee /usr/share/xsessions/xinitrc.desktop
[Desktop Entry]
Name=xinitrc
Comment=Executes the .xinitrc script in your home directory
Exec=xinitrcsession-run
TryExec=xinitrcsession-run
Type=Application
EOF

sudo chmod 0664 /usr/share/xsessions/xinitrc.desktop

cat <<'EOF' | sudo tee /etc/pam.d/common-unlock-gnome-keyring
auth       optional     pam_gnome_keyring.so
session    optional     pam_gnome_keyring.so auto_start
EOF

cat <<'EOF' | sudo tee -a /etc/pam.d/login
@include common-unlock-gnome-keyring
EOF

# Fedora configuration
if [ -x /usr/bin/dnf ]; then

	# Setup DNF configuration
	sudo cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.default
	cat <<'EOF' | sudo tee /etc/dnf/dnf.user.conf
deltarpm=True
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
EOF
	cat /etc/dnf/dnf.conf.default /etc/dnf/dnf.user.conf | sudo tee /etc/dnf/dnf.conf

	# Enable RPM fusion free and non-free repositories
	sudo dnf install \
		https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
		https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm

	sudo dnf update -y

	# Install Additional proprietary codecs
	sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
	sudo dnf groupupdate sound-and-video

	# Install NVIDIA drivers if required
	if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -Ei "NVIDIA.*(GeForce|Quadro|Tesla|GTX|RTX)"; then
		sudo dnf update -y # And reboot if you are not on the latest kernel
		sudo dnf install akmod-nvidia
		sudo dnf install xorg-x11-drv-nvidia-cuda # optional for cuda/nvdec/nvenc support
	fi

	# Uninstall libreoffice
	sudo dnf group remove libreoffice

	# Enable Flathub repo for installing flatpaks
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

source ~/.bash_profile
source ~/.bashrc

# Lazygit: https://github.com/jesseduffield/lazygit
# simple terminal UI for git commands
go get github.com/jesseduffield/lazygit

# pprof: https://github.com/google/pprof
# pprof is a tool for visualization and analysis of profiling data.
go get -u github.com/google/pprof

# The program ensures source code files have copyright license headers by
# scanning directory patterns recursively.
# It modifies all source files in place and
# avoids adding a license header to any file that already has one.
go get -u github.com/google/addlicense
go install github.com/mattn/efm-langserver@latest
go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Slides presentation in the terminal from Markdown
go install github.com/maaslalani/slides@latest


# exa (https://github.com/ogham/exa)
# A modern replacement for ‘ls’.
cargo install exa

# ripgrep (https://github.com/BurntSushi/ripgrep)
# ripgrep recursively searches directories for a regex pattern while respecting your gitignore
cargo install ripgrep

# bat (cat core util replacements)
#  Supports syntax highlighting for a large number of programming and markup languages:
cargo install bat

# fd-find (https://github.com/sharkdp/fd)
# A simple, fast and user-friendly alternative to find
cargo install fd-find

# hyperfine (https://github.com/sharkdp/hyperfine)
#  A command-line benchmarking tool
cargo install hyperfine

# delta (better git diff)
cargo install git-delta

# github.com/anordal/shellharden: The corrective bash syntax highlighter
# Shellharden can do what Shellcheck can't: Apply the suggested changes.
# In other words, harden vulnerable shellscripts.
# The builtin assumption is that the script does not depend on the vulnerable
# behavior – the user is responsible for the code review.
cargo install shellharden

# Install dropbox
if [ ! -f "$HOME/.dropbox-dist/dropboxd" ]; then
	pushd "$HOME"
	wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
	popd
fi

# Install Drawio
flatpak install flathub com.jgraph.drawio.desktop

# Install Obisidin MD
flatpak install flathub md.obsidian.Obsidian


# Install deno language
curl -fsSL https://deno.land/x/install/install.sh | sh

# Rust analyzer
curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | \
    gunzip -c - > ~/.local/bin/rust-analyzer
chmod +x ~/.local/bin/rust-analyzer

rustup update
rustup component add rust-src
rustup component add rustfmt
rustup component add clippy
rustup toolchain add nightly


cargo install cargo-audit
cargo install flamegraph # For profiling
