#NoTrayIcon
Action := "shut down"
countdown := 4

Progress, m2 b w400 fm12 fs8 cwffffff R0-%countdown% P%countdown%, press Esc to cancel, Computer will %Action% in %countdown% seconds
Sleep, 1000
countdown -= 1
Loop, %countdown%
{
	Progress, %countdown%
	Progress, , press Esc to cancel, Computer will %Action% in %countdown% seconds
	Sleep, 1000
	countdown -= 1
}
Progress, off

PostMessage("Radial menu - message receiver", 1)	; exit RM
Sleep, 500
Shutdown, 8	; "Power down" value shuts down the system and turns off the power.
;Run, %windir%\system32\shutdown.exe -s -t 0
ExitApp


;===Hotkeys============================================================================
Escape::ExitApp


;===Functions==========================================================================
PostMessage(Receiver,Message) {
	oldTMM := A_TitleMatchMode, oldDHW := A_DetectHiddenWindows
	SetTitleMatchMode, 3
	DetectHiddenWindows, on
	PostMessage, 0x1001,%Message%,,,%Receiver% ahk_class AutoHotkeyGUI
	SetTitleMatchMode, %oldTMM%
	DetectHiddenWindows, %oldDHW%
}  