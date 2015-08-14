;=== MY MOUSE GESTURES ===
; This file is included in main Radial menu script. You can create your mouse gestures here.



MG_R() {    ; example
	MsgBox, 64, RM - mouse gesture example, Hello! I'm mouse gesture %A_ThisFunc%.`nYou can edit me in RM\My codes\My mouse gestures.ahk
}

MG_L() {    ; example
	MsgBox, 64, RM - mouse gesture example, Hello! I'm mouse gesture %A_ThisFunc%.`nYou can edit me in RM\My codes\My mouse gestures.ahk
}

MG_U() {
	RMApp_Navigator()	; shows Navigator
}

/*
MG_RD() {   ; example. Closes active window.
	ActiveWinID := RMApp_Reg("ActiveWinID")	; window that was active in a moment when you pressed RMShowHotkey
	WinClose, ahk_id %ActiveWinID%
}
*/






/*===Description======================================================================================
MyMouseGestures.ahk is tabula rasa, and it's up to you to write your commands in it and create your own mouse gestures system.
If you not't like mouse gestures, simply delete all functions in this file. 

When you press RMShowHotkey, RM stores some useful info:
- unique ID number (hwnd) of window under the mouse cursor. To get it, call:   WinUMID := RMApp_Reg("WinUMID")   ; "UM" means "under mouse".
- unique ID number (hwnd) of active window. To get it, call:   ActiveWinID := RMApp_Reg("ActiveWinID")
- class of the control under the mouse cursor. To get it, call:   ControlUMClass := RMApp_Reg("ControlUMClass")
- unique ID number (hwnd) of the control under the mouse cursor. To get it, call: ControlUMID := RMApp_Reg("ControlUMID")
- class of control that has input focus in active window. To get it, call ControlFocClass := RMApp_Reg("ControlFocClass")
- x coordinate relative to screen.  To get it, call:   x := RMApp_Reg("x")
- y coordinate relative to screen.  To get it, call:   y := RMApp_Reg("y")
To get current profile, call: CurrentProfile := RMApp_Reg("CurrentProfile")
*/


/*===Tips===
I planned to implement my private mouse gestures system, but I found that's a bad idea, because 
everyone has his own specific needs. My system could also scare first time RM user. 

I mostly use mouse gestures to manage virtual desktops, arrange windows and show Navigator.

I'll give you a few tips:
-	Visit http://virtuawin.sourceforge.net It's a virtual desktop program that accepts window messages.
	Check out "External Interface" in Virtuawin help. You can send messages to Virtuawin by drawing RM gestures. 
	MG_R() may switch to right virtual desktop desktop, MG_L() to left, MG_UR() may move active window
	to right desktop, MG_UL() to left, MG_UD() to central... It's a great feeling when you can change your
	desktops so easily - just by dragging Rbutton for 9 pixels to right or left. I strongly recommend it.
	If there will be interset, I'll post my private set of functions for controling Virtuawin by RM mouse gestures. 
-	MG_RD() may close active window...
-	don't forget modifiers; for example, some mouse gesture with control key down can do one thing, with alt another, with shift
	someting else, and without modifier, something that you use most often...
-	don't forget profiles, you can have profile-sensitive mouse gestures; for example, some mouse gesture may do one thing in
	"Main profile", another thing in "Work profile"...
-	You may create context sensitive mouse gestures for Windows explorer, Web browser...
-	etc.
*/