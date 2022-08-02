#!/usr/bin/env bash

set -e

function is_avail {
    which "$@" 1> /dev/null 2> /dev/null
    return $?
}


PKG_EXT=""
IS_UBUNTU=$(cat /etc/os-release | egrep -i '^NAME\b' | egrep -i Ubuntu)
IS_FEDORA=$(cat /etc/os-release | egrep -i '^NAME\b' | egrep -i Fedora)

if $(is_avail apt); then
    PKG_EXT="deb"
elif $(is_avail dnf); then
    PKG_EXT="rpm"
fi


function pkg_install {
    # Install packages using the package manager. Do not prompt (yes/no)
    # for install, and skip any non retriavable package. That is, if given
    # a list of packages one package cannot be found, still install
    # the remaining packages

    # Unfortunately if APT doesn't find a package from the entire list it refueses to install
    # all the other packages in the list. Thus we are forced to use this hacky
    # way of calling APT for each package (SUPER SLOW!!! FUCK YOU APT). I don't know if DNF
    # suffers from the same problems. We need to test it
    if $(is_avail apt); then
        echo "$@" | sed 's/-devel$/-dev/g' | xargs -d ' ' -I {} sudo apt-get install -y {}
    elif $(is_avail dnf); then
        echo "$@" | sed 's/-dev$/-devel/g' | xargs -d ' ' -I {} sudo dnf install -y {}
    fi
}

function curl_get_filename {
    curl -sJLI "$1"| egrep -ioh filename=\".\*\" | sed 's/filename="//g' | sed 's/"$//g'
    return $?
}

function curl_download {
    curl -O -J -L "$1"
    return $?
}

function wget_pkg_install {
    pushd "$HOME/Downloads"
    for v in "$@"
    do
        local out_file=$(curl_get_filename "$v")
        if [ $(echo "$out_file" | egrep -i "$PKG_EXT\$") ]; then
            curl_download "$v" && pkg_install "$out_file"
            rm "$out_file"
        fi
    done
    popd
}

function wget_tar_unpack {
    pushd "$HOME/Downloads"
    mkdir -p "$HOME/Software"


    local url="$1"
    local dest="${2:-$HOME/Software}"


    local result=1
    local out=$(curl_get_filename "$url")

    curl_download "$url"

    if [ $? ]; then
        local top_levels=$(tar --exclude='./*/*' -tvf "$out")
        tar xzvf "$out" && mv "$top_levels" "$dest"
        result=$?
    fi

    popd
    return $result
}


function wget_ensure {
    is_avail "$1" || wget_pkg_install "${@:2}"
    return $?
}

function git_ensure {
    local result=0
    mkdir -p "$HOME/git-clone"
    pushd "$HOME/git-clone"
    if [ ! $(is_avail "$1") ]; then
        git clone "$2"

        pushd $(basename "$2")

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
    return $result
}
