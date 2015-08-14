;=== My RMShowHotkey conditions === 
/* This file is included in main Radial menu script. By editing RMApp_RMShowHotkeyConditions() function, you can adjust RMShowHotkey's context-sensitivity.
If RMApp_RMShowHotkeyConditions() function returns string "block", RMShowHotkey will be blocked (disabled), and in all other cases, it will be enabled.
Do not use info from RM registers here. For example, use;
	ActiveWinID := WinExist("A")		; not ActiveWinID := RMApp_Reg("ActiveWinID")
	MouseGetPos,,, WinUMID				; not WinUMID := RMApp_Reg("WinUMID")
*/


RMApp_RMShowHotkeyConditions() {
	
}





/*=== Examples ===

; Example 1 - enable RMShowHotkey in all cases
RMApp_RMShowHotkeyConditions() {
	
}


; Example 2 - block RMShowHotkey if Notepad or Paint are active windows, and enable it in all other cases. ("BlackList" effect)
RMApp_RMShowHotkeyConditions() {
	WinGetClass, ActiveWinClass, % "ahk_id " WinExist("A")
	if ActiveWinClass in Notepad,MSPaintApp
		return "block"	; blocks RMShowHotkey
}


; Example 3 - enable RMShowHotkey only if Notepad or Paint are active windows, and block it in all other cases. ("WhiteList" effect)
RMApp_RMShowHotkeyConditions() {
	WinGetClass, ActiveWinClass, % "ahk_id " WinExist("A")
	if ActiveWinClass not in Notepad,MSPaintApp
		return "block"	; blocks RMShowHotkey
}


; Example 4 - block RMShowHotkey if window under mouse is "Shell_TrayWnd", "Button" or "NotifyIconOverflowWindow" class, and enable it in all other cases.
RMApp_RMShowHotkeyConditions() {
	MouseGetPos,,, hWinUnderMouse	
	WinGetClass, WinUnderMouseClass, % "ahk_id " hWinUnderMouse
	if WinUnderMouseClass in Shell_TrayWnd,Button,NotifyIconOverflowWindow	; (Shell_TrayWnd: Taskbar, Button: Win7 start button, NotifyIconOverflowWindow: Tray icons window)
		return "block"	; blocks RMShowHotkey
}


; Example 5 - block RMShowHotkey if it's between 12 and 14 hours, and enable it in all other cases.
RMApp_RMShowHotkeyConditions() {
	if A_Hour between 12 and 14
		return "block"	; blocks RMShowHotkey
}

*/