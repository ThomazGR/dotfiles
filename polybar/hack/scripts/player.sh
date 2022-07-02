#!/bin/bash

firefoxInstance=$(dbus-send --session \
					--dest=org.freedesktop.DBus \
					--print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames | \
					fgrep org.mpris.MediaPlayer2.firefox | \
					head -1 | \
					awk '{print $2}' | \
					sed -e 's:"::g')


if [[  "$firefoxInstance" == "" ]] ; then
	echo "Nothing is playing :("
fi

isPaused=$(dbus-send --print-reply \
			--dest=$firefoxInstance \
			/org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
			string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus' | \
			tail -n 1 | \
			grep -oP '(?<= ").*?(?=")')

songTitle=$(dbus-send --print-reply \
			--dest=$firefoxInstance \
			/org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
			string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | \
			grep -E 'xesam:title' -A 1 | \
			tail -n 1 | \
			grep -oP '(?<= ").*?(?=")')

songArtist=$(dbus-send --print-reply \
			--dest=$firefoxInstance \
			/org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
			string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | \
			grep -E 'xesam:artist' -A 2 | \
			tail -n 1 | \
			grep -oP '(?<= ").*?(?=")')

if [[ "$songArtist" == "" ]] ; then
	songArtist="No artist"
else
	:
fi

if [[ "$songTitle" == "" ]] ; then
	songTitle="No title"
else
	:
fi

if [[ "$isPaused" == "Paused" ]] ; then
	echo " ${songTitle:0:20} - ${songArtist:0:20}"
elif [[ "$isPaused" == "Playing" ]] ; then
	echo " ${songTitle:0:20} - ${songArtist:0:20}"
fi
