;===Description=========================================================================
/*
Radial menu designer (RMD)
Author:		Boris Mudrinić (Learning one on AHK forum)
Contact:	boris.mudrinic@gmail.com
Thanks:		Chris Mallett, Lexikos, Tic (Tariq Porter), Majkinetor (Miodrag Milić), Rseding91, Fincs and others...
Link: 		www.autohotkey.com/community/viewtopic.php?f=2&t=50813
Video: 		www.screenr.com/THMs

Components by other authors:
- Gdip_All library.	Credits: Tic (Tariq Porter), Rseding91, fincs. Link: http://www.autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/page-72#entry533310
- Attach() - Copyright (c) Majkinetor. All rights reserved. Licensed under BSD. Link: http://www.autohotkey.com/forum/topic53317.html
- ScreenToClient() and ClientToScreen() by Lexikos. Link: http://www.autohotkey.com/forum/post-170559.html#170559

Interpreted by AutoHotkey_L unicode
- Authors: Chris Mallett and Lexikos, with portions by AutoIt Team and various AHK community members
- License: GNU General public license
- Info and source code at: www.autohotkey.net/~Lexikos/AutoHotkey_L

Made for RM2module (and higher) applications, including Radial menu v4 application (RM4).
- Info at: www.autohotkey.com/community/viewtopic.php?f=2&t=50813

LICENSE:
As the author of Radial menu designer (RMD), I'm reserving all my rights except the following: If you agree on all terms in this license, you may: 1) non-commercially use RMD to create/edit radial menus used with Radial menu v4 application, 2) make RMD part of or use it with your non-commercial application, 3) upload any part of RMD written by me on English AutoHotkey forum or www.autohotkey.net. If you'll do 2), you must inform me about that, and provide appropriate credits in documentation, source code, and About MsgBox, as described below. If you'll do 3), you'll have to note that it's my code, like "by Learning one - www.autohotkey.com/community/viewtopic.php?f=2&t=50813", unless if that is obvious even to reader who doesn't now anything about RMD and my other radial menu works. If you modified my original code you uploaded, you have to note that too. I'm not responsible for any damages arising from the use of RMD. Without my written permission, RMD can not (neither optionally) be used by or made part of any commercial application/script, or used to create/edit (neither optionally) any file that is used/connected with it, and nobody is allowed to have any profit from it. If you notice any sort of license or copyright violation by any person, you agree that you will report that to me immediately and that you will testify on court in case of litigation. On issues not regulated with this license Croatian laws apply. In case of litigation, Croatian laws and language apply and court in Zagreb (Croatia) has jurisdiction. Appropriate credits text in case 2): "Thanks to Boris Mudrinić (Learning one on AHK forum), for his Radial menu designer (RMD). Contact: boris.mudrinic@gmail.com. More info and license at: www.autohotkey.com/community/viewtopic.php?f=2&t=50813. Also thanks to Chris Mallett, Lexikos, Tic (Tariq Porter), Majkinetor (Miodrag Milić), Rseding91, Fincs and others, whose work is used to run RMD."

Some rules to remember:
- item must have text or icon to exist in menu
- menu must have at least 1 item to be capable for saving and to exist as file
- icons must be in .png format and located in IconsFolder (sub-folders are allowed) 
- although RMD can theoretically display unlimited number of rings, RM2module supports up to 4 rings.

Extracting icons from .exe files.
If file you dragged on menu or clipboard has .exe extension, its icon will be extracted to Icons folder, and displayed in menu. But for some .exe files, this doesn't work properly - empty icon is extracted and displayed. Improving this is out of my skills, but maybe Tic (GDI+ library author) or somebody else could improve Gdip_CreateBitmapFromFile() function which is responsible for this.

Click on Save button.
If you click on Save button and nothing happens, that means that last saved state is equal to current state, so there is nothing to save.

Notes for developers:
RMD is made to be used with any application based on RM2module that stores radial menu definition files in RM4 style, not just for RM4. If you want to make it part of your application, you'll have to specify IconsFolder and MenuVariables (if any) when creating RMD application object (+ obligations from license). It's also (hopefully) made to be compatible with 3. generation of RM module - RM3module and contains some components that will be used by RM3module. Some features are still not completely developed and implemented and documentation is not finished yet.

Which component does what?
- Radial menu designer (RMD) is used to CREATE AND EDIT radial menus (and some other files too).
- RM2module is used to RUN radial menus.
*/



