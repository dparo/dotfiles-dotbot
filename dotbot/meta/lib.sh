#!/usr/bin/env bash
# -*- coding: utf-8 -*-

function __install_nerd_fonts {
	pushd /tmp || return 1
	mkdir -p "$HOME/.local/share/fonts"
	for font in "$@"; do
		local outdir="$HOME/.local/share/fonts/$font Nerd Font"
		wget -c "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip"
		mkdir -p "$outdir"
		pushd "$outdir" || return 1
		7z x "/tmp/$font.zip" -aoa
		popd || return 1
	done
	popd || return 1

	# Remove unused fonts and install fonts system-wide for all users
	pushd ~/.local/share/fonts || return 1
	sudo mkdir -p /usr/local/share/fonts
	find . -type f | grep -Ei "\bWindows Compatible.ttf$" | xargs -I {} rm -rf {}
	for font in "$@"; do
		sudo mv "$font Nerd Font" /usr/local/share/fonts
	done
	popd || return 1

	# Refresh the cache
	fc-cache -fvr
}

##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################
## Public functions
##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################


function prompt_yes_no {
	while true; do
		read -r -p "${1} [yN] " yn
		case $yn in
		[Yy]*) return 0 ;;
		*) return 1 ;;
		esac
	done
}

function install_all_fonts {
	__install_nerd_fonts "Hack" "JetBrainsMono" "CascadiaCode" "IBMPlexMono" "LiberationMono" "Meslo" "Noto" "Ubuntu" "UbuntuMono" "SourceCodePro"
	sudo wget "https://github.com/microsoft/vscode-codicons/raw/main/dist/codicon.ttf" -O /usr/share/fonts/codicon.ttf
}


function is_avail {
	which "$@" 1>/dev/null 2>/dev/null
	return $?
}

function curl_get_filename {
	curl -sJLI "$1" | grep -Eioh filename=\".\*\" | sed 's/filename="//g' | sed 's/"$//g'
	return $?
}

function curl_download {
	curl -O -J -L "$1"
	return $?
}

function wget_tar_unpack {
	pushd "$HOME/Downloads" || exit 1
	mkdir -p "$HOME/Software"

	local url="$1"
	local dest="${2:-$HOME/Software}"

	local result=1
	local out
    out=$(curl_get_filename "$url")

	curl_download "$url"

	if [ $? ]; then
		local top_levels
        top_levels=$(tar --exclude='./*/*' -tvf "$out")
		tar xzvf "$out" && mv "$top_levels" "$dest"
		result=$?
	fi

	popd || exit 1
	return "$result"
}


function git_ensure {
	local result=0
	mkdir -p "$HOME/git-clone"
	pushd "$HOME/git-clone" || exit 1
	if [ ! "$(is_avail "$1")" ]; then
		git clone "$2"

		pushd "$(basename "$2")" || exit 1

		if [ -f "./CMakeLists.txt" ]; then
			mkdir -p build
			pushd build || exit 1
			cmake ../ && make all && sudo make install
			result=$?
			popd || exit 1
		elif [ -f "./meson.build" ]; then
			meson build && ninja -C build all && sudo ninja -C build install
			result=$?
		elif [ -f "./autogen.sh" ]; then
			./autogen.sh && ./configure && make all && sudo make PREFIX=/usr/local/bin install
			result=$?
		elif [ -f "Cargo.toml" ]; then
			cargo build --release && cargo install
			result=$?
		elif [ -f "./Makefile" ]; then
			make all && sudo make PREFIX=/usr/local/bin install
			result=$?
		fi

		popd || exit 1
	fi
	popd || exit 1
	return "$result"
}


function update_rust_pkgs {
    cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ' | xargs -I {} bash -c "cargo install {} || true"
}

function update_submodules {
	pushd ../ || exit 1
	git submodule update --init --recursive --remote "dotbot"
	pushd dotbot || exit 1
	git checkout master
	git pull
	popd || exit 1
	git add dotbot
	git commit -m "Dotbot update ($(date))"

	find ./vendor/ -mindepth 1 -maxdepth 1 -type d | while IFS= read -r f; do
		git submodule update --init --recursive --remote "$f"
		pushd "$f" || exit 1
		git checkout -f master
		git checkout -f ./
		git pull
		git submodule update --init --recursive
		popd || exit 1
		git add "$f"
	done

	pushd vendor/neovim || exit 1
	git checkout v0.7.0
	popd || exit 1

	git add vendor/neovim
	git commit -m "Software update ($(date))"
	popd || exit 1
}

function update_themes {
	GTK_THEME="${GTK_THEME:-Adwaita}"
	CURSOR_THEME="${CURSOR_THEME:-Adwaita}"
	ICON_THEME="${ICON_THEME:-Adwaita}"

	local xsettingsd_config="${XDG_CONFIG_HOME:-$HOME/.config}/xsettingsd/xsettingsd.conf"
	local xresources_config="${XDG_CONFIG_HOME:-$HOME/.config}/X11/.Xresources"
	local gtk4_config="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-4.0/settings.ini"
	local gtk3_config="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
	local gtk2_config="${GTK2_RC_FILES:-$HOME/.gtkrc-2.0}"

	if [ ! -f "$xresources_config" ]; then
		xresources_config="$HOME/.Xresources"
	fi

	set -x

	# Setup default cursor
	cat <<EOF 1>~/.local/share/icons/default/index.theme
[Icon Theme]
Name=default
Comment=Default Cursor Theme
Inherits=${CURSOR_THEME}
EOF

	# Symlink legacy ~/.icons/default path to the new XDG one (Required for Xresources and xsettingsd to find the `default` theme)
	if 0; then
		mkdir -p ~/.icons && ln -sfT ~/.local/share/icons/default ~/.icons/default
	fi

	# Update .Xresources
	sed "s@^Xcursor.theme.*@Xcursor.theme: $CURSOR_THEME@g" -i "$xresources_config"

	# Update xsettingsd config first
	sed "s@^Gtk/CursorThemeName.*@Gtk/CursorThemeName   \"$CURSOR_THEME\"@g" -i "$xsettingsd_config"
	sed "s@^Net/ThemeName.*@Net/ThemeName \"$GTK_THEME\"@g" -i "$xsettingsd_config"
	sed "s@^Net/IconThemeName.*@Net/IconThemeName \"$ICON_THEME\"@g" -i "$xsettingsd_config"


    for c in "$gtk2_config" "$gtk3_config" "$gtk4_config"; do
        # Update Gtk-2.0 config
        sed "s@^gtk-theme-name\s*=.*@gtk-theme-name=\"$GTK_THEME\"@g" -i "$c"
        sed "s@^gtk-icon-theme-name\s*=.*@gtk-icon-theme-name=\"$ICON_THEME\"@g" -i "$c"
        sed "s@^gtk-cursor-theme-name\s*=.*@gtk-cursor-theme-name=\"$CURSOR_THEME\"@g" -i "$c"
    done


	# Sync gsettings configuration (Used only by Wayland, X11 sessions respect the XSETTINGS daemon)
	#     See https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland#setting-values-in-gsettings
	local gnome_schema="org.gnome.desktop.interface"
	gsettings set "$gnome_schema" gtk-theme "$GTK_THEME"
	gsettings set "$gnome_schema" icon-theme "$ICON_THEME"
	gsettings set "$gnome_schema" cursor-theme "$CURSOR_THEME"

	set +x

	return 0
}
