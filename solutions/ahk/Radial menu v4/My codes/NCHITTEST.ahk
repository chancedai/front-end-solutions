;=== NCHITTEST ===
; This file is included in main Radial menu script. You can create NCHITTEST result sensitive actions here.



NCHT_MAXBUTTON() {		; this means; if you click on window's MAXBUTTON with RMShowHotkey, then RM will execute this function.
   WinUMID := RMApp_Reg("WinUMID")  ; get unique ID number of window under the mouse cursor.
   NCHTH_AlwaysOnTopToggle(WinUMID)	; AlwaysOnTopToggle is defined below, in Helper functions. "NCHTH_" means "NCHT helper"
}

NCHT_CAPTION() {		
   WinUMID := RMApp_Reg("WinUMID"), RMShowHotkey := RMApp_Reg("RMShowHotkey")
   NCHTH_SetWinTransparency(WinUMID, RMShowHotkey)	; WinTransControl is defined below, in Helper functions.
}

/*
; Some examples:
NCHT_MINBUTTON() {
   MsgBox, You clicked on MINBUTTON.`nIf you want, define your own action here...
}

NCHT_CLOSE() {
   MsgBox, You clicked on CLOSE.`nIf you want, define your own action here...
}
*/




;===Helper functions===================================================================================
NCHTH_AlwaysOnTopToggle(WinID)
{
   WinGet, ExStyle, ExStyle, ahk_id %WinID%
   if (ExStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST - the window is always-on-top
   {
      Winset, AlwaysOnTop, off, ahk_id %WinID%
      WinSet, Bottom,, ahk_id %WinID%   ; Sends a window beneath all other windows. If you don't like this line, comment it.
      Sleep, 50
      MouseGetPos,,,WinUMID
      WinActivate, ahk_id %WinUMID%
      Return
   }
   WinActivate, ahk_id %WinID%
   Winset, AlwaysOnTop, on, ahk_id %WinID%
}

NCHTH_SetWinTransparency(WinID, Hotkey)
{
   CoordMode, mouse, screen
   WinGet, WinTrans, Transparent, ahk_id %WinID%
   if WinTrans =
   WinTrans = 255
   MouseGetPos, x1
   Loop
   {
      Sleep, 20
      MouseGetPos, x2
      if x1 = %x2%
	  {
		if !(GetKeyState(Hotkey, "p"))
		{
			SendInput, {%Hotkey%}
			Return
		}
		Continue
	  }
      Slider := (x1-x2)*5       ; speed factor 5
      CurWinTrans := WinTrans-Slider
      if !(CurWinTrans<15)      ; security - not under 15
      WinSet, trans, %CurWinTrans%, ahk_id %WinID% 
      if !(GetKeyState(Hotkey, "p"))
      Break
   }
}   


/*===Description========================================================================================
NCHITTEST determines what part of the window is under mouse cursor. NCHITTEST() is Sean's function. Thank you Sean!
You can execute some extra actions when you click on some part of window with RMShowHotkey instead of showing RM's main menu or executing mouse gesture. 
However, this will not work on some not standard windows.

This file is tabula rasa, and it's up to you to write your commands in it if you want. There are just two built in features:
1. clicking on window's MAXBUTTON will toggle always on top state of that window
2. click & horizontal drag over window's CAPTION will change window's transparency. Drag left increases and drag right decreases transparency.

If you don't want to use this feature, simply delete all NCHITTEST functions; when they don't exist, there is nothing to execute. 

Function syntax := "NCHT_" <part of window>
Examples:
- NCHT_CAPTION() ; this means; if you clicked on window's CAPTION with RMShowHotkey, then RM will execute this function.
- NCHT_MINBUTTON() ; this means; if you clicked on window's MINBUTTON with RMShowHotkey, then RM will execute this function.

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
