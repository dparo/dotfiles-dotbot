#!/usr/bin/env bash
# -*- coding: utf-8 -*-

git_exclude_vault_pass() {
    git config core.excludesFile "$PWD/vault_pass.txt"
    grep -qxE 'vault_pass.txt' "$PWD/.git/info/exclude" || echo 'vault_pass.txt' >>"$PWD/.git/info/exclude"
}
