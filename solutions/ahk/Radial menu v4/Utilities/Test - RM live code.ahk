/*==Description=========================================================================

RM live code.

This example script shows how another process can interact with RM process without using WM_COPYDATA, or ClipBoard, FileMapping, COM, Mailslots, Pipes, Sockets, or similar.
It's all done via window controls in RM's hidden "Radial menu - message receiver" window. To see how does it look and work, hold down Shift key and select
Versions info item from Menu control submenu, or call RMApp_ShowMessageReceiverGui() function.

It's not powerful as COM or similar IPC mechanisms, but can do useful things.
One of "attractive" things is that you can create radial menus in RM process, and call them from another process.
Or code some function in ahk, put it in RM, and call it from another program, etc.

Remember you can send window messages to RM (which can be numbers), but with RM live code, you can work with strings and do much more.

RM live code allows you to execute (call) any valid item action from RM process like;
- function from RM code like: "fun MyFunc"
- subroutine from RM code like: "sub MySub"
- ordinary run command like: "C:\My script.ahk"
- etc.

If you want to communicate with RM with:
- another ahk script, just put RMLiveCode() function in your script and you are ready to go
- another program written in some other programming language, you'll have to study how RMLiveCode() works and code something similar in your program.

Examples:
RMLiveCode("fun Demo1")							will execute Demo1 function from RM's code
RMLiveCode("fun Demo2|a|b|c")					will execute Demo2 function from RM's code and pass 3 parameters to it
RMLiveCode("RM\Help.htm")						will open RM\Help
RMLiveCode("fun RMApp_MyRMHandler2|11|c")		will call radial menu number 11 and use "click to select" method
MsgBox % RMLiveCode("fun Gdip_LibraryVersion")	will call Gdip_LibraryVersion function from RM's code and return result
*/

#NoEnv

;===Hotkeys for testing and learning==================================================
F1::RMLiveCode("fun Demo1")
F2::RMLiveCode("fun Demo2|a|b|%A_WinDir%")
F3::RMLiveCode("RM\Help.htm")
F4::RMLiveCode("fun RMApp_MyRMHandler2|11|c")				; click to select
F5::RMLiveCode("fun RMApp_MyRMHandler2|12|r|" A_ThisHotkey)	; release to select
F6::RMLiveCode("fun RMApp_ShowMessageReceiverGui")			; call this to see how does "Radial menu - message receiver" look and work
F7::MsgBox % RMLiveCode("fun RMApp_Reg|RMinfo")				; make a call and see return value in MsgBox



;=== Compare: [SLOW: multiple calls one by one] vs [FAST: multiple calls at once] === 	; press F6 to see how it works - what's happening in "Radial menu - message receiver" window
F8::	; this makes 8 calls one by one - SLOW performance. Return value is string.
a := RMLiveCode("fun Gdip_LibraryVersion")
b := RMLiveCode("fun RMApp_Version")
c := RMLiveCode("fun RMApp_Reg|CurrentProfile")
d := RMLiveCode("fun RMApp_Reg|RMShowHotkey")
e := RMLiveCode("fun RMApp_Reg|RMSelectMethod")
f := RMLiveCode("fun RMApp_Reg|RMShowMethod")
g := RMLiveCode("fun RMApp_Reg|RSMShowHotkey")
h := RMLiveCode("fun RMApp_Reg|Sounds")
MsgBox % a "`n" b "`n" c "`n" d "`n" e "`n" f "`n" g "`n" h
return

F9::	; this makes 8 calls at once - FAST performance. Return value is object (simple array), not string!
Result := RMLiveCode("fun Gdip_LibraryVersion"
					, "fun RMApp_Version"
					, "fun RMApp_Reg|CurrentProfile"
					, "fun RMApp_Reg|RMShowHotkey"
					, "fun RMApp_Reg|RMSelectMethod"
					, "fun RMApp_Reg|RMShowMethod"
					, "fun RMApp_Reg|RSMShowHotkey"
					, "fun RMApp_Reg|Sounds")
