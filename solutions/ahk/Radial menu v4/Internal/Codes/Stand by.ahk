#NoTrayIcon
Action := "stand by"
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

DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
ExitApp


;===Hotkeys============================================================================
Escape::ExitApp