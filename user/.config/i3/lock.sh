#!/usr/bin/env bash

lock() {
	if test "$(pgrep -u "$(whoami)" 'i3lock(-fancy)?$')"; then
		true
	else
		pgrep -u "$(whoami)" picom
		local picom_status=$?
		pkill -u "$(whoami)" -KILL picom

        xset +dpms
        xset dpms 0 0 10
        ( sleep 1 && xset dpms force off ) &
		i3lock --show-failed-attempts --nofork --ignore-empty-password \
            -t -c "#1a1b26"
        xset dpms force on
        xset dpms 0 0 0
        xset -dpms


		#i3lock-fancy -- maim

		if pgrep -u "$(whoami)" picom && [ "$picom_status" -eq 0 ]; then
			run picom
		fi
	fi
}

case "$1" in
	lock)
		lock
		;;
	logout)
		i3-msg exit
		;;
	suspend)
        (lock &); sleep 2; systemctl suspend
		;;
	hibernate)
        (lock &); sleep 2; systemctl hibernate
		;;
	reboot)
		systemctl reboot
		;;
	shutdown|poweroff)
		systemctl poweroff
		;;
	*)
		echo "Usage: $0 {lock|logout|suspend|hibernate|reboot|shutdown}"
		exit 2
		;;
esac

exit 0
