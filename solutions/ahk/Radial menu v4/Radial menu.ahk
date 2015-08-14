/*==Description=========================================================================
Radial menu application is encapsulated, so you can put your code at appropriate places and make your perfect portable master script.
Hotkeys, hotstrings, timers, GUI-s, additional menus... anything you need. The code is clean - there are no global variables.
*/


;===Auto-execute========================================================================
RMApp_AutoExecute()
; you can put or include your auto-execute code here 
Return


;===Hotkeys=============================================================================
#Include *i %A_ScriptDir%\My Codes\My hotkeys.ahk		; you can put your hotkeys here


;===Hotstrings==========================================================================
#Include *i %A_ScriptDir%\My Codes\My hotstrings.ahk	; you can put your hotstrings here


;===Subroutines=========================================================================
#Include %A_ScriptDir%\Internal\Codes\RMApp sub.ahk		; reserved prefix: RMApp_
; you can put or include your subroutines here 

RMApp_OnExit:	; on exit subroutine
RMApp_OnExit()
; you can put or include your OnExit code here 
ExitApp


;===Functions===========================================================================
#Include %A_ScriptDir%\Internal\Codes\Gdip_All.ahk			; reserved prefix: Gdip_
#Include %A_ScriptDir%\Internal\Codes\RM2module.ahk			; reserved prefix: RM2_
#Include %A_ScriptDir%\Internal\Codes\RMApp lib.ahk			; reserved prefix: RMApp_
#Include *i %A_ScriptDir%\My Codes\NCHITTEST.ahk			; reserved prefix: NCHT_
#Include *i %A_ScriptDir%\My Codes\My mouse gestures.ahk	; reserved prefix: MG_
#Include *i %A_ScriptDir%\My Codes\My functions.ahk
; you can put or include your functions here 
