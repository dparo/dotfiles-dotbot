#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")" || exit
cd ../ || exit

function rebuild_gf_debugger {
	pushd "vendor/gf" || return 1
	./build.sh
	mv --force gf2 ~/.local/bin/gf2
	popd || return 1
}

function update_python_packages {
	mkdir -p temp
	pip3 freeze >temp/requirements.txt
	pip3 install --upgrade -r temp/requirements.txt
	rm -f temp/requirements.txt

	# Deletes the pip3 cache which can accumulate to high disk usage after a while
	pip cache purge
}

function update_npm_modules {
	npm update -g
}

function rebuild_sumneko_lua_lang_server {
	pushd "vendor/lua-language-server" || return 1
	cd 3rd/luamake || return 1

	## Do not call the provided install.sh script since it modifies shell config files
	## that we do no want. Since it doesn't provide a flag to not do this,
	## we are going to simply call ninja directly
	#            ./compile/install.sh
	ninja -f compile/ninja/linux.ninja
	cd ../.. || return 1
	./3rd/luamake/luamake rebuild
	popd || return 1
}

function update_rust {
	rustup update

	# Update rust analyzer
	curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - >~/.local/bin/rust-analyzer
	chmod +x ~/.local/bin/rust-analyzer
}

function update_rust_pkgs {
	cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ' | xargs -I {} bash -c "cargo install {} || true"
}

function update_julia {
	# Install/Update Julia language server
	julia --project="$HOME/.julia/environments/nvim-lspconfig" -e 'using Pkg; Pkg.add("LanguageServer")'
	julia --project="$HOME/.julia/environments/nvim-lspconfig" -e 'using Pkg; Pkg.update()'
}

##
## PROMPT
##

test "$1" = "--yes"
YES=$?

function prompt {
	if [ "$YES" -eq 0 ]; then
		return 0
	fi
	while true; do
		read -r -p "${1} [yN] " yn
		case $yn in
		[Yy]*) return 0 ;;
		*) return 1 ;;
		esac
	done
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

function update_pkgs {
	update_submodules
	mkdir -p temp
	prompt "Do you wish to upgrade Deno?" && deno upgrade
	prompt "Do you wish to upgrade rust/cargo?" && update_rust
	prompt "Do you wish to update all NPM modules?" && update_npm_modules
	prompt "Do you wish to update all python3 packages?" && update_python_packages

	if which julia; then
		prompt "Do you wish to update the Julia language server" && update_julia
	fi
}

function update_pkgs_slow {
	prompt "Do you wish to rebuild sumneko/lua-language-server" && rebuild_sumneko_lua_lang_server
	prompt "Do you wish to upgrade rust packages?" && update_rust_pkgs
}

function update_themes {
	GTK_THEME="${GTK_THEME:-Adwaita}"
	CURSOR_THEME="${CURSOR_THEME:-Adwaita}"
	ICON_THEME="${ICON_THEME:-Adwaita}"

	local xsettingsd_config="${XDG_CONFIG_HOME:-$HOME/.config}/xsettingsd/xsettingsd.conf"
	local xresources_config="${XDG_CONFIG_HOME:-$HOME/.config}/X11/.Xresources"
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

	# Update Gtk-2.0 config
	sed "s@^gtk-theme-name\s*=.*@gtk-theme-name=\"$GTK_THEME\"@g" -i "$gtk2_config"
	sed "s@^gtk-icon-theme-name\s*=.*@gtk-icon-theme-name=\"$ICON_THEME\"@g" -i "$gtk2_config"
	sed "s@^gtk-cursor-theme-name\s*=.*@gtk-cursor-theme-name=\"$CURSOR_THEME\"@g" -i "$gtk2_config"

	# Update Gtk-3.0 config
	sed "s@^gtk-theme-name\s*=.*@gtk-theme-name=$GTK_THEME@g" -i "$gtk3_config"
	sed "s@^gtk-icon-theme-name\s*=.*@gtk-icon-theme-name=$ICON_THEME@g" -i "$gtk3_config"
	sed "s@^gtk-cursor-theme-name\s*=.*@gtk-cursor-theme-name=$CURSOR_THEME@g" -i "$gtk3_config"

	# Sync gsettings configuration (Used only by Wayland, X11 sessions respect the XSETTINGS daemon)
	#     See https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland#setting-values-in-gsettings
	local gnome_schema="org.gnome.desktop.interface"
	gsettings set "$gnome_schema" gtk-theme "$GTK_THEME"
	gsettings set "$gnome_schema" icon-theme "$ICON_THEME"
	gsettings set "$gnome_schema" cursor-theme "$CURSOR_THEME"

	set +x

	return 0
}

function main {
	if test "$1" == "--themes"; then
		shift
		update_themes "$@"
	elif test "$1" == "--slow-pkgs"; then
		shift
		update_pkgs_slow "$@"
	else
		update_pkgs "$@"
	fi
}

main "$@"
