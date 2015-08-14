;===Settings============================================================================
RMVersion := 4.41
ThanksTo := "Chris Mallett, Lexikos, Tic (Tariq Porter), Majkinetor (Miodrag Milić), HotKeyIt, Rseding91, Fincs, Jackeiku, TomXIII, Sean, TheGood, Bentschi, Elesar, None, Me Lance, Patchen, SpeedY, Preston, and others..." 



;===Auto-execute========================================================================
#SingleInstance, ignore
RM := GetHigherDir(2)

InternalFullPath := RM "\Internal\Internal.txt"
LicenseFullPath := RM "\Legal\Radial menu license.txt"
IconFullPath := RM "\Internal\RM icon.ico"
RM4LogoBarPath := RM "\Internal\RM4 logo bar.jpg"
Author := "Boris Mudrinić (Learning one on AutoHotkey forum)"
Contact := "boris.mudrinic@gmail.com"
ShortDescription := "Radial menu is a new method of giving commands to computers. It's a powerful hotkey, launcher, mouse gestures system, and much more. Packed in ergonomic interface, driven by AutoHotkey, highly adjustable and extendible, can do almost anything you wish."


if FileExist(RM "\Internal\RM icon.ico")
	Menu, Tray, Icon, % IconFullPath
Menu, Tray, Tip, Welcome to Radial menu v%RMVersion%

if (GetPathType(InternalFullPath) != "file") {
	MsgBox, 16, Radial menu v%RMVersion%, Can't read Internal.txt.
	ExitApp
}
if (GetPathType(LicenseFullPath) != "file") {
	MsgBox, 16, Radial menu v%RMVersion%, Can't read Radial menu license.txt.
	ExitApp
}

FileRead, InternalTxt, % InternalFullPath
Loop, parse, InternalTxt, `n, `r
{
	Field := Trim(A_LoopField)
	if (A_index = 3 and Field = "User agrees on all license and autorship terms")
		ExitApp
}

License := ReadLicenseOmitHeader(LicenseFullPath)
if (License = "") {
	MsgBox, 16, Radial menu v%RMVersion%, Can't read license.
	ExitApp
}



;=== Same as in RM's AboutGui ===
Gui, 1:-MaximizeBox -MinimizeBox 
Gui, 1:Color, White

Gui, 1:Add, Picture, x0 y0 w800 h89 vRM4LogoBar, %RM4LogoBarPath%
Gui, 1:Font, s8 Q5 , Arial
Gui, 1:Add, Text, x5 y90 w790 h30 +Center BackgroundTrans , %ShortDescription%

Gui, 1:Add, GroupBox, x5 y130 w390 h40 , Author
Gui, 1:Add, GroupBox, x405 y130 w390 h40 , Contact
Gui, 1:Add, GroupBox, x5 y175 w790 h90 , Thanks to

Gui, 1:Font, s10 Q5 , Arial
Gui, 1:Add, Text, x12 y147 w380 h20 BackgroundTrans -Wrap, %Author%
Gui, 1:Add, Text, x412 y147 w380 h20 BackgroundTrans -Wrap, %Contact%
Gui, 1:Add, Text, x12 y192 w780 h70 BackgroundTrans , %ThanksTo%

;=== Specific ===
Gui, 1:Font, s8 Q5 , Arial
Gui, 1:Add, Edit, x5 y275 w790 h180  +ReadOnly -Background , %License%
Gui, 1:Add, Text, x10 y468 w450 h20 , Do you agree on all license and autorship terms?
Gui, 1:Add, Button, x530 y460 w130 h30 vNo gNo, No
Gui, 1:Add, Button, x665 y460 w130 h30 vYes gYes, Yes

GuiControl, 1:Focus, No
SoundPlay, *64
Gui, 1:Show, w800 h495, Welcome to Radial menu v%RMVersion%
return


;===Subroutines=========================================================================
Yes:
Gui, 1: destroy

AHK_LNotice=
(
AutoHotkey_L
- copyright: Chris Mallett, Lexikos, portions by AutoIt Team and various AHK community members
- license: GNU General public license
- no warranty for the program
- links, source, license text, and other info in "Legal" folder
)
MsgBox, 64, Radial menu is interpreted by AutoHotkey_L - unicode build, %AHK_LNotice%

