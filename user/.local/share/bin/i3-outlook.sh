#!/usr/bin/env bash
# -*- coding: utf-8 -*-

i3-msg '[ instance="crx_pkooggnaalmfkidjmlhoelhdllpphaga" class="Google-chrome" ] scratchpad show, move position center' \
    || gtk-launch chrome-pkooggnaalmfkidjmlhoelhdllpphaga-Default.desktop
