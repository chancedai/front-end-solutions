;===Functions===========================================================================
GuiPicControlHelperFunction(GuiNum, VarPrefix, Count, W, H, StartAfter) {	
	global	
	Loop, % Count
	{
		StartAfter ++
		ControlID := VarPrefix StartAfter
		Gui, %GuiNum%:Add, Picture, x1 y1 w%w% h%h% BackgroundTrans 0xE v%ControlID% Hide
		GuiControl, %GuiNum%:Hide, %ControlID%
	}
	GuiNum := "", VarPrefix := "", Count := "", W := "", H := "", StartAfter := "", ControlID := ""	
}
GuiLayoutHelperFunction(o) {	
	global	
	For k,v in o
	%k% := v
	Gui %GuiNum%:+Resize +MinSize%GuiMinSize%
	Gui %GuiNum%:Color, %GuiColor%
	Gui %GuiNum%:Font, q%GuiFontRendering% s%GuiFontSize% c%GuiFontColor%, %GuiFontName%
	Gui %GuiNum%:Add, Button, x%CmdX% y%CmdY% w%CmdW% h%CmdH% g%CmdText%Button vCmd hwndhCmd, %CmdText%
	Gui %GuiNum%:Add, Text, x%IBX% y%IBY% w%IBW% h%IBH% +0x201 +0x1000 vInfoBar hwndhInfoBar, Info bar	
	Gui %GuiNum%:Add, Button, x%SaveX% y%SaveY% w%SaveW% h%SaveH% g%SaveText%Button vSave hwndhSave, %SaveText%
	Gui %GuiNum%:Add, Edit, x%EX% y%EY% w%EW% h%EH% vEdit hwndhEdit,	
	Gui %GuiNum%:Show, hide w%GuiW% h%GuiH%
	r := {hCmd: hCmd, hInfoBar: hInfoBar, hSave: hSave, hEdit: hEdit}
	Attach(hInfoBar, "w r"), Attach(hSave, "x r"), Attach(hEdit, "w h r")	
	For k,v in o	
	%k% := ""
	k := "", v := ""
	hCmd := "", hInfoBar := "", hSave := "" , hEdit := ""
	return r
}
DevGuiHelperFunction(GuiNum, FontSize) {	
	global		
	Gui %GuiNum%:+Resize +MinSize250x100
	Gui %GuiNum%:Font, q5 s%FontSize%
	Gui %GuiNum%:Add, Text, x222 y222 w22 h22 vDevGuiDefocuser
	GuiControl, %GuiNum%:Hide, DevGuiDefocuser
	Gui %GuiNum%:Add, Edit, x2 y2 w600 h600 t15 vDevGuiEdit hwndhDevGuiEdit
	Gui %GuiNum%:Show, hide w604 h604, Developer's Gui
	Attach(hDevGuiEdit, "w h r"), GuiNum := "", hDevGuiEdit := ""
}
SimpleEditGuiHelperFunction(o) {	
	global	
	For k,v in o
	%k% := v
	Gui %GuiNum%:+Resize +MinSize%GuiMinSize%
	Gui %GuiNum%:Color, %GuiColor%
	Gui %GuiNum%:Font, q%GuiFontRendering% s%GuiFontSize% c%GuiFontColor%, %GuiFontName%
	Gui %GuiNum%:Add, Edit, x%EditX% y%EditY% w%EditW% h%EditH% Multi %TabStops% v%Prefix%Edit hwndhEdit,	
	Gui %GuiNum%:Add, Button, x%OkX% y%OkY% w%OkW% h%OkH% g%Prefix%%OkText%Button v%Prefix%Ok hwndhOk, %OkText%
	Gui %GuiNum%:Add, Button, x%CancelX% y%CancelY% w%CancelW% h%CancelH% g%Prefix%%CancelText%Button v%Prefix%Cancel hwndhCancel, %CancelText%
	Gui %GuiNum%:Show, hide w%GuiW% h%GuiH%
	r := {hEdit: hEdit, hOk: hOk, hCancel: hCancel, hEdit: hEdit} 	
	Attach(hEdit, "w h r"), Attach(hOk, "y r"), Attach(hCancel, "x y r")
	For k,v in o	
	%k% := ""
	k := "", v := ""
	hEdit := "", hOk := "", hCancel := ""
	return r
}
GetBoardSkinBitmaps(ItemSize) {	
	r := {}
	pBitmap1 := Gdip_CreateBitmap(ItemSize, ItemSize), G1 := Gdip_GraphicsFromImage(pBitmap1)
	Gdip_SetSmoothingMode(G1, 4), Gdip_SetInterpolationMode(G1, 7)
	pPen1 := Gdip_CreatePen("0x77DDDDDD", 1)
	pBrush1 := Gdip_CreateLineBrushFromRect(5, 5, ItemSize-1-10, ItemSize-1-10, "0xffEFEFEF", "0xffE6E6E6")
	pBrush2 := Gdip_BrushCreateHatch("0x20849FFF", "0x00000000", 8)	
	Gdip_FillEllipse(G1, pBrush1, 5, 5, ItemSize-1-10, ItemSize-1-10)
	Gdip_FillEllipse(G1, pBrush2, 5, 5, ItemSize-1-10, ItemSize-1-10)	
	Gdip_DrawEllipse(G1, pPen1, 5, 5, ItemSize-1-10, ItemSize-1-10)
	Gdip_DeletePen(pPen1), Gdip_DeleteBrush(pBrush1), Gdip_DeleteBrush(pBrush2)
	Gdip_DeleteGraphics(G1)
	r.Insert("EmptyNB", pBitmap1)
	pBitmap2 := Gdip_CreateBitmap(ItemSize, ItemSize), G2 := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_SetSmoothingMode(G2, 4), Gdip_SetInterpolationMode(G2, 7)
	pBrush1 := Gdip_CreateLineBrushFromRect(3, 3, ItemSize-1-6, ItemSize-1-6, "0xffFFFFBF", "0xffBABA6A")
	pBrush2 := Gdip_CreateLineBrushFromRect(5, 5, ItemSize-1-10, ItemSize-1-10, "0xffFEFDF3", "0xffF2DA43")
	pBrush3 := Gdip_BrushCreateHatch("0x16849FFF", "0x00000000", 21)	
	Gdip_FillEllipse(G2, pBrush1, 3, 3, ItemSize-1-6, ItemSize-1-6)
	Gdip_FillEllipse(G2, pBrush2, 5, 5, ItemSize-1-10, ItemSize-1-10)
	Gdip_FillEllipse(G2, pBrush3, 5, 5, ItemSize-1-10, ItemSize-1-10)
	Gdip_DeleteBrush(pBrush1), Gdip_DeleteBrush(pBrush2), Gdip_DeleteBrush(pBrush3)
	Gdip_DeleteGraphics(G2)
	r.Insert("FullNB", pBitmap2)
	pBitmap3 := Gdip_CreateBitmap(ItemSize, ItemSize), G3 := Gdip_GraphicsFromImage(pBitmap3)
	Gdip_SetSmoothingMode(G3, 4), Gdip_SetInterpolationMode(G3, 7)
	pBrush1 := Gdip_CreateLineBrushFromRect(0, 0, ItemSize-1, ItemSize-1, "0xffEDEDE6", "0xffE5E5E5")
	pBrush2 := Gdip_CreateLineBrushFromRect(1, 1, ItemSize-1-2, ItemSize-1-2, "0xffF6F6F4", "0xffF3F3F1")
	pBrush3 := Gdip_CreateLineBrushFromRect(3, 3, ItemSize-1-6, ItemSize-1-6, "0xffDFDFDF", "0xffFBFBFB")
	Gdip_FillEllipse(G3, pBrush1, 0, 0, ItemSize-1, ItemSize-1)
	Gdip_FillEllipse(G3, pBrush2, 1, 1, ItemSize-1-2, ItemSize-1-2)
	Gdip_FillEllipse(G3, pBrush3, 3, 3, ItemSize-1-6, ItemSize-1-6)
	Gdip_DeleteBrush(pBrush1), Gdip_DeleteBrush(pBrush2), Gdip_DeleteBrush(pBrush3)
	Gdip_DeleteGraphics(G3)
	r.Insert("Border", pBitmap3)
	pBitmap4 := Gdip_CloneBitmapArea(r.Border, 0, 0, ItemSize, ItemSize), G4 := Gdip_GraphicsFromImage(pBitmap4)
	Gdip_SetSmoothingMode(G4, 4), Gdip_SetInterpolationMode(G4, 7)
	Gdip_DrawImage(G4, r.EmptyNB, 0, 0, ItemSize, ItemSize)
	Gdip_DeleteGraphics(G4)
	r.Insert("Empty", pBitmap4)
	pBitmap5 := Gdip_CloneBitmapArea(r.Empty, 0, 0, ItemSize, ItemSize), G5 := Gdip_GraphicsFromImage(pBitmap5)
	Gdip_SetSmoothingMode(G5, 4), Gdip_SetInterpolationMode(G5, 7)
	Gdip_DrawImage(G5, r.FullNB, 0, 0, ItemSize, ItemSize)
	Gdip_DeleteGraphics(G5)
	r.Insert("Full", pBitmap5)
	Gdip_DisposeImage(pBitmap3)
	r.Remove("Border")
	return r
}
ScreenToClient(hwnd, ByRef x, ByRef y) {
    VarSetCapacity(pt, 8)
    NumPut(x, pt, 0, "int"), NumPut(y, pt, 4, "int")
    DllCall("ScreenToClient", A_PtrSize ? "Ptr" : "UInt", hwnd, "uint", &pt)
    x := NumGet(pt, 0, "int"), y := NumGet(pt, 4, "int")
}
ClientToScreen(hwnd, ByRef x, ByRef y) {
    VarSetCapacity(pt, 8)
    NumPut(x, pt, 0, "int"), NumPut(y, pt, 4, "int")
    DllCall("ClientToScreen", A_PtrSize ? "Ptr" : "UInt", hwnd, "uint", &pt)
    x := NumGet(pt, 0, "int"), y := NumGet(pt, 4, "int")
}
SplitPath(FullPath) {	
	oRes := {}, FullPath := RTrim( FullPath,"\")
	Attributes := FileExist(FullPath)
	if (Attributes = "")	
		return
	else if Attributes contains D	
	{
		SplitPath, FullPath, OutFileName,,,, OutDrive
		oRes.FileName := "", oRes.Dir := FullPath, oRes.Extension := ""
		oRes.Attributes := Attributes, oRes.Type := "folder"
		oRes.ShortName := (OutFileName = "") ? OutDrive : OutFileName
	}
	else 
	{
		SplitPath, FullPath , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		oRes.FileName := OutFileName, oRes.Dir := OutDir, oRes.Extension := OutExtension
		oRes.Attributes := Attributes, oRes.Type := "file"
		oRes.ShortName := OutNameNoExt
	}
	return oRes
}
CreateDDMenu(MenuDefinitionVar, MenuName="MyMenu", MenuSub="MenuSub", ReturnMenu="") {		
	Level0MenuName := MenuName, LabOrSub := MenuSub, MaxDepth := 0
	Loop, parse, MenuDefinitionVar, `n
	{
		CurLevel := 0, Field := A_LoopField
		if Field is space						
		Continue
		while (SubStr(Field,0,1) = A_space or SubStr(Field,0,1) = A_Tab or SubStr(Field,0,1) = "`r")
		StringTrimRight, Field, Field, 1
		var := Field
		while (SubStr(var,1,1) = A_Tab)
		{
			StringTrimLeft, var, var, 1
			CurLevel++
		}
		if (MaxDepth < CurLevel)
		MaxDepth := CurLevel
		lplus := CurLevel + 1, Level%lplus%MenuName := var, CurMenuName := Level%CurLevel%MenuName
		Level%CurLevel%ic .= CurMenuName "|" var "|" LabOrSub "`n"
		if (CurLevel > 0)
		{
			lminus := CurLevel - 1, icToChange := Level%lminus%ic
			StringTrimRight, icToChange, icToChange, 1
			LastLineLen := "", LastLine := ""
			Loop
			{
				LastChar := SubStr(icToChange,0,1)
				if (LastChar = "`n" or LastChar = "")
				break
				else
				{
					LastLine := LastChar LastLine
					StringTrimRight, icToChange, icToChange, 1
				}
			}
			StringSplit, v, LastLine, |
			LastLine := v1 "|" v2 "|:" v2 "`n"
			icToChange .= LastLine
			Level%lminus%ic := icToChange
		}
	}
	MaxDepth += 1
	Loop, %MaxDepth%
	{
		if A_index = 1
		CurLevel := MaxDepth - 1
		else
		CurLevel -= 1
		CurIc := Level%CurLevel%ic
		While (SubStr(CurIc,0) = "`n")
		StringTrimRight, CurIc, CurIc, 1
		if ReturnMenu
		{
			Loop, %CurLevel%
			Indentation .= A_Tab
		}
		Loop, parse, CurIc, `n
		{
			StringSplit, v, A_LoopField, |
			if ReturnMenu
			{
				if (SubStr(v2,1,3) = "---")
				ToReturn .= Indentation "Menu, " v1 ", add`n"
				else
				ToReturn .= Indentation "Menu, " v1 ", add, " v2 ", " v3 "`n"
			}	
			else
			{
				if (SubStr(v2,1,3) = "---")
				Menu, %v1%, add
				else
				Menu, %v1%, add, %v2%, %v3%
			}
		}
		Indentation := ""
	}
	if ReturnMenu
	{
		While (SubStr(ToReturn,0) = "`n")
		StringTrimRight, ToReturn, ToReturn, 1
		return ToReturn
	}
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
GetCurrent(RM) {
	static KeysOrder := "Profile|Skin|LicenseAgreement"
	StringSplit, key, KeysOrder, |
	res := {}
	FileRead, FileContents, %RM%\Internal\Internal.txt
	Loop, parse, FileContents, `n,`r
	res.Insert(key%A_Index%, Trim(A_LoopField))
	return res
}
Attach(hCtrl="", aDef="") {
	Attach_(hCtrl, aDef, "", "")
}
Attach_(hCtrl, aDef, Msg, hParent){
	static
	local s1,s2, enable, reset, oldCritical
	if (aDef = "") {							
		if IsFunc(hCtrl)
			return Handler := hCtrl
		ifEqual, adrWindowInfo,, return			
		hParent := hCtrl != "" ? hCtrl+0 : hGui
		loop, parse, %hParent%a, %A_Space%
		{
			hCtrl := A_LoopField, SubStr(%hCtrl%,1,1), aDef := SubStr(%hCtrl%,1,1)="-" ? SubStr(%hCtrl%,2) : %hCtrl%,  %hCtrl% := ""
			gosub Attach_GetPos
			loop, parse, aDef, %A_Space%
			{
				StringSplit, z, A_LoopField, :
				%hCtrl% .= A_LoopField="r" ? "r " : (z1 ":" z2 ":" c%z1% " ")
			}
			%hCtrl% := SubStr(%hCtrl%, 1, -1)				
		}
		reset := 1,  %hParent%_s := %hParent%_pw " " %hParent%_ph
	}
	if (hParent = "")  {						
		if !adrSetWindowPos
			adrSetWindowPos		:= DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "user32"), A_IsUnicode ? "astr" : "str", "SetWindowPos")
			,adrWindowInfo		:= DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "user32"), A_IsUnicode ? "astr" : "str", "GetWindowInfo")
			,OnMessage(5, A_ThisFunc),	VarSetCapacity(B, 60), NumPut(60, B), adrB := &B
			,hGui := DllCall("GetParent", "uint", hCtrl, "Uint") 
		hParent := DllCall("GetParent", "uint", hCtrl, "Uint") 
		if !%hParent%_s
			DllCall(adrWindowInfo, "uint", hParent, "uint", adrB), %hParent%_pw := NumGet(B, 28) - NumGet(B, 20), %hParent%_ph := NumGet(B, 32) - NumGet(B, 24), %hParent%_s := !%hParent%_pw || !%hParent%_ph ? "" : %hParent%_pw " " %hParent%_ph
		if InStr(" " aDef " ", "p")
			StringReplace, aDef, aDef, p, xp yp wp hp
		ifEqual, aDef, -, return SubStr(%hCtrl%,1,1) != "-" ? %hCtrl% := "-" %hCtrl% : 
		else if (aDef = "+")
			if SubStr(%hCtrl%,1,1) != "-" 
				 return
			else %hCtrl% := SubStr(%hCtrl%, 2), enable := 1 
		else {
			gosub Attach_GetPos
			%hCtrl% := ""
			loop, parse, aDef, %A_Space%
			{			
				if (l := A_LoopField) = "-"	{
					%hCtrl% := "-" %hCtrl%
					continue
				}
				f := SubStr(l,1,1), k := StrLen(l)=1 ? 1 : SubStr(l,2)
				if (j := InStr(l, "/"))
					k := SubStr(l, 2, j-2) / SubStr(l, j+1)
				%hCtrl% .= f ":" k ":" c%f% " "
			}
 			return %hCtrl% := SubStr(%hCtrl%, 1, -1), %hParent%a .= InStr(%hParent%, hCtrl) ? "" : (%hParent%a = "" ? "" : " ")  hCtrl 
		}
	}
	ifEqual, %hParent%a,, return				
	if !reset && !enable {					
		%hParent%_pw := aDef & 0xFFFF, %hParent%_ph := aDef >> 16
		ifEqual, %hParent%_ph, 0, return		
	} 
	if !%hParent%_s
		%hParent%_s := %hParent%_pw " " %hParent%_ph
	oldCritical := A_IsCritical
	critical, 5000
	StringSplit, s, %hParent%_s, %A_Space%
	loop, parse, %hParent%a, %A_Space%
	{
		hCtrl := A_LoopField, aDef := %hCtrl%, 	uw := uh := ux := uy := r := 0, hCtrl1 := SubStr(%hCtrl%,1,1)
		if (hCtrl1 = "-")
			ifEqual, reset,, continue
			else aDef := SubStr(aDef, 2)	
		gosub Attach_GetPos
		loop, parse, aDef, %A_Space%
		{
			StringSplit, z, A_LoopField, :		
			ifEqual, z1, r, SetEnv, r, %z2%
			if z2=p
				 c%z1% := z3 * (z1="x" || z1="w" ?  %hParent%_pw/s1 : %hParent%_ph/s2), u%z1% := true
			else c%z1% := z3 + z2*(z1="x" || z1="w" ?  %hParent%_pw-s1 : %hParent%_ph-s2), 	u%z1% := true
		}
		flag := 4 | (r=1 ? 0x100 : 0) | (uw OR uh ? 0 : 1) | (ux OR uy ? 0 : 2)			
		DllCall(adrSetWindowPos, "uint", hCtrl, "uint", 0, "uint", cx, "uint", cy, "uint", cw, "uint", ch, "uint", flag)
		r+0=2 ? Attach_redrawDelayed(hCtrl) : 
	}
	critical %oldCritical%
	return Handler != "" ? %Handler%(hParent) : ""
 Attach_GetPos:									
		DllCall(adrWindowInfo, "uint", hParent, "uint", adrB), 	lx := NumGet(B, 20), ly := NumGet(B, 24), DllCall(adrWindowInfo, "uint", hCtrl, "uint", adrB)
		,cx :=NumGet(B, 4),	cy := NumGet(B, 8), cw := NumGet(B, 12)-cx, ch := NumGet(B, 16)-cy, cx-=lx, cy-=ly
 return
}
Attach_redrawDelayed(hCtrl){
	static s
	s .= !InStr(s, hCtrl) ? hCtrl " " : ""
	SetTimer, %A_ThisFunc%, -100
	return
 Attach_redrawDelayed:
	loop, parse, s, %A_Space%
		WinSet, Redraw, , ahk_id %A_LoopField%
	s := ""
 return
}


;===Legal===============================================================================
/*
Attach() - copyright (c) Majkinetor. All rights reserved. Licensed under BSD;

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/


