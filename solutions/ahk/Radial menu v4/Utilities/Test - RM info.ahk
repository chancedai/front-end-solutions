

; This example script shows how you can get info about currently running RM via another stand-alone script or program.


Info := GetRMInfo()	; gets info about currently running RM and stores it in Info object
if !IsObject(Info) {	; if RM doesn't exist, GetRMInfo() will return blank value (it will not return object).
	MsgBox, RM doesn't exist
	ExitApp
}

;MsgBox % Info.RMPID			; How to get specific info example

;=== How to display all availble info example ===
For k,v in Info
	Text .= k ":" A_Tab v "`n"
Gui 1:Add, Edit, x5 x5 w700 h200 t40 t80 +ReadOnly, % RTrim(Text, "`n")
Gui 1:Show, w710 h210, Info about currently running RM
return

GuiClose:
ExitApp



;===Function============================================================================
GetRMInfo() { ; gets info about currently running RM and returns it as object (associative array)
	WinTitle := "Radial menu - message receiver ahk_class AutoHotkeyGUI", oldTMM := A_TitleMatchMode, oldDHW := A_DetectHiddenWindows
	SetTitleMatchMode, 3
	DetectHiddenWindows, on
	if (WinExist(WinTitle) = 0) {	; if RM doesn't exist, there's nothing to do...
		SetTitleMatchMode, %oldTMM%
		DetectHiddenWindows, %oldDHW%
		return
	}
	ControlGetText, ControlText, Edit1, % WinTitle	; get text from "RM info field" in RM's hidden message receiver window
	Out := {}	; create Out object (associative array)
	Loop, parse, ControlText, `n, `r	; parse, find first ":" sign, and assign key = value in Out object
	{
		Line := Trim(A_LoopField), pos := InStr(Line, ":")
		if (pos > 1)	;  0 is not found + key must have at least one letter
			key := Trim(SubStr(Line, 1, pos-1)), Value := Trim(SubStr(Line, pos+1)), Out.Insert(key,value)
	}
	SetTitleMatchMode, %oldTMM%
	DetectHiddenWindows, %oldDHW%
	return Out
}
