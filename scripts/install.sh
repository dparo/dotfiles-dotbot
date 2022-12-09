#!/usr/bin/env bash

cd "$(dirname "$0")/../" || exit

set -e

source ./roles/zsh/files/.zshenv
source ./roles/zsh/files/.zprofile

if [[ -f "$PWD/requirements.yml" ]]; then
    # ansible-galaxy install -r "$PWD/requirements.yml"
    true
fi

echo "ANSIBLE_HOME: $ANSIBLE_HOME"
echo "ANSIBLE_GALAXY_CACHE_DIR: $ANSIBLE_GALAXY_CACHE_DIR"
echo "ANSIBLE_LOCAL_TEMP: $ANSIBLE_LOCAL_TEMP"

show_all_facts() {
    # Dumps all the ansible facts / variables available
    ansible localhost -m ansible.builtin.setup
}

run() {
    set -x
    ansible-playbook "$PWD/site.yml" "$@"
    rm -rf "$HOME/.ansible"
}

if test "$RUNNING_INSIDE_DOCKER" = ""; then
    run --ask-become-pass --extra-vars "running_inside_docker=false" "$@"
else
    run --extra-vars "running_inside_docker=true" "$@"
fi
