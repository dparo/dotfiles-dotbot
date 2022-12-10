#!/usr/bin/env bash
# -*- coding: utf-8 -*-

git_exclude_vault_pass() {
    git config core.excludesFile "$PWD/vault_pass.txt"
    grep -qxE 'vault_pass.txt' "$PWD/.git/info/exclude" || echo 'vault_pass.txt' >>"$PWD/.git/info/exclude"
}

ask_vault_pass() {
    set +x
    if ! test -f "$PWD/vault_pass.txt"; then
        read -r -s -p "ANSIBLE VAULT PASS: " vault_password
        echo "$vault_password" >"$PWD/vault_pass.txt"
    fi
}
