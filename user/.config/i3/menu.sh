#!/bin/bash

ask=""

if [ "$1" == "" ]; then

	CHOICES=$(
		cat <<EOF
Session control
Lock screen
Audio
Display
NetworkManager: DMENU
NetworkManager: Applet
NetworkManager: TUI
NetworkManager: Edit Connection
Bluetooth Manager
Bluetooth Applet
Manage SSH & GPG
Ubuntu Software Properties
Edit i3 config
EOF
	)
	ask=$(echo "$CHOICES" | rofi -dmenu -i -matching fuzzy)
else
	ask="$1"
fi

declare -A commands

commands['EXIT']=''
commands['Lock screen']="$HOME/.config/i3/lock.sh lock"
commands['Audio']='pavucontrol'
commands['Display']='arandr'
commands['Manage SSH & GPG']=seahorse
commands['Ubuntu Software Properties']=software-properties-gtk
commands['NetworkManager: DMENU']=networkmanager_dmenu
commands['NetworkManager: Applet']='pkill nm-applet; nm-applet'
commands['NetworkManager: TUI']='kitty -- nmtui'
commands['NetworkManager: Edit Connections']=nm-connection-editor
commands['Bluetooth Manager']='blueman-manager'
commands['Bluetooth Assistant']='blueman-assistant'
commands['Bluetooth Applet']='blueman-applet'
commands['Bluetooth Tray']='blueman-tray'
commands['Session control']="i3-nagbar -t warning -m 'Session Control' \
                            -B 'Logout' '~/.config/i3/lock.sh logout' \
                            -B 'Reboot' '~/.config/i3/lock.sh reboot' \
                            -B 'Shutdown' '~/.config/i3/lock.sh shutdown' \
                            -B 'Suspend (RAM)' '~/.config/i3/lock.sh suspend' \
                            -B 'Hibernate - Deep Sleep (HDD)' '~/.config/i3/lock.sh hibernate'"

exec bash -c "${commands[$ask]}"
