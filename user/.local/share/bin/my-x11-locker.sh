#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")" || exit 1

xset +dpms
xset dpms 0 0 15
env XSECURELOCK_AUTH_TIMEOUT=20 XSECURELOCK_BLANK_TIMEOUT=2 XSECURELOCK_SHOW_DATETIME=1 XSECURELOCK_SHOW_HOSTNAME=1 XSECURELOCK_SHOW_USERNAME=1 xsecurelock
xset dpms force on
xset dpms 0 0 0
xset -dpms
