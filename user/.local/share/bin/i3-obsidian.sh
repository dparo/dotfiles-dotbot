#!/usr/bin/env bash
# -*- coding: utf-8 -*-

i3-msg '[ instance="obsidian" class="obsidian" window_role="browser-window" ] scratchpad show, move position center' \
    || gtk-launch obsidian.desktop
