;===Description=========================================================================
/*
This file is included in RMApp lib.ahk.
Last update: 15.11.2013.

Navigator is a drop down menu which helps you to easily navigate to folders that you often use.
It navigates to your favorite folders in Windows explorer, My Computer, and in other standard Open, Save, Export, Import, Upload, Select dialog windows.
If Navigator doesn't work as expected in some dialog windows, you can adapt the method how it interacts with window controls here.
*/


;===Function===========================================================================
RMApp_NavControlHandler(FolderPath, hwnd="", FocusedControl="") {
	/*
	RM executes this function after user selects item in Navigator menu, if it is a folder path, drive letter or ShellSpecialFolderConstant.
	All parameters are provided by RM.
	Note that you can't always navigate to all ShellSpecialFolders. For example, you can't navigate to Control panel while you're in standard "Open File" dialog box window, but you can always navigate there while you're in Windows explorer.
	
	"FolderPath" can be folder path, drive letter or ShellSpecialFolderConstant, for example: "C:\Program Files", "C:\", "10"
	"hwnd" is handle to window, for example: "0xa03f0".
	"FocusedControl" is control of the target window which has input focus, if any. Example: "Button2"

	Some functions in use:
	RMApp_IsControlVisible()		returns 1 if control is visible
	RMApp_ControlSetTextR()			same as ControlSetText command, but a little bit more reliable
	RMApp_ControlSetFocusR()		same as ControlSetFocus command, but a little bit more reliable
	RMApp_Explorer_Navigate()		navigates to specified folder in Windows Explorer or MyComputer
	*/
	
	RestoreInitText := 1						; turn on "restore control's initial text after navigating to specified folder" switch
	hwnd := (hwnd="") ? WinExist("A") : hwnd	; if omitted, use active window
	WinGetTitle, WinTitle, ahk_id %hwnd%		; get window's title
	WinGetClass, WinClass, ahk_id %hwnd%			; get window's class
	if (FocusedControl="")
		ControlGetFocus, FocusedControl, ahk_id %hwnd%	; if not specified, get FocusedControl
	
	if FolderPath is integer
		FolderPath := Round(FolderPath)		; for some strange reason, this has to be done although it looks like nonsense, otherwise try RMApp_Explorer_Navigate(FolderPath, hwnd) won't work properly if FolderPath if ShellSpecialFolderConstant

	;=== If window is Windows Explorer or MyComputer ===
	if WinClass in ExploreWClass,CabinetWClass
	{
		try RMApp_Explorer_Navigate(FolderPath, hwnd)
		if (FocusedControl != "" and RMApp_IsControlVisible("ahk_id " hwnd, FocusedControl) = 1)
			RMApp_ControlSetFocusR(FocusedControl, "ahk_id " hwnd)				; focus initialy focused control
		return
	}

	;=== Other cases (not Windows Explorer or MyComputer) - first we'll decide to which control we will send FolderPath ===
	if (WinClass = "#32770") {		;  standard dialog box class
		if RMApp_IsControlVisible("ahk_id " hwnd, "Edit1")
			Control := "Edit1"		; in standard dialog windows, "Edit1" control is the right choice
		Else if RMApp_IsControlVisible("ahk_id " hwnd, "Edit2")
			Control := "Edit2"		; but sometimes if condition above fails, "Edit2" control is the right choice
		Else						; if above fails - just return and do nothing.
			Return
	}
	Else if (InStr(WinClass, "bosa_sdm_") > 0) { ; MS Office dialog boxes on WinXP (bosa_sdm_ classes). Examples: "bosa_sdm_XL9", "bosa_sdm_Microsoft Office Word 12.0"
		; http://ahkscript.org/boards/viewtopic.php?p=4778#p4778
		if RMApp_IsControlVisible("ahk_id " hwnd, "Edit1")
			Control := "Edit1"			; if "Edit1" control exists, it is the right choice.
		Else if RMApp_IsControlVisible("ahk_id " hwnd, "RichEdit20W2")
			Control := "RichEdit20W2"	; some dialogs don't have "Edit1" control, but they have "RichEdit20W2" control, which is then the right choice.
		Else							; if above fails - just return and do nothing.
			Return
	}
	Else if WinTitle contains Open,Save,Export,Import,Upload,Select	; some other not standard dialog windows.
	{
		if RMApp_IsControlVisible("ahk_id " hwnd, "Edit1")
			Control := "Edit1"			; if "Edit1" control exists, it is the right choice.
		Else if RMApp_IsControlVisible("ahk_id " hwnd, "RichEdit20W2")
			Control := "RichEdit20W2"	; some dialogs don't have "Edit1" control, but they have "RichEdit20W2" control, which is then the right choice.
		Else							; if above fails - just return and do nothing.
			Return
	}
	Else {	; in all other cases, we'll explore FolderPath, and return from this function
		ComObjCreate("Shell.Application").Explore(FolderPath)	; http://msdn.microsoft.com/en-us/library/windows/desktop/bb774073%28v=vs.85%29.aspx
		Return
	}

	;=== Refine ShellSpecialFolderConstant ===
	if FolderPath is integer
	{
		if (FolderPath = 17)			; My Computer --> 17 or 0x11
			FolderPath := "::{20d04fe0-3aea-1069-a2d8-08002b30309d}"	; because you can't navigate to "17" but you can navigate to "::{20d04fe0-3aea-1069-a2d8-08002b30309d}"
		else							; don't allow other ShellSpecialFolderConstants. For example - you can't navigate to Control panel while you're in standard "Open File" dialog box window.
			return
	}

	/*
	ShellSpecialFolderConstants:	http://msdn.microsoft.com/en-us/library/windows/desktop/bb774096%28v=vs.85%29.aspx
	CSIDL:							http://msdn.microsoft.com/en-us/library/windows/desktop/bb762494%28v=vs.85%29.aspx
	KNOWNFOLDERID:					http://msdn.microsoft.com/en-us/library/windows/desktop/dd378457%28v=vs.85%29.aspx
	*/

	
	;===In this part (if we reached it), we'll send FolderPath to control and optionaly restore control's initial text after navigating to specified folder===	
	if (RestoreInitText = 1)	; if we want to restore control's initial text after navigating to specified folder
		ControlGetText, InitControlText, %Control%, ahk_id %hwnd%	; we'll get and store control's initial text first
	
	RMApp_ControlSetTextR(Control, FolderPath, "ahk_id " hwnd)	; set control's text to FolderPath
	RMApp_ControlSetFocusR(Control, "ahk_id " hwnd)				; focus control
	if (WinExist("A") != hwnd)			; in case that some window just popped out, and initialy active window lost focus
		WinActivate, ahk_id %hwnd%		; we'll activate initialy active window
	
	;=== Avoid accidental hotkey & hotstring triggereing while doing SendInput - can be done simply by #UseHook, but do it if user doesn't have #UseHook in the script ===
	If (A_IsSuspended = 1)
		WasSuspended := 1
	if (WasSuspended != 1)
		Suspend, On
	SendInput, {End}{Space}{Backspace}		; silly but necessary part - go to end of control, send dummy space, delete it, and then send enter
	Sleep, 50								; having a little sleep before sending {Enter} improves reliability
	SendInput, {enter}
	if (WasSuspended != 1)
		Suspend, Off

	/*
	Question: Why not use ControlSetText, and then send enter to control via ControlSend, %Control%, {enter}, ahk_id %hwnd% ?
	Because in some "Save as"  dialogs in some programs, this causes auto saving file instead of navigating to specified folder! After a lot of testing, I concluded that most reliable method, which works and prevents this, is the one that looks weird & silly; after setting text via ControlSetText, control must be focused, then some dummy text must be sent to it via SendInput (in this case space, and then backspace which deletes it), and then enter, which causes navigation to specified folder.
	Question: Ok, but is "SendInput, {End}{Space}{Backspace}{enter}" really necessary? Isn't "SendInput, {enter}" sufficient?
	No. Sending "{End}{Space}{Backspace}{enter}" is definitely more reliable then just "{enter}". Sounds silly but tests showed that it's true.
	*/
	
	if (RestoreInitText = 1) {	; if we want to restore control's initial text after we navigated to specified folder
		Sleep, 70				; give some time to control after sending {enter} to it
		ControlGetText, ControlTextAfterNavigation, %Control%, ahk_id %hwnd%	; sometimes controls automatically restore their initial text
		if (ControlTextAfterNavigation != InitControlText)						; if not
			RMApp_ControlSetTextR(Control, InitControlText, "ahk_id " hwnd)		; we'll set control's text to its initial text
	}
	if (WinExist("A") != hwnd)	; sometimes initialy active window loses focus, so we'll activate it again
		WinActivate, ahk_id %hwnd%
	
	if (FocusedControl != "" and RMApp_IsControlVisible("ahk_id " hwnd, FocusedControl) = 1)
		RMApp_ControlSetFocusR(FocusedControl, "ahk_id " hwnd)				; focus initialy focused control
	
	
	/*
	;==Old method which looks more proper, but is definitely less reliable==
	if RestoreInitText
		ControlGetText, InitControlText, %Control%, ahk_id %hwnd%
	RMApp_ControlSetTextR(Control, FolderPath, "ahk_id " hwnd)
	Sleep, 60
	ControlSend, %Control%, {enter}, ahk_id %hwnd%
	Sleep, 60
	if RestoreInitText
		RMApp_ControlSetTextR(Control, InitControlText, "ahk_id " hwnd)
	if (WinExist("A") != hwnd)
		WinActivate, ahk_id %hwnd%
	*/
}

