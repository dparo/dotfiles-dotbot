#!/usr/bin/env bash

cd "$(dirname "$0")/../" || exit

set -e

source "$PWD/scripts/lib.sh"

show_all_facts() {
    # Dumps all the ansible facts / variables available
    ansible localhost -m ansible.builtin.setup
}

run() {
    if [[ -f "$PWD/requirements.yml" ]]; then
        # ansible-galaxy install -r "$PWD/requirements.yml"
        true
    fi

    set -x

    if test -f "$PWD/vault_pass.txt"; then
        ansible-playbook "$PWD/site.yml" -e "@$PWD/secrets_file.enc" --vault-password-file "$PWD/vault_pass.txt" "$@"
    else
        ansible-playbook "$PWD/site.yml" -e "@$PWD/secrets_file.enc" --ask-vault-pass "$@"
    fi

    rm -rf "$HOME/.ansible"
}

source "$PWD/scripts/lib.sh"
source ./roles/zsh/files/.zshenv
source ./roles/zsh/files/.zprofile

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/ansible"
echo "vault_pass.txt" >"${XDG_CONFIG_HOME:-$HOME/.config}/ansible/.gitignore"

echo "ANSIBLE_HOME: $ANSIBLE_HOME"
echo "ANSIBLE_GALAXY_CACHE_DIR: $ANSIBLE_GALAXY_CACHE_DIR"
echo "ANSIBLE_LOCAL_TEMP: $ANSIBLE_LOCAL_TEMP"

git_exclude_vault_pass

if grep -qE 'hypervisor' /proc/cpuinfo; then
    export RUNNING_INSIDE_VM=1
fi

if test "${RUNNING_INSIDE_DOCKER:-0}" -eq 1; then
    run --extra-vars "running_inside_docker=true" "$@"
elif test "${RUNNING_INSIDE_VM:-0}" -eq 1; then
    run --ask-become-pass --extra-vars "running_inside_vm=true" "$@"
else
    run --ask-become-pass --extra-vars "running_inside_docker=false" --extra-vars "running_inside_vm=false" "$@"
fi
