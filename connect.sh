#!/bin/bash

#---------------------------------------------------------------
# By John Hamelink <john@johnhamelink.com>
#---------------------------------------------------------------
# Credit to Ric123 and megamanextent for the primer material
# found at UbuntuForums.Org
#---------------------------------------------------------------
# Based on the work of Alex Zaballa (02/24/2011)
# Distributed under GPL v.2.
#---------------------------------------------------------------

#clear

paID=""
qPath=""


unmute() {
	echo "Unmuting"
	su pi -c 'pacmd "set-sink-mute 0 0"'
}

mute() {
	echo "Muting"
	su pi -c 'pacmd "set-sink-mute 0 1"'
}

connect() {
	# Return Example: /org/bluez/29159/hci0/dev_01_23_45_AB_CD_EF
	qPath="$(qdbus --system org.bluez | grep -m 1 "/dev_")"

	mute

	# Even though the phone says it's connected, it doesn't work
	# unless I hard-reset the connection. Also, AudioSource.Disconnect
	# won't work reliably in this situation, so I tried the Device.Disconnect
	# method which seems to work well for my Gingerbread Hero (Android 2.3).
	#qdbus --system org.bluez "${qPath}" org.bluez.Device.Disconnect 1> /dev/null
	sleep 5
	echo "[Connecting] Attempting connection..."
	qdbus --system org.bluez "${qPath}" org.bluez.AudioSource.Connect 1> /dev/null

	unmute

	# Return Example: bluez_source.01_23_45_AB_CD_EF
	bluezSource="$(su pi -c "pactl list" | grep -m 1 "Name: bluez_source" | cut -c 8-)"
	echo "[Connected] Bluez Source: ${bluezSource}"

	# Return Example: alsa_output.pci-0000_00_10.1.analog-stereo
	alsaSink="$(su pi -c "pactl list" | grep -m 1 "Name: alsa_output" | cut -c 8-)"
	echo "[Connected] Alsa Sink: ${alsaSink}"

	# Return Example: 25
	paID=$(su pi -c "pactl load-module module-loopback source=${bluezSource} sink=${alsaSink}")
	echo "[Connected] pactl ID number: ${paID}"
}

disconnect() {
 
	mute
	echo "[Disconnected] Unloading module: ${paID}"
	su pi -c "pactl unload-module ${paID}"
	qPath="$(qdbus --system org.bluez | grep -m 1 "/dev_")"
	qdbus --system org.bluez "${qPath}" org.bluez.AudioSource.Disconnect 1> /dev/null
	echo "[Disconnected] Device disconnected, restarting..."
      
}

main() {
	echo "Waiting for connection..."
	while :
	do
		qPath="$(su pi -c 'pactl list' | grep -m 1 'Name: bluez_source' | cut -c 8-)"
		if [ "$qPath" != ""  ]
		then
			echo "Found ${qPath}, connecting..."
			connect
			break
		fi

		echo "[Disconnected] Zzz..."
		sleep 1
	done

}

# Signal handling allows us to 
# Cleanly exit the program.
trap mute EXIT

# Engage!
main

while :
do
	qPath="$(su pi -c 'pactl list' | grep -m 1 'Name: bluez_source' | cut -c 8-)"

	if [ -z "${qPath}" ]
	then
		disconnect
		main
	fi
	
	echo "[Connected] Zzz..."
	sleep 5
done


