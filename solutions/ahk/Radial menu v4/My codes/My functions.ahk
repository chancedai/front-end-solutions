;=== MY FUNCTIONS === 
; This file is included in main Radial menu script. You can put your functions here.



Demo1() {		; example
	MsgBox, 64, RM - executing function example, Hello! I'm function Demo1.`n`nI'm executed because you:`n1. specified "fun Demo1" as selected item's action and`n2. created Demo1().
}

Demo2(a="",b="",c="",d="",e="") {	; example
	MsgBox, 64, RM - executing function example, Hello! I'm function Demo2.`nI accepted the following parameters:`n%a%`n%b%`n%c%`n%d%`n%e%
}

/* ; another example
RAS(FullPath) {	; Run something and suspend RM
	IfNotExist, %FullPath%
	return
	RMApp_Suspend(1)
	SplitPath, FullPath, file, dir
	Run, %file%, %dir%
}
*/







/*===Description======================================================================================
To execute specific function when you select RM item you must:
1.	specify name of that function (+ "fun" prefix) as item's action. Example: Action = fun Demo1
2.	create that function here, or in Radial menu.ahk, or any other included file.
If you want to perform some more complicated actions, create stand-alone script and launch it by selecting RM item.

You can pass parameters to custom functions. Example: Action = fun Demo2|param1|param2|param3 calls: MF_Demo2("param1", "param2", "param3")
It's good to know that with Radial menu, you can control any other script and most of other programs via custom
functions or mouse gestures. Study OnMessage(), PostMessage, Send, etc. 

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