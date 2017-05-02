#!/bin/bash -x
sudo apt install -y pulseaudio pavucontrol paprefs avahi-utils
sudo apt install -y pulseaudio-module-zeroconf avahi-daemon

paprefs &
pavucontrol &

pulseaudio -k # restarts pulseaudio