MsgBox % Result.1 "`n" Result.2 "`n" Result.3 "`n" Result.4 "`n" Result.5 "`n" Result.6 "`n" Result.7 "`n" Result.8
return




;=== Advanced example ===
; This F10 hotkey demonstrates how another process (in this case this stand-alone ahk script) can give command to a running RM process to create new radial menu on the fly and show it after it was created. If someone needs to frequently create menus on the fly, than it's highly recommended to leave RM2module turned on in RM process! Result will be faster menu creation because bitmaps would allready be created and in memory.
F10::
if (IsMenuCreated = 1) {	; if menu is alredy created via this script, just call it (don't recreate it)
	RMLiveCode("fun RMApp_MyRMHandler2|" ThisMenuGuiNum "|c")	; call menu and use click to select method
	return
}

MenuDefinition=
(
[Item1]
Icon=       Paint.png
Action=     %A_WinDir%\system32\mspaint.exe

[Item2]
Text=       Demo1
Action=     fun Demo1

[Item3]
Text=       Demo2
Action=     fun Demo2|RM live code:|- this menu was created at %A_Hour%:%A_Min%|- by command from %A_ScriptName%

[General]
OneRingerAtt=     1
CentralText=      RM live code
)

ThisMenuGuiNum := 77									; choose number for this new radial menu. It can also be a name (named GUIs) like: "OnTheFly"
res := RMLiveCode("fun RM2_Reg|SkinDir"					; make a multi call and get required info
				, "fun RM2_Reg|SkinOverride"
				, "fun RM2_Reg|ItemGlowGuiNum"
				, "fun RMApp_Reg|FuncParamDelimiter")
SkinDir := res.1
SkinOverride := res.2
ItemGlowGuiNum := res.3
FuncParamDelimiter := res.4		; defualt delimiter is "|" but we'll have to change it temporary because MenuDefinition contains "|"

RMLiveCode("fun RM2_On|" SkinDir "|" SkinOverride "|" ItemGlowGuiNum	; turn on RM2module
		, "fun RMApp_Reg|FuncParamDelimiter|‡"							; set "‡" as new temporary delimiter
		, "fun RMApp_LoadMenu‡" ThisMenuGuiNum "‡" MenuDefinition		; load menu from MenuDefinition
		, "fun RMApp_Reg‡FuncParamDelimiter‡" FuncParamDelimiter		; restore old delimiter
		, "fun RM2_Off"													; turn off RM2module
		, "fun RMApp_MyRMHandler2|" ThisMenuGuiNum "|c")				; call menu and use click to select method

IsMenuCreated := 1														; remember that menu is now created
return

F11::
if (IsMenuCreated = 1)		; menu is alredy created via this script (by F10 hotkey), so just call it (not recreate)
	RMLiveCode("fun RMApp_MyRMHandler2|" ThisMenuGuiNum "|r|" A_ThisHotkey)	; call menu but use release to select method
return

Esc::ExitApp



;===Function============================================================================
RMLiveCode(YourCall*) {		; executes any valid item action from Radial menu process - function, subroutine, run command, etc.
	/*
	===General===
	RMLiveCode IPC is done via window controls in RM's hidden message receiver window. Its title is "Radial menu - message receiver" and its window class is "AutoHotkeyGUI"
	The concept is: 1) write what you want to call, 2) send "Execute" window message or click "Execute" button, 3) and when call is processed, you can get return value.
	"Radial menu - message receiver" is supposed to be hidden and work in background, but you can call "fun RMApp_ShowMessageReceiverGui" to see how does it look and work.
	
	====YourCall===
	YourCall can consist of;
	- just one call (parameter) like:		ReturnValue := RMLiveCode("fun Gdip_LibraryVersion")							; return value type: STRING
	- multiple calls (parameters) like: 	ReturnValue := RMLiveCode("fun Gdip_LibraryVersion", "fun RMApp_Version")		; return value type: OBJECT (simple array)
	Number of multiple calls is unlimited (variadic function).

	=== Forbidden character ===
	"¤" is forbidden character, which you must not use in YourCall. It's RM's internal constant which delimits multiple calls.

	===Important controls inside RM's hidden message receiver window===
	Edit1		"RM info field" - contains info about currently running RM, like AhkVersion, RMPID, RMFolder, etc.
	Edit2 		"Call field" - a place where you have to write your call (command), which can be any valid item action
	Edit3		"Return field" - a place where return value of user's call will be written. Can also be used as a place where you can put additional parameters for your call.
	Button1		"Execute button" - executes user's call from Edit2 and displays return value in Edit3
	The classnames and instance numbers of those controls do not change - they are always the same in all Radial menu v4 applications, so you can be sure that
	"Edit1" will always represent "RM info field", "Edit2"  will always represent "Call field", etc.

	===About Button1 text===
	Button1 text says about "ready state" of RM's message receiver window;
	- when ready for making a call, its text is "Execute" and is in "Enabled" state
	- when call is in progress, its text is "Working..." and is in "Disabled" state
	*/
	
	static RMLiveCodeSeparator := "¤"	; RM's internal constant which delimits multiple calls. It's forbidden to use in YourCall, but this function doesn't check it

	WinTitle := "Radial menu - message receiver ahk_class AutoHotkeyGUI", oldTMM := A_TitleMatchMode, oldDHW := A_DetectHiddenWindows
	SetTitleMatchMode, 3
	DetectHiddenWindows, on

	if (WinExist(WinTitle) = 0) {	; if RM doesn't exist, there's nothing to do...
		SetTitleMatchMode, %oldTMM%
		DetectHiddenWindows, %oldDHW%
		return
	}

	TotalParams := YourCall.MaxIndex()
	if (TotalParams="")		; no call - there's nothing to do 
		return
	if (TotalParams=1)		; just one call
		Call := YourCall.1
	else {					; mulitple calls - pack them
		For k,v in YourCall
			Call .= RMLiveCodeSeparator v					; pack all calls into one and delimit them with RMLiveCodeSeparator
		Call := SubStr(Call, StrLen(RMLiveCodeSeparator)+1)	; delete first separator
	}
		
	Loop {	; wait until "Working..." state finishes - if previous call is still in progress...
		ControlGetText, ButtonText, Button1, % WinTitle
		if (ButtonText != "Working...")
			break
		Sleep, 50
	}
	
	ControlSetText, Edit2, % Call, % WinTitle	; set Call (command) to "Call field" in RM's message receiver window. It's equal as if user mannualy wrote it. 
	Sleep, 50
	PostMessage, 0x1001, 6,,, % WinTitle		; send "MessageReceiver - Execute" window message to RM. It's equal as if user clicked on "Execute" button.
	Sleep, 50
	
	Loop {	; wait until "Working..." state finishes, until call is processed...
		ControlGetText, ButtonText, Button1, % WinTitle
		if (ButtonText != "Working...")
			break 
		Sleep, 50
	}
	
	ControlGetText, ReturnValue, Edit3, % WinTitle	; now we can take return value from "Return field" in RM's message receiver window. Note than only functions can return some value.
	SetTitleMatchMode, %oldTMM%
	DetectHiddenWindows, %oldDHW%
	
	if (TotalParams=1)		; there was just one call - return result as STRING
		ToReturn := ReturnValue
	else {					; there were mulitple calls - unpack results and return them as OBJECT (simple array)
		ToReturn := []
		; Note: do not use Loop, parse, ReturnValue, % RMLiveCodeSeparator
		StringSplit, rv, ReturnValue, % RMLiveCodeSeparator		; unpack - ReturnValue consist of mulitple return values packed into one string which are delimited with RMLiveCodeSeparator
		Loop % TotalParams		; insert each return value into ToReturn object which will have the same number of keys as number of parameters passed to RMLiveCode() function
			ToReturn.Insert(rv%A_Index%)
	}
	return ToReturn	; return result to user
}