Loop, parse, InternalTxt, `n, `r
{
	Field := Trim(A_LoopField)
	if (A_index = 3)
		NewInternalTxt .= "User agrees on all license and autorship terms" "`n"
	else
		NewInternalTxt .= Field "`n"
}
NewInternalTxt := Trim(NewInternalTxt)

FileDelete, % InternalFullPath
Sleep, 50
FileAppend, %NewInternalTxt%, % InternalFullPath, UTF-8

AdaptPaths(RM)	; for Win7 users

Sleep, 100
Run, Radial menu.exe, %RM%
ExitApp


No:
Gui, 1:+OwnDialogs
GuiControl, 1:Focus, RM4LogoBar
GuiControl, Disable, Yes
GuiControl, Disable, No
NoAgreementText =
(
As you don't agree on all license and autorship terms, you are not allowed to use Radial menu. Exit and and delete it from computer and any other device that can store electronic data immediately. You are even not allowed just to take a look at any file in Radial menu.
)
MsgBox, 262192, Radial menu v%RMVersion% - no agreement, %NoAgreementText%
ExitApp


GuiClose:
ExitApp


;===Functions===========================================================================
GetHigherDir(LevelUp=0,CustomPath="") {
	if CustomPath = 
	CustomPath := A_ScriptDir
	StringSplit, d, CustomPath, \
	Num := d0 - LevelUp
	Loop, %Num%
	ToReturn := (ToReturn) ? ToReturn "\" d%A_Index% : d%A_Index%
	Return ToReturn
}

AdaptPaths(RM) { ; In Win7 and WIN_VISTA, "My Pictures, My Music, My Videos" paths are different compared to WinXP. So when user runs RM on Win7 or WIN_VISTA for the first time, adapt those paths in Example navigator and Folders submenu.
	if A_OSVersion in WIN_7,WIN_VISTA
	{
		SplitPath, A_MyDocuments,,,,, UsersDrive	; example: "C:"
		
		FileRead, ExampleNavigator, %RM%\Menu definitions\Navigators\Example navigator.txt
		FileDelete, %RM%\Menu definitions\Navigators\Example navigator.txt
		StringReplace, ExampleNavigator, ExampleNavigator, `%A_MyDocuments`%\My Pictures, %UsersDrive%\Users\`%A_UserName`%\Pictures, All
		StringReplace, ExampleNavigator, ExampleNavigator, `%A_MyDocuments`%\My Music, %UsersDrive%\Users\`%A_UserName`%\Music, All
		StringReplace, ExampleNavigator, ExampleNavigator, `%A_MyDocuments`%\My Videos, %UsersDrive%\Users\`%A_UserName`%\Videos, All
		FileAppend, %ExampleNavigator%, %RM%\Menu definitions\Navigators\Example navigator.txt, UTF-8
		
		FileRead, Folders, %RM%\Menu definitions\Submenus\Folders.txt
		FileDelete, %RM%\Menu definitions\Submenus\Folders.txt
		StringReplace, Folders, Folders, `%A_MyDocuments`%\My Pictures, %UsersDrive%\Users\`%A_UserName`%\Pictures, All
		StringReplace, Folders, Folders, `%A_MyDocuments`%\My Music, %UsersDrive%\Users\`%A_UserName`%\Music, All
		StringReplace, Folders, Folders, `%A_MyDocuments`%\My Videos, %UsersDrive%\Users\`%A_UserName`%\Videos, All
		FileAppend, %Folders%, %RM%\Menu definitions\Submenus\Folders.txt, UTF-8
	}
}

ReadLicenseOmitHeader(LicenseFullPath) {
	static NewLine := "`r`n"
	FileRead, License, % LicenseFullPath
	Loop, parse, License, `n, `r
	{
		Line := Trim(A_LoopField)
		if (Line = "License:")
			StartReading := 1		
		if (StartReading = 1)
			LicenseOmitHeader .= A_LoopField NewLine
	}
	if LicenseOmitHeader is Space
		return		; blank return value means there was error in reading
	else
		return Trim(LicenseOmitHeader, " `t`r`n")
}

GetPathType(FullPath) {	; by Learning one. Returns "folder" or "file" or "" if not exist
	Att := FileExist(FullPath)
	return (Att = "") ? "" : (InStr(Att, "D") > 0) ? "folder" : "file"
}