#!/usr/bin/env bash

set -x
set -e

source /etc/os-release

if ! test -x "$(command -v ansible)"; then
    case $ID in
    ubuntu)
        sudo apt update
        sudo apt install -y git ansible
        ;;

    arch)
        sudo pacman -S --noconfirm git ansible
        ;;
    esac
fi

DOTFILES_LOCATION="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"
if ! test -d "$DOTFILES_LOCATION"; then
    mkdir -p "$DOTFILES_LOCATION"
    git clone --recursive "https://github.com/dparo/dotfiles" "$DOTFILES_LOCATION"
fi

ask_vault_pass() {
    set +x
    read -r -s -p "ANSIBLE VAULT PASS: " vault_password
    echo "$vault_password" > "$PWD/vault_pass.txt"
}

main() {
    source "$PWD/scripts/lib.sh"

    set +x
    ask_vault_pass
    set -x

    git_exclude_vault_pass

    ./ansible/scripts/install.sh "$@"
    if test "$?" -eq 0; then
        while true; do
            echo ""
            echo ""
            echo ""
            echo "It is recommended to reboot after installing the dotfiles for the first time."
            read -p -r "Do you want to reboot now? [yn]" yn
            case $yn in
            [Yy]*) systemctl reboot ;;
            [Nn]*) ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi
}

pushd "$DOTFILES_LOCATION" || exit 1
main "$@"
