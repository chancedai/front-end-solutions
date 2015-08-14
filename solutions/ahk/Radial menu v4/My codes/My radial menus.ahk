;=== MY RADIAL MENUS ===
; This file is included in main Radial menu script. You can load or create additional radial menus here.



























/*==Description=========================================================================
You are now inside RMApp_AutoExecute(). If you want to load or create additional radial menus inside RM app, here is the best
place & time to do that. Don't worry about turning RM2module & Gdiplus on & off, RM app takes care about that. Do not use commands
that will stop auto-execute here, just load or create menus you need via RMApp_LoadMenu() or RM2_CreateMenu() and nothing more!
The first free gui number that you can use for your additional radial menu(s) inside RM app is stored in "FirstFreeGui" variable.
"RM" variable is equal to "A_ScriptDir".

Read "Context-sensitive radial menus" heading in RM help file.


Simplest examples:
	Example1:
		;=== Code in My radial menus.ahk ===
		RMApp_LoadMenu(59, RM "\Menu definitions\Submenus\Comp control.txt")  ; loads radial menu from file, uses Gui number 59.
		
		;=== Code in My hotkeys.ahk ===
		F4::RMApp_MyRMHandler2(59) ; Shows specified menu, gets selected item and executes item action if something was selected.
		
	Example2:
		;=== Code in My radial menus.ahk ===
		RM2_CreateMenu(60,"1|2|3|4|5|6")		; creates radial menu defined in "RM2module style", uses Gui number 60.
		
		;=== Code in My hotkeys.ahk ===
		F5::
		SelectedItem := RMApp_MyRMHandler(60)	; returns %A_ThisMenuItem% (or RMApp_MyRMHandler(60,"","","gn") which returns %A_ThisMenuItem%|%A_ThisMenu%)
		if SelectedItem
		MsgBox,,, % SelectedItem ,1				; you have %A_ThisMenuItem% (or %A_ThisMenuItem%|%A_ThisMenu%) information. Specify your action.
		return



Functions in use:
	RMApp_LoadMenu(GuiNum, FileOrString)
		Loads radial menu from file or creates it from menu definition string. Item's submenus can be specified, but will be ignored. Returns "GuiNum".
		
		Example1 - from file
			RMApp_LoadMenu(55, "C:\MenuDefinition.txt")  ; loads radial menu from file, uses Gui number 55.
		
		Example2 - from string
			MenuDefinition =
			(`
			[Item1]
			Icon=		Calculator.png
			Action=		%A_WinDir%\system32\calc.exe
			
			[Item2]
			Text=		Function Demo1
			Action=		fun Demo1
			)
			RMApp_LoadMenu(56, MenuDefinition) ; loads radial menu from variable (string), uses Gui number 56.

	RM2_CreateMenu(GuiNum,ItemAttributes,SpecMenuBack="",SpecMenuFore="",OneRingerAtt="",CentralTextOrImageAtt="")
		Creates radial menu defined in "RM2module style". Returns "GuiNum". For more info see RM2module documentation.
		Example1:
			RM2_CreateMenu(57, "This|is|additional|radial|menu")
		
		Example2:
			RM2_CreateMenu(58, ">" A_ScriptDir "\Icons\Paint.png|Function Demo1")

	RMApp_MyRMHandler(GuiNum, SelectMethod="", key="", options="",ShowPosX="", ShowPosY="")
			Shows specified menu and gets selected item. Does not execute item action.
			For parameters description see RM2_GetSelectedItem() in RM2module documentation.

	RMApp_MyRMHandler2(GuiNum, SelectMethod="", key="", options="",ShowPosX="", ShowPosY="") {
			Shows specified menu, gets selected item and executes item action if something was selected.
			For parameters description see RM2_GetSelectedItem() in RM2module documentation.
*/
