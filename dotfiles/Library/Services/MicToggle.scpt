(*
 * Save as an Automator QuickAction in ~/Library/Services (I called mine
 * MicToggle), then use:
 * System Preference > Keyboard > Shortcuts > Services > MicToggle
 *   Enable it
 *   Also add a shortcut key combo.
 * Boom, global mute toggle key.
 *)

use scripting additions
tell application "System Events"
	set plist to (POSIX path of (path to library folder from user domain) as string) & "/Preferences/" & "com.apple.personal.mictoggle.plist"
	set currentMic to (get volume settings)'s input volume
	try
		set plistFile to property list file plist
	on error
		make new property list file with properties {name:plist}
		set plistFile to property list file plist
	end try
	tell plistFile
		try
			set previousMic to value of property list item "previousMicLevel"
		on error
			try
				set value of property list item "previousMicLevel" to currentMic
			on error
				make new property list item at end with properties {name:"previousMicLevel", value:currentMic}
			end try
		end try
	end tell
	if currentMic is 0 and previousMic is 0 then
		(*if manually muted, unmute compromise to 50*)
		display notification "Unmuted mic"
		set newMic to 50
	else if currentMic is greater than 0 and previousMic is greater than 0 then
		(*if manually unmuted, after having used script to mute*)
		display notification "Muted mic"
		set newMic to 0
	else
		(*otherwise toggle the mute*)
		if currentMic is 0 then
			display notification "Unmuted mic"
			set newMic to previousMic
		else
			display notification "Muted mic"
			set newMic to previousMic
		end if
	end if
	set volume input volume newMic
	tell plistFile
		set value of property list item "previousMicLevel" to currentMic
	end tell
end tell
