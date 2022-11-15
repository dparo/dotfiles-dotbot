#!/usr/bin/env bash
# -*- coding: utf-8 -*-

i3-msg '[ instance="crx_cifhbcnohmdccbgoicgdjpfamggdegmo" class="Google-chrome" ] scratchpad show, move position center' \
    || gtk-launch chrome-cifhbcnohmdccbgoicgdjpfamggdegmo-Default.desktop
