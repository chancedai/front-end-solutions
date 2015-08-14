;===Auto-execute========================================================================
Gui, 1:+AlwaysOnTop
Gui, 1:Add, Button, x5 y10 w100 h30 gExitApp, ExitApp
Gui, 1:Add, Button, x115 y10 w100 h30 gReload, Reload
Gui, 1:Add, Button, x5 y50 w100 h30 gSuspendOff, Suspend off
Gui, 1:Add, Button, x115 y50 w100 h30 gSuspendOn, Suspend on
Gui, 1:Add, Button, x225 y50 w100 h30 gSuspendToggle, Suspend toggle
Gui, 1:Add, Button, x5 y90 w100 h30 gSoundsOff, Sounds off
Gui, 1:Add, Button, x115 y90 w100 h30 gSoundsOn, Sounds on
Gui, 1:Add, Button, x225 y90 w100 h30 gSoundsToggle, Sounds toggle
Gui, 1:Add, Button, x5 y130 w155 h30 gRMShowHotkeyOff, RMShowHotkey off
Gui, 1:Add, Button, x170 y130 w155 h30 gRMShowHotkeyOn, RMShowHotkey on
Gui, 1:Add, Button, x5 y170 w155 h30 gMessageReceiverExecute, MessageReceiver - Execute
Gui, 1:Add, Text, x5 y205 w320 h30, This example script shows how you can control RM with some other script or program by sending windows messages to it.
Gui, 1:Show, w330 h240, RM window messages tester
Return


;===Subroutines=========================================================================
GuiClose:
ExitApp

ExitApp:
PostMessage("Radial menu - message receiver", 1)
return
Reload:
PostMessage("Radial menu - message receiver", 2)
return
SuspendOff:
PostMessage("Radial menu - message receiver", 30)
return
SuspendOn:
PostMessage("Radial menu - message receiver", 31)
return
SuspendToggle:
PostMessage("Radial menu - message receiver", 32)
return
SoundsOff:
PostMessage("Radial menu - message receiver", 40)
return
SoundsOn:
PostMessage("Radial menu - message receiver", 41)
return
SoundsToggle:
PostMessage("Radial menu - message receiver", 42)
return
RMShowHotkeyOff:
PostMessage("Radial menu - message receiver", 50)
return
RMShowHotkeyOn:
PostMessage("Radial menu - message receiver", 51)
return
MessageReceiverExecute:
PostMessage("Radial menu - message receiver", 6)
return


;===Functions===========================================================================
PostMessage(Receiver,Message) {
	oldTMM := A_TitleMatchMode, oldDHW := A_DetectHiddenWindows
	SetTitleMatchMode, 3
	DetectHiddenWindows, on
	PostMessage, 0x1001,%Message%,,,%Receiver% ahk_class AutoHotkeyGUI
	SetTitleMatchMode, %oldTMM%
	DetectHiddenWindows, %oldDHW%
}  


;===Hotkeys=============================================================================
Esc::ExitApp