;===Auto-execute========================================================================
#SingleInstance, ignore
OnExit, ExitSub		; Obligatory

;=== RM4 specific ===
RM := GetHigherDir(2)	; get folder in which RM4 app is located
if FileExist(RM "\Internal\RM icon.ico")
Menu, Tray, Icon, %RM%\Internal\RM icon.ico	; set RM4 logo icon to main window
#NoTrayIcon

;=== Create GuiMenu ===
GuiMenuDefinition=			; feel free to add your custom GuiMenu items... (Profiles, Submenus and Context-sensitive are RM4 specific "shortcuts" - not obligatory)
(
File
	New
	Open...
	Save
	Save as...
	Delete...
View
	Toggle
	Graphics
	Text
Other
	Notes
	Deleted items
	AlwaysOnTop toggle
	--------
	About
	Watch tutorial video
	Visit RMD home page
Profiles
Submenus
Context-sensitive
)
CreateDDMenu(GuiMenuDefinition,"GuiMenu","GuiMenuHandler")	; create drop down menu from GuiMenuDefinition
Gui 1:Menu, GuiMenu	; assign it to main window


;=== Prepare obligatory parameters in RM4 === 	(may not be obligatory in other apps based on RM2module - depends on how app is constructed)
MenuOptions := {IconsFolder: RM "\Icons"}	; tell in which folder icons are located
MenuVariables := {"RM\": RM "\"}			; tell that "RM\" string in menu definitions represents folder in which RM4 app is located. Format - Var: value 

;=== Prepare optional parameters ===
Miscellaneous := {RootDir: RM "\Menu definitions"}	; tell default RootDir for Open, Save as, and Save dialogs
;Layout := {ItemSize:55, ItemLayout: "10_15_20_25_30", RadiusSizeFactor: "1"}		; example how to override some defaults - very rarely used
;GuiOptions := {BorderW: 1, GuiFontSize: 8, InfoBarH: 20, GuiColor: "fafae5"}		; example how to override some defaults - very rarely used
;ItemBitmapOptions := {TextSize: 9, TextColor: "777700"}							; example how to override some defaults - very rarely used

;=== Pass parmeters (associative arrays) and create RMD application object, open file, show main window ===
App := new c_App(MenuOptions, MenuVariables, Miscellaneous, Layout, GuiOptions, ItemBitmapOptions)	; create application object (RMD)
App.Open(RM "\Menu definitions\" GetCurrent(RM).Profile ".txt")	; open file (current RM4 profile in this case)

;App.Events.AfterDropFileOnBoard := Func("AfterDropFileOnBoard") ; example how to monitor AfterDropFileOnBoard event through user's AfterDropFileOnBoard function. (You can choose another name function name)
App.GuiShow()	; show main window
return


;=== Event functions - optional ===	; you must register event monitoring by calling App.Events.AfterDropFileOnBoard := Func("AfterDropFileOnBoard")
AfterDropFileOnBoard(oMenu, ItemNum, Type) {
/*
This event occurs after user drops file or folder on a empty slot in currently displayed menu or clipboard, while he is in "Graphics" view mode.

Parameters:
oMenu		is a pointer to currently displayed menu or clipboard on wich user dropped a file or folder
ItemNum		is a item number on wich user dropped a file or folder. Examples: 2, 32, 9
Type		says did user dropped a file or folder on a currently displayed menu or clipboard. Examples: Menu, Clipboard
*/

	MsgBox, 4, AfterDropFileOnBoard event demo, % "You dropped a file on " Type "'s " ItemNum ". item.`n`n It's current item Action is:`n" oMenu["Item" ItemNum].Action ".`n`nDo you want to change item Action to fun Demo1?"
	
	IfMsgBox, Yes
		oMenu["Item" ItemNum].Action := "fun Demo1"	; changes dropped and newly created item's action to "fun Demo1"

}



;===Hotkeys=============================================================================
; feel free to add your custom hotkeys

#If (App.IsMainWinActive())		; Optional hotkeys
^n::App.New()
^o::App.SelectFileToOpen()
^s::App.Save()

#If (App.SetFontSizeConditions())	; Optional hotkeys
^WheelUp::App.EditSetFontSize(1)
^WheelDown::App.EditSetFontSize(-1)

#If (App.IsEditFocused())	; Optional hotkeys
Tab::SendInput, ^{Tab}
+Enter::SendInput, ``n

#If (App.LButtonConditions())	; Obligatory hotkey. Do not modify.
*LButton::App.OnLButton()
#If

/* ; Changing RMD's item layout is not 100% compatible with RM2module, so don't use it yet. It's is mainly reserved for RM3module. Just for demo here.
F6::App.SetLayout("9")				; one ringer with 9 items
F7::App.SetLayout("15")				; one ringer with 15 items
F8::App.SetLayout("8_14_20")		; multi ringer
F9::App.SetLayout("6_12_18_24")		; multi ringer
F10::App.DevGui.See(App)			; see structure while developing
*/


;===Subroutines=========================================================================
; feel free to add your custom subroutines...

#Include %A_ScriptDir%\RMD subroutines.ahk	; by Learning one

GuiMenuHandler:			; if you added your custom GuiMenu items, feel free to specify their actions... 
Gui, 1:+OwnDialogs 
if (A_ThisMenu = "File")
{
	if (A_ThisMenuItem = "New")
		App.New()
	else if (A_ThisMenuItem = "Open...")
		App.SelectFileToOpen()
	else if (A_ThisMenuItem = "Save")
		App.Save()
	else if (A_ThisMenuItem = "Save as...")
		App.SaveAs()
	else if (A_ThisMenuItem = "Delete...")
		App.Delete()
}
else if (A_ThisMenu = "View")
{
	if (A_ThisMenuItem = "Toggle")
		App.SetView()
	else if (A_ThisMenuItem = "Graphics")
		App.SetView("g")
	else if (A_ThisMenuItem = "Text")
		App.SetView("t")
}
else if (A_ThisMenu = "Other")
{
	if (A_ThisMenuItem = "Notes")
		App.ShowNotes()
	else if (A_ThisMenuItem = "Deleted items")
		App.ShowDeletedItems()
	else if (A_ThisMenuItem = "AlwaysOnTop toggle")
		App.AlwaysOnTop()
	else if (A_ThisMenuItem = "About")
		App.ShowAbout()
	else if (A_ThisMenuItem = "Watch tutorial video")
		App.WatchTutorialVideo()
	else if (A_ThisMenuItem = "Visit RMD home page")
		App.VisitRMDHomePage()
}
else if (A_ThisMenu = "GuiMenu")	; items in GuiMenu that don't have their submenus
{
	if (A_ThisMenuItem = "Profiles")
		App.SelectFileToOpen(App.Misc.RootDir)
	else if (A_ThisMenuItem = "Submenus")
		App.SelectFileToOpen(App.Misc.RootDir "\Submenus")
	else if (A_ThisMenuItem = "Context-sensitive")
		App.SelectFileToOpen(App.Misc.RootDir "\Context-sensitive")		
}
return

ExitSub:
result := App.OnExit()	; Obligatory.  Do not modify.
if (result = "Cancel")
	return
; feel free to add your custom on exit code...
ExitApp



;===Functions===========================================================================
; feel free to add your custom functions...

#Include %A_ScriptDir%\Gdip_All.ahk			; credits: Tic, Rseding91, fincs. http://www.autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/page-72#entry533310
#Include %A_ScriptDir%\RMD functions.ahk	; by Learning one except: 1) Attach() by Majkinetor and 2) ScreenToClient(), ClientToScreen() by Lexikos



;===Classes=============================================================================
; feel free to add your custom classes...

#Include %A_ScriptDir%\RMD classes.ahk		; by Learning one 
