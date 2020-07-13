#!/bin/zsh
set -euo pipefail

# Remap macOS keyboard
#
# Adapted from: https://www.maven.de/2018/05/more_keyboards/
# Values from: https://opensource.apple.com/source/IOHIDFamily/IOHIDFamily-1035.41.2/IOHIDFamily/IOHIDUsageTables.h.auto.html
# https://github.com/pqrs-org/Karabiner-Elements/issues/2331
# https://github.com/jasonrudolph/keyboard

# if ! [[ -f "${0:A:h}/xpc_set_event_stream_handler" ]]; then
#     echo "Building xpc_set_event_stream_handler"
#     # https://raw.githubusercontent.com/snosrap/xpc_set_event_stream_handler/master/xpc_set_event_stream_handler/main.m
#     clang -fobjc-arc "${0:A:h}/xpc_set_event_stream_handler.m" -o xpc_set_event_stream_handler
# fi

if [ $# -eq 1 ]; then
    PLIST_FILENAME="${HOME}/Library/LaunchAgents/co.fahn.remap.plist"
    cat << EOF >! "${PLIST_FILENAME}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>co.fahn.remap</string>
	<key>ProgramArguments</key>
	<array>
		<string>${0:A:h}/xpc_set_event_stream_handler</string>
		<string>${0:A}</string>
	</array>
	<key>LaunchEvents</key>
	<dict>
		<key>com.apple.iokit.matching</key>
		<dict>
			<key>Convertible 2 TKL</key>
			<dict>
				<key>IOProviderClass</key>
				<string>IOHIDInterface</string>
				<key>VendorID</key>
				<integer>2652</integer>
				<key>ProductID</key>
				<integer>34050</integer>
				<key>IOMatchLaunchStream</key>
				<true/>
			</dict>
			<key>Contour Receiver</key>
			<dict>
				<key>IOProviderClass</key>
				<string>IOHIDInterface</string>
				<key>VendorID</key>
				<integer>2867</integer>
				<key>ProductID</key>
				<integer>8192</integer>
				<key>IOMatchLaunchStream</key>
				<true/>
			</dict>
		</dict>
	</dict>
</dict>
</plist>
EOF
    DOMAIN_TARGET="gui/$(id -u)"
    SERVICE_TARGET="${DOMAIN_TARGET}/co.fahn.remap"
    echo "Booting out existing service"
    launchctl bootout "${SERVICE_TARGET}" || true
    echo "Bootstrapping new service"
    launchctl bootstrap "${DOMAIN_TARGET}" "${PLIST_FILENAME}"
    echo "Kickstarting new service"
    launchctl kickstart -k "${SERVICE_TARGET}"
    exit 0
fi

date
echo "Performing remap.  Install service with \"${ZSH_ARGZERO} install\""
echo

FROM="\"HIDKeyboardModifierMappingSrc\""
TO="\"HIDKeyboardModifierMappingDst\""

C="0x700000006"
V="0x700000019"

ESCAPE="0x700000029"
OPEN_BRACKET="0x70000002F" # [ or {
CLOSE_BRACKET="0x700000030" # ] or }
BACKSLASH="0x700000031" # \ or |
NON_US_POUND="0x700000032" # §/± for UK
GRAVE_TILDE="0x700000035" # `/~
CAPS_LOCK="0x700000039"

F1="0x70000003A"
F2="0x70000003B"
F3="0x70000003C"
F4="0x70000003D"
F5="0x70000003E"
F6="0x70000003F"
F7="0x700000040"
F8="0x700000041"
F9="0x700000042"
F10="0x700000043"
F11="0x700000044"
F12="0x700000045"
F17="0x70000006C"

PRINT_SCREEN="0x700000046"
SCROLL_LOCK="0x700000047"
PAUSE="0x700000048"
INSERT="0x700000049"
HOME="0x70000004A"
PAGE_UP="0x70000004B"
DELETE_FORWARD="0x70000004C"
END="0x70000004D"
PAGE_DOWN="0x70000004E"

APPLICATION="0x700000065" # PC Menu?
POWER="0x700000066"

VOLUME_MUTE="0x70000007F"
VOLUME_UP="0x700000080"
VOLUME_DOWN="0x700000081"
#CSMR_VOLUME_MUTE="0xC000000E2" # Apple keyboard mute
#CSMR_VOLUME_INCREMENT="0xC000000E9" # Apple keyboard volume increment
#CSMR_VOLUME_DECREMENT="0xC000000EA" # Apple keyboard volume decrement

LEFT_CTRL="0x7000000E0"
LEFT_SHIFT="0x7000000E1"
LEFT_ALT="0x7000000E2"
LEFT_GUI="0x7000000E3"
RIGHT_CTRL="0x7000000E4"
RIGHT_SHIFT="0x7000000E5"
RIGHT_ALT="0x7000000E6"
RIGHT_GUI="0x7000000E7"

ISO_BACKSLASH="0x700000064"

MEDIA_PLAY="0xC000000B0"
MEDIA_NEXT="0xC000000B5"
MEDIA_PREV="0xC000000B6"
MEDIA_EJECT="0xC000000B8"

# List all available Services & Devices with:
#   hidutil list

# Convertible 2 TKL
# hidutil property --matching '{"ProductID":0x8502, "VendorID":0xa5c}' --set "{\"UserKeyMapping\":[
# {$FROM: $F6,            $TO: $MEDIA_PREV},
# {$FROM: $F7,            $TO: $MEDIA_PLAY},
# {$FROM: $F8,            $TO: $MEDIA_NEXT},
# {$FROM: $F10,           $TO: $VOLUME_MUTE},
# {$FROM: $F11,           $TO: $VOLUME_DOWN},
# {$FROM: $F12,           $TO: $VOLUME_UP},
# {$FROM: $GRAVE_TILDE,   $TO: $ISO_BACKSLASH},
# {$FROM: $ISO_BACKSLASH, $TO: $GRAVE_TILDE}
# ]}"

# Settings for Apple Keyboards.
hidutil property --matching '{"VendorID":0xa5c}' --set "{\"UserKeyMapping\":[
{$FROM: $CAPS_LOCK,             $TO: $LEFT_SHIFT},
{$FROM: $LEFT_SHIFT,             $TO: $LEFT_CTRL},
{$FROM: $GRAVE_TILDE,             $TO: $F17},
{$FROM: $ISO_BACKSLASH, $TO: $GRAVE_TILDE}
]}"
