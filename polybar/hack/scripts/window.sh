#!/bin/bash

WM_DESKTOP=$(xdotool getwindowfocus)

if [ $WM_DESKTOP == "4194312" ]; then

	echo "%{F#ffffff}Desktop%{u-}"

elif [ $WM_DESKTOP != "1883" ]; then

	WM_CLASS=$(xprop -id $(xdotool getactivewindow) WM_CLASS | cut -d ',' -f 2 | grep -oP '"\K[^"]+')
	#$(xprop -id $(xdotool getactivewindow) WM_CLASS | awk 'NF {print $NF}' | sed 's/"/ /g')
	WM_NAME=$(xprop -id $(xdotool getactivewindow) WM_NAME | cut -d '=' -f 2 | grep -oP '"\K[^"]+')
	#$(xprop -id $(xdotool getactivewindow) WM_NAME | cut -d '=' -f 2 | awk -F\" '{ print $2 }')

	if [ $WM_CLASS == 'Gnome-terminal' ]; then

		echo "%{F#ffffff}Terminal%{u-}"

	elif [ $WM_CLASS == 'firefox' ]; then

		echo "%{F#ffffff}Firefox%{u-}"
	
	#elif [ $WM_NAME == 'Enter WM_NAME value here' ]; then

	#	echo "%{F#ffffff}Custom name%{u-}"

	else

		echo "%{F#ffffff}$WM_NAME%{u-}"

	fi

fi
