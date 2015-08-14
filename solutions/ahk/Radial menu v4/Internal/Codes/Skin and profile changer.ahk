;===Auto-execute========================================================================
#NoTrayIcon
#SingleInstance, ignore

RM := GetHigherDir(2)
Menu, Tray, Icon, %RM%\Internal\RM icon.ico

;===Get data===
oInternal := SF_ObjCreate(RM "\Internal\Internal.txt", "CurProfile|CurSkin|LicenseAgreement")
SkinsList := GetSkins(RM)
ProfilesList := GetProfiles(RM)

SkinsList := PreSelectItem(SkinsList, oInternal.CurSkin)
ProfilesList := PreSelectItem(ProfilesList, oInternal.CurProfile)

;===Build Gui===
Gui, 1:-MaximizeBox -MinimizeBox
Gui, 1:Add, Text,  x10 y14 w40 h20 -Wrap, Skin:
Gui, 1:Add, DropDownList, x55 y10 w130 h20 r16 vSelSkin, %SkinsList%
Gui, 1:Add, Text,  x10 y44 w40 h20 -Wrap, Profile:
Gui, 1:Add, DropDownList, x55 y40 w130 h20 r16 vSelProfile, %ProfilesList%
Gui, 1:Add, Button, x55 y70 w130 h25, Ok
Gui, 1:Add, Link, x10 y100 w175 h20 Right, <a href="https://dl.dropboxusercontent.com/u/171417982/AHK/RM2module/RM2module and Radial menu v4 skins.html">More skins and previews</a>
Gui, 1:Show, w195 h120, Change RM's...
Return


;===Subroutines=========================================================================
GuiClose:
ExitApp

ButtonOk:
Gui, 1:+OwnDialogs
Gui, 1:Submit, nohide
If (SelProfile = "" or SelSkin = "")
{
	MsgBox, 64, Skin & profile changer, Please select RM's skin and profile.
	return
}
Gui, 1:Hide
If (SelProfile = oInternal.CurProfile and SelSkin = oInternal.CurSkin)
ExitApp

oInternal.CurProfile := SelProfile, oInternal.CurSkin := SelSkin
oInternal.ToFile()

PostMessage("Radial menu - message receiver",02)	; reload RM
ExitApp


;===Functions===========================================================================
PostMessage(Receiver,Message) {
   oldTMM := A_TitleMatchMode, oldDHW := A_DetectHiddenWindows
   SetTitleMatchMode, 3
   DetectHiddenWindows, on
   PostMessage, 0x1001,%Message%,,,%Receiver% ahk_class AutoHotkeyGUI
   SetTitleMatchMode, %oldTMM%
   DetectHiddenWindows, %oldDHW%
}  

GetHigherDir(LevelUp=0,CustomPath="") {
   if CustomPath = 
   CustomPath := A_ScriptDir
   StringSplit, d, CustomPath, \
   Num := d0 - LevelUp
   Loop, %Num%
   ToReturn := (ToReturn) ? ToReturn "\" d%A_Index% : d%A_Index%
   Return ToReturn
}

PreSelectItem(List, ToPreSelect) {
	Loop, parse, List, |
	{
		if (A_loopField = ToPreSelect)
		NewList .= A_loopField "||"
		else
		NewList .= A_loopField "|"
	}
	if !(SubStr(NewList,-1) = "||")
	NewList := RTrim(NewList,"|")
	return NewList
}

GetProfiles(RM) {
	Loop, %RM%\Menu definitions\*.txt
	{
		Field := A_LoopFileName
		if !(Field = "General settings.txt")
		{
			StringTrimRight, Field, Field, 4
			ProfilesList .= Field "|"
		}
	}
	ProfilesList := Trim(ProfilesList,"|")
	Sort, ProfilesList, D|
	return ProfilesList
}

GetSkins(RM) {
	Loop, %RM%\Skins\*,2
	{
		if A_LoopFileName not contains +
		SkinsList .= A_LoopFileName "|"
	}
	SkinsList := Trim(SkinsList,"|")
	Sort, SkinsList, D|
	return SkinsList
}

SF_ObjCreate(FilePath,KeysOrder){
	static base := Object("ToFile", "SF_ToFile")
	Loop, parse, KeysOrder, |
	{
		if A_LoopField in xmfmo24fxfxmfvfdvoe,joicjxio41cwecwejmcxu
		{
			MsgBox, 16, %A_ThisFunc% Error, You are using forbidden keys.`nObject creation failed!
			return
		}
	}
	obj := Object("base", base, "xmfmo24fxfxmfvfdvoe", FilePath, "joicjxio41cwecwejmcxu", KeysOrder)
	if !FileExist(FilePath)
	{
		Loop, parse, KeysOrder, |
		obj.Insert(A_LoopField, "")
	}
	else
	{
		FileRead, FileContents, %FilePath%
		StringSplit, v, FileContents, `n
		Loop, parse, KeysOrder, |
		obj.Insert(A_LoopField, Trim(v%A_Index%," `r`t"))
	}
	return obj
}

SF_ToFile(obj) {
	FilePath := obj.xmfmo24fxfxmfvfdvoe, KeysOrder := obj.joicjxio41cwecwejmcxu
	FileDelete, %FilePath%
	Loop, parse, KeysOrder, |
	NewFileContents := NewFileContents "`n" obj[A_LoopField] 
	NewFileContents := LTrim(NewFileContents,"`n")
	Sleep, 100
	FileAppend, %NewFileContents%, %FilePath%, UTF-8
}