#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")" || exit 1


docker build -t dotfiles . && exec docker run --interactive -t dotfiles
