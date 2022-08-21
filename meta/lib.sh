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
	pushd "$HOME/Downloads"
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

	popd
	return "$result"
}


function git_ensure {
	local result=0
	mkdir -p "$HOME/git-clone"
	pushd "$HOME/git-clone"
	if [ ! "$(is_avail "$1")" ]; then
		git clone "$2"

		pushd "$(basename "$2")"

		if [ -f "./CMakeLists.txt" ]; then
			mkdir -p build
			pushd build
			cmake ../ && make all && sudo make install
			result=$?
			popd
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

		popd
	fi
	popd
	return "$result"
}
