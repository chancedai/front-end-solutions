;===Classes=============================================================================
Class c_App {
	static Version := 1.00, Author := "Learning one", Events := {}
	__New(oMenuOptions="", oMenuVariables="", oMisc="", oL="", oGC="", oIB="") {
		this.DevGui := new this.c_DevGui()
		if !IsObject(oMenuOptions)	
		oMenuOptions := {}
		if !IsObject(oMenuVariables)		
		oMenuVariables := {}
		if !IsObject(oMisc)	
		oMisc := {}
		if !IsObject(oL)	
		oL := {}
		if !IsObject(oGC)	
		oGC := {}
		if !IsObject(oIB)	
		oIB := {}
		this.MenuOptions := oMenuOptions, this.MenuVariables := oMenuVariables, this.Misc := oMisc
		if !InStr(FileExist(this.MenuOptions.IconsFolder), "D") {
			MsgBox, 16, Radial menu designer, % "Icons folder does not exist:`n" this.MenuOptions.IconsFolder "`n`nApplication will exit."
			ExitApp			
		}
		this.Misc.CanOpenExtensions := (this.Misc.CanOpenExtensions = "") ? "txt,ini,ahk,ahkl,html,htm" : this.Misc.CanOpenExtensions
		this.Misc.RootDir := (this.Misc.RootDir = "") ? "" : this.Misc.RootDir
		this.Misc.SkinFuncName := (this.Misc.SkinFuncName = "") ? "GetBoardSkinBitmaps" : this.Misc.SkinFuncName
		SkinFunc := Func(this.Misc.SkinFuncName)
		oL.ItemSize := (oL.ItemSize = "") ? 66 : oL.ItemSize
		oL.RadiusSizeFactor := (oL.RadiusSizeFactor = "") ? "0_9" : oL.RadiusSizeFactor
		oL.ItemLayout := (oL.ItemLayout = "") ? "6_12_18_24" : oL.ItemLayout
		oIB.ItemSize := oL.ItemSize	
		this.IB := oIB	
		this.L := {}	
		this.t := {}	
		this.D := {}	
		this.t.Deleted := "", this.t.Notes := ""
		this.t.Clipboard := new this.c_MenuDefinition("", this.MenuOptions, this.MenuVariables)	
		this.t.Temp1 := new this.c_MenuDefinition("[Item1]`nText=item", this.MenuOptions, this.MenuVariables)	
		this.L.ItemSize := oL.ItemSize, this.L.RadiusSizeFactor := oL.RadiusSizeFactor, this.L.ItemLayout := oL.ItemLayout
		this.L.RLN := oL.ItemSize "x" oL.RadiusSizeFactor "x" oL.ItemLayout	
		this.L[this.L.RLN] := new this.c_RadialLayout(this.L.RLN)	
		this.L.LLN := this.L[this.L.RLN].ItemSize "x" this.L[this.L.RLN].RadiusSizeFactor "x" this.L[this.L.RLN].TotalRings*2 "xh"	
		this.L[this.L.LLN] := new this.c_LinearLayout(this.L.LLN)	
		UnderLinePos := InStr(oL.ItemLayout, "_", 0, 0)	
		ItemsInLargestRing := (UnderLinePos = 0) ? oL.ItemLayout : SubStr(oL.ItemLayout,UnderLinePos+1)
		this.L.ItemsInLargestRing := ItemsInLargestRing	
		ItemSize := this.L[this.L.RLN].ItemSize
		Gui 1: +LastFound +OwnDialogs
		this.hGui1 := WinExist()
		RadLayoutW := this.L[this.L.RLN].RadiusesOuter[this.L[this.L.RLN].TotalRings]*2
		LinLayoutW := this.L[this.L.LLN].Width, LinLayoutH := this.L[this.L.LLN].Height
		this.GC := new this.c_GuiControl(RadLayoutW, LinLayoutW, LinLayoutH, oGC)	
		Gui 2: +LastFound -SysMenu +owner1
		this.hGui2 := WinExist()
		oGC.GuiNum := 2	
		this.SEG := new this.c_SimpleEditGui(oGC)
		this.pToken := Gdip_Startup()
		this.Bitmaps := SkinFunc.(ItemSize)	
		this.RBoard:= new this.c_GuiPicControl(1,"rbi",this.L[this.L.RLN].TotalItems,ItemSize , ItemSize)	
		this.LBoard := new this.c_GuiPicControl(1,"lbi",this.L[this.L.LLN].TotalItems, ItemSize, ItemSize)	
		this.FakeItem := new this.c_SpecialEffect({Width: ItemSize, Height: ItemSize, GuiNum: 99})	
		this.RBoard.MoveInArray(this.L[this.L.RLN].Offsets, this.GC.RLStartX, this.GC.RLStartY)	
		this.RBoard.SetBitmap(this.Bitmaps.Empty)
		this.LBoard.MoveInArray(this.L[this.L.LLN].Offsets, this.GC.LLStartX, this.GC.LLStartY)	
		this.LBoard.SetBitmap(this.Bitmaps.Empty)
		this.L.ToShow := this.RBoard.AllNums
		this.SetView("h"), this.GC.InfoBarSetText("Welcome!")
		this.D.SEG := []	
		Version := this.Version
		Gui 1:Show, hide, Radial menu designer v%Version%
About =
(
Radial menu designer (RMD) v%Version%
Author:`tBoris Mudrinić (Learning one on AHK forum)
Contact:`tboris.mudrinic@gmail.com
Thanks:`tChris Mallett, Lexikos, Tic (Tariq Porter), Majkinetor (Miodrag Milić), Rseding91, Fincs and others...
Link:`twww.autohotkey.com/community/viewtopic.php?f=2&t=50813
Video:`twww.screenr.com/THMs

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
)
		this.About := About		
	}
	LButtonOnLBoard(LName, x, y, DeleteOrigItem) {
		SelectedItemNum := this.L[LName].GetSelectedItem(this.GC.LLStartX, this.GC.LLStartY, x, y)
		if (SelectedItemNum = "")	
			return
		if !this.t.Clipboard.DoesItemExist(SelectedItemNum)
			return
		Offset := this.L[LName].Offsets[SelectedItemNum]
		StringSplit, o, Offset, :
		xOffset := x-(this.GC.LLStartX+o1), yOffset := y-(this.GC.LLStartY+o2)
		pBitmapItem := this.t.Clipboard.Item2BitmapForBoard(SelectedItemNum, this.Bitmaps.FullNB, this.Bitmaps.EmptyNB, this.IB)
		this.FakeItem.SetBitmap(pBitmapItem)
		Gdip_DisposeImage(pBitmapItem)
		this.FakeItem.ShowUM(xOffset,yOffset)
		if DeleteOrigItem
			this.LBoard.SetBitmap(this.Bitmaps.Empty, SelectedItemNum)
		this.FakeItem.DragNotActivate()
		ReleasedAt := this.FakeItem.GetPos(1)	
		this.FakeItem.Hide()	
		StringSplit, r, ReleasedAt, :
		x := r1, y := r2
		ScreenToClient(this.hGui1, x, y)
		ExportedItemText := "[Item" SelectedItemNum "]`n" this.t.Clipboard.Item2String(SelectedItemNum)  "`n`n" 	
		ExportedItem := this.t.Clipboard.ExportItem(SelectedItemNum, DeleteOrigItem)
		if (this.GC.IsAreaAt("Radial layout", x,y) = 1)	
		{
			LName := this.L.ItemSize "x" this.L.RadiusSizeFactor "x" this.L.ItemLayout
			SelectedItemNum2 := this.L[LName].GetSelectedItem(this.GC.RLStartX, this.GC.RLStartY, x, y)
			if (SelectedItemNum2 = "")	
			{
				if DeleteOrigItem
				this.t.Clipboard.DeleteItem(SelectedItemNum), this.t.Deleted .= ExportedItemText
				return
			}
			if (SelectedItemNum2 = 0)	
			WasSuccessful := 0
			else
			WasSuccessful := this.t.Menu.ImportItem(ExportedItem,SelectedItemNum2)
			if WasSuccessful
			{
				pBitmapItem := this.t.Menu.Item2BitmapForBoard(SelectedItemNum2, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
				this.RBoard.SetBitmap(pBitmapItem, SelectedItemNum2)
				Gdip_DisposeImage(pBitmapItem)
			}
			else
			{
				if DeleteOrigItem	
				{
					this.t.Clipboard.ImportItem(ExportedItem,SelectedItemNum)
					pBitmapItem := this.t.Clipboard.Item2BitmapForBoard(SelectedItemNum, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
					this.LBoard.SetBitmap(pBitmapItem, SelectedItemNum)
					Gdip_DisposeImage(pBitmapItem)
				}
			}
		}
		else if (this.GC.IsAreaAt("Linear layout", x,y) = 1)	
		{
			SelectedItemNum2 := this.L[this.L.LLN].GetSelectedItem(this.GC.LLStartX, this.GC.LLStartY, x, y)
			if (SelectedItemNum2 = "")	
			{
				if DeleteOrigItem
				this.t.Clipboard.DeleteItem(SelectedItemNum), this.t.Deleted .= ExportedItemText
				return
			}
			WasSuccessful := this.t.Clipboard.ImportItem(ExportedItem,SelectedItemNum2)
			if WasSuccessful
			{
				pBitmapItem := this.t.Clipboard.Item2BitmapForBoard(SelectedItemNum2, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
				this.LBoard.SetBitmap(pBitmapItem, SelectedItemNum2)
				Gdip_DisposeImage(pBitmapItem)
			}
			else
			{
				if DeleteOrigItem	
				{
					this.t.Clipboard.ImportItem(ExportedItem,SelectedItemNum)
					pBitmapItem := this.t.Clipboard.Item2BitmapForBoard(SelectedItemNum, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
					this.LBoard.SetBitmap(pBitmapItem, SelectedItemNum)
					Gdip_DisposeImage(pBitmapItem)
				}
			}
		}
		else	
		{
			if DeleteOrigItem
			this.t.Clipboard.DeleteItem(SelectedItemNum), this.t.Deleted .= ExportedItemText
		}
	}
	LButtonOnRBoardCenter(LName, x, y) {
		pBitmapItem := this.t.Temp1.Item2BitmapForBoard(1, this.Bitmaps.FullNB, this.Bitmaps.EmptyNB, this.IB)
			this.FakeItem.SetBitmap(pBitmapItem)
		Gdip_DisposeImage(pBitmapItem)
		xOffset := this.GC.RLStartX-this.l.ItemSize/2, yOffset := this.GC.RLStartY-this.l.ItemSize/2
		ClientToScreen(this.hGui1, xOffset, yOffset)
		this.FakeItem.Show(xOffset, yOffset)
		this.FakeItem.DragNotActivate()
		ReleasedAt := this.FakeItem.GetPos(1)	
		this.FakeItem.Hide()	
		StringSplit, r, ReleasedAt, :
		x := r1, y := r2
		ScreenToClient(this.hGui1, x, y)
		ExportedItem := this.t.Temp1.ExportItem(1,0)	
		if (this.GC.IsAreaAt("Radial layout", x,y) = 1)	
		{
			SelectedItemNum2 := this.L[LName].GetSelectedItem(this.GC.RLStartX, this.GC.RLStartY, x, y)
			if (SelectedItemNum2 = "")	
				return
			WasSuccessful := this.t.Menu.ImportItem(ExportedItem,SelectedItemNum2)
			if WasSuccessful
			{
				pBitmapItem := this.t.Menu.Item2BitmapForBoard(SelectedItemNum2, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
				this.RBoard.SetBitmap(pBitmapItem, SelectedItemNum2)
				Gdip_DisposeImage(pBitmapItem)
			}
		}
		else if (this.GC.IsAreaAt("Linear layout", x,y) = 1)	
		{
			SelectedItemNum2 := this.L[this.L.LLN].GetSelectedItem(this.GC.LLStartX, this.GC.LLStartY, x, y)
			if (SelectedItemNum2 = "")	
				return
			WasSuccessful := this.t.Clipboard.ImportItem(ExportedItem,SelectedItemNum2)
			if WasSuccessful
			{
				pBitmapItem := this.t.Clipboard.Item2BitmapForBoard(SelectedItemNum2, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
				this.LBoard.SetBitmap(pBitmapItem, SelectedItemNum2)
				Gdip_DisposeImage(pBitmapItem)
			}
		}
	}
	LButtonOnRBoard(LName, x, y, DeleteOrigItem) {
		SelectedItemNum := this.L[LName].GetSelectedItem(this.GC.RLStartX, this.GC.RLStartY, x, y)
		if (SelectedItemNum = "")	
			return
		if (SelectedItemNum = 0)	
		{
			if this.IsInCircle(this.GC.RLStartX, this.GC.RLStartY, x, y, this.L.ItemSize/2)	
			this.LButtonOnRBoardCenter(LName, x, y)	
			return
		}
		if !this.t.Menu.DoesItemExist(SelectedItemNum)
			return
		Offset := this.L[LName].Offsets[SelectedItemNum]
		StringSplit, o, Offset, :
		xOffset := x-o1-this.GC.RLStartX, yOffset := y-o2-this.GC.RLStartY
		pBitmapItem := this.t.Menu.Item2BitmapForBoard(SelectedItemNum, this.Bitmaps.FullNB, this.Bitmaps.EmptyNB, this.IB)
		this.FakeItem.SetBitmap(pBitmapItem)
		Gdip_DisposeImage(pBitmapItem)
		this.FakeItem.ShowUM(xOffset,yOffset)
		if DeleteOrigItem
			this.RBoard.SetBitmap(this.Bitmaps.Empty, SelectedItemNum)
		this.FakeItem.DragNotActivate()
		ReleasedAt := this.FakeItem.GetPos(1)	
		this.FakeItem.Hide()	
		StringSplit, r, ReleasedAt, :
		x := r1, y := r2
		ScreenToClient(this.hGui1, x, y)
		ExportedItemText := "[Item" SelectedItemNum "]`n" this.t.Menu.Item2String(SelectedItemNum)  "`n`n" 	
		ExportedItem := this.t.Menu.ExportItem(SelectedItemNum, DeleteOrigItem)
		if (this.GC.IsAreaAt("Radial layout", x,y) = 1)	
		{
			SelectedItemNum2 := this.L[LName].GetSelectedItem(this.GC.RLStartX, this.GC.RLStartY, x, y)
			if (SelectedItemNum2 = "")	
			{
				if DeleteOrigItem
				this.t.Menu.DeleteItem(SelectedItemNum), this.t.Deleted .= ExportedItemText
				return
			}
			if (SelectedItemNum2 = 0)	
			WasSuccessful := 0
			else
			WasSuccessful := this.t.Menu.ImportItem(ExportedItem,SelectedItemNum2)
			if WasSuccessful
			{
				pBitmapItem := this.t.Menu.Item2BitmapForBoard(SelectedItemNum2, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
				this.RBoard.SetBitmap(pBitmapItem, SelectedItemNum2)
				Gdip_DisposeImage(pBitmapItem)
			}
			else
			{
				if DeleteOrigItem	
				{
					this.t.Menu.ImportItem(ExportedItem,SelectedItemNum)
					pBitmapItem := this.t.Menu.Item2BitmapForBoard(SelectedItemNum, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
					this.RBoard.SetBitmap(pBitmapItem, SelectedItemNum)
					Gdip_DisposeImage(pBitmapItem)
				}
			}
		}
		else if (this.GC.IsAreaAt("Linear layout", x,y) = 1)	
		{
			SelectedItemNum2 := this.L[this.L.LLN].GetSelectedItem(this.GC.LLStartX, this.GC.LLStartY, x, y)
			if (SelectedItemNum2 = "")	
			{
				if DeleteOrigItem
				this.t.Menu.DeleteItem(SelectedItemNum), this.t.Deleted .= ExportedItemText
				return
			}
			WasSuccessful := this.t.Clipboard.ImportItem(ExportedItem,SelectedItemNum2)
			if WasSuccessful
			{
				pBitmapItem := this.t.Clipboard.Item2BitmapForBoard(SelectedItemNum2, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
				this.LBoard.SetBitmap(pBitmapItem, SelectedItemNum2)
				Gdip_DisposeImage(pBitmapItem)
			}
			else
			{
				if DeleteOrigItem	
				{
				this.t.Menu.ImportItem(ExportedItem,SelectedItemNum)
				pBitmapItem := this.t.Menu.Item2BitmapForBoard(SelectedItemNum, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
				this.RBoard.SetBitmap(pBitmapItem, SelectedItemNum)
				Gdip_DisposeImage(pBitmapItem)
				}
			}
		}
		else	
		{
			if DeleteOrigItem
			this.t.Menu.DeleteItem(SelectedItemNum), this.t.Deleted .= ExportedItemText
		}
	}
	LButtonConditions() {
		CoordMode, mouse, Screen
		MouseGetPos, x, y, WinUMID
		if (WinUMID != this.hGui1 or WinExist("A") != this.hGui1 or this.ViewType = "t" or this.D.Type = "")
		return
		ScreenToClient(this.hGui1, x, y)
		if this.GC.IsAreaAt("Radial layout", x,y)
			return 1
		else if this.GC.IsAreaAt("Linear layout", x,y)
			return 1
	}
	OnLButton() {
		CoordMode, mouse, Screen
		MouseGetPos, x,y
		DeleteOrigItem := (GetKeyState("Control", "p") = 0) ? 1 : 0
		ScreenToClient(this.hGui1, x, y)
		if this.GC.IsAreaAt("Radial layout", x,y)	
		LName := this.L.ItemSize "x" this.L.RadiusSizeFactor "x" this.L.ItemLayout, this.LButtonOnRBoard(LName, x, y, DeleteOrigItem)
		else if this.GC.IsAreaAt("Linear layout", x,y)	
		LName := this.L.LLN, this.LButtonOnLBoard(LName, x, y, DeleteOrigItem)
	}
	SetView(ViewType="") {
		if (ViewType = this.ViewType)
			return
		else if (ViewType = "h")	
			this.RBoard.Hide(), this.LBoard.Hide(), this.GC.EditHide()
		else if (this.d.Type = "t")	
			this.RBoard.Hide(), this.LBoard.Hide(), this.GC.EditShow(), this.GC.EditFocus(), this.ViewType := "t"
		else if (this.d.Type = "rm")	
		{
			if (ViewType = "t")			
			{
				EditText := this.t.Menu.Menu2String()
				this.t.Clipboard.CheckItemExistance()
				this.GC.EditSetText(EditText)
				this.RBoard.Hide(), this.LBoard.Hide(), this.GC.EditShow(), this.GC.EditFocus(), this.ViewType := "t"
			}
			else if (ViewType = "g")	
			{
				EditText := this.GC.EditGetText()
				this.t.Menu.String2Menu(EditText)
				this.t.Clipboard.CheckItemExistance()
				this.RBoard.Hide(), this.GC.EditHide()
				this.Menu2Board("Menu"), this.Menu2Board("Clipboard")
				this.LBoard.Show(), this.ViewType := "g"
			}
			else if (ViewType = "")	
			{
				if (this.ViewType = "t")
					this.SetView("g")
				else
					this.SetView("t")
			}
		}
	}
	Menu2Board(WhichMenu="Menu") {	
		if (WhichMenu = "Menu")
		WhichBoard := "RBoard"
		else if (WhichMenu = "Clipboard")
		WhichBoard := "LBoard"
		this[WhichBoard].SetBitmap(this.Bitmaps.Empty)	
		Loop, % this.t[WhichMenu]._i.TotalItems
		{
			if this.t[WhichMenu].DoesItemExist(A_Index)	
			{
				pBitmapItem := this.t[WhichMenu].Item2BitmapForBoard(A_Index, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
				this[WhichBoard].SetBitmap(pBitmapItem, A_Index)
				Gdip_DisposeImage(pBitmapItem)
			}
		}
		if (WhichMenu = "Menu")
		this.RBoard.Show(this.L.ToShow)
		else if (WhichMenu = "Clipboard")
		this.LBoard.Show()
	}
	SetLayout(ItemLayout) {
		if (ItemLayout = this.L.ItemLayout or this.D.Type != "rm" or this.ViewType != "g")
		return
		UnderLinePos := InStr(ItemLayout, "_", 0, 0)	
		ItemsInLargestRing := (UnderLinePos = 0) ? ItemLayout : SubStr(ItemLayout,UnderLinePos+1)
		if (ItemsInLargestRing > this.L.ItemsInLargestRing)
		{
			Gui 1:+OwnDialogs 
			MsgBox, 64, Set layout, Requested layout "%ItemLayout%" is too big so it will not be displayed.
			return
		}
		LName := this.L.ItemSize "x" this.L.RadiusSizeFactor "x" ItemLayout
		If !this.L.HasKey(LName)	
			this.L[LName] := new this.c_RadialLayout(LName)	
		ToAdd := this.L[LName].TotalItems - this.RBoard.Count
		if (ToAdd > 0)
		{
			c := this.RBoard.Count
			Loop % this.L[LName].TotalItems	
			{
				c++
				ToSetBitmap .= c ","
			}
			ToSetBitmap := Trim(ToSetBitmap, ",")
			this.RBoard.Add(ToAdd)
			this.RBoard.SetBitmap(this.Bitmaps.Empty, ToSetBitmap)
		}
		Loop % this.L[LName].TotalItems	
		ToShow .= A_Index ","
		ToShow := Trim(ToShow, ",")
		this.RBoard.Hide()	
		this.RBoard.MoveInArray(this.L[LName].Offsets, this.GC.RLStartX, this.GC.RLStartY)
		this.RBoard.Show(ToShow)	
		this.L.ItemLayout := ItemLayout	
		this.L.ToShow := ToShow
	}
	OnGuiDropFiles(){
		Gui 1:Show
		CoordMode, mouse, Screen
		MouseGetPos, x, y, WinUMID
		if (WinUMID != this.hGui1)
		return
		StringSplit, File, A_GuiEvent, `n	
		FilePath := File1
		if (FileExist(FilePath) = "")	
			return
		ScreenToClient(this.hGui1, x, y)
		if (this.ViewType = "t") {
			if (this.GC.IsAreaAt("InfoBar", x,y) = 1 or this.GC.IsAreaAt("Edit", x,y) = 1)
			this.Open(FilePath)
		}
		else if (this.ViewType = "g") {
			if this.GC.IsAreaAt("Radial layout", x,y)
			{
				if (this.D.Type != "rm")
					return
				LName := this.L.ItemSize "x" this.L.RadiusSizeFactor "x" this.L.ItemLayout
				SelectedItemNum2 := this.L[LName].GetSelectedItem(this.GC.RLStartX, this.GC.RLStartY, x, y)
				if (SelectedItemNum2 = "")	
					return
				if (SelectedItemNum2 = 0)	
				WasSuccessful := 0
				else
				WasSuccessful := this.t.Menu.FullPathToItem(FilePath,SelectedItemNum2)
				if WasSuccessful
				{
					pBitmapItem := this.t.Menu.Item2BitmapForBoard(SelectedItemNum2, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
					this.RBoard.SetBitmap(pBitmapItem, SelectedItemNum2)
					Gdip_DisposeImage(pBitmapItem)
					if (this.Events.AfterDropFileOnBoard != "")	
						this.Events.AfterDropFileOnBoard.(this.t.Menu, SelectedItemNum2, "Menu") 
				}
			}
			else if this.GC.IsAreaAt("Linear layout", x,y) {
				if (this.D.Type != "rm")
					return
				LName := this.L.LLN
				SelectedItemNum2 := this.L[this.L.LLN].GetSelectedItem(this.GC.LLStartX, this.GC.LLStartY, x, y)
				if (SelectedItemNum2 = "")	
					return
				WasSuccessful := this.t.Clipboard.FullPathToItem(FilePath,SelectedItemNum2)
				if WasSuccessful
				{
					pBitmapItem := this.t.Clipboard.Item2BitmapForBoard(SelectedItemNum2, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
					this.LBoard.SetBitmap(pBitmapItem, SelectedItemNum2)
					Gdip_DisposeImage(pBitmapItem)
					if (this.Events.AfterDropFileOnBoard != "")	
						this.Events.AfterDropFileOnBoard.(this.t.Clipboard, SelectedItemNum2, "Clipboard") 
				}
			}
			else if this.GC.IsAreaAt("InfoBar", x,y)
				this.Open(FilePath)
		}
	}
	OnGui2DropFiles() {	
		CoordMode, mouse, Screen
		MouseGetPos, x, y, WinUMID
		if (WinUMID != this.hGui2 or this.D.SEG.1 != "Notes")
		return
		StringSplit, File, A_GuiEvent, `n	
		FilePath := File1
		P := SplitPath(FilePath)
		Var := P.Extension, CanOpenExtensions := this.Misc.CanOpenExtensions
		if Var not in %CanOpenExtensions%
			return
		if (P.Type != "file")	
			return
		FileRead, FileContents, *t %FilePath%
		this.t.Notes := FileContents
		this.SEG.EditSetText(this.t.Notes), this.SEG.EditReadOnly(0), this.SEG.EditFocus()
		Gui 2:Show, , Notes
		this.D.SEG.1 := "Notes", this.D.SEG.2 := "", this.D.SEG.3 := this.t.Notes
	}	
	GuiContextMenu() {
		CoordMode, mouse, Screen
		MouseGetPos, x, y, WinUMID
		if (WinUMID != this.hGui1 or WinExist("A") != this.hGui1 or this.ViewType = "t" or this.D.Type = "")
		return
		ScreenToClient(this.hGui1, x, y)
		if this.GC.IsAreaAt("Radial layout", x,y)	
		{
			LName := this.L.ItemSize "x" this.L.RadiusSizeFactor "x" this.L.ItemLayout
			SelectedItemNum := this.L[LName].GetSelectedItem(this.GC.RLStartX, this.GC.RLStartY, x, y)
			if (SelectedItemNum = 0 or SelectedItemNum = "" or this.t.Menu.DoesItemExist(SelectedItemNum) != 1)
				return	
			ItemString := this.t.Menu.Item2String(SelectedItemNum)
			this.SEG.EditSetText(ItemString), this.SEG.EditReadOnly(0), this.SEG.OkFocus()
			Gui 2:Show, , % "Item " SelectedItemNum " properties - " this.D.ShortName
			this.D.SEG.1 := "Menu", this.D.SEG.2 := SelectedItemNum, this.D.SEG.3 := ItemString
			Gui 1:+Disabled
		}
		else if this.GC.IsAreaAt("Linear layout", x,y)	
		{
			LName := this.L.LLN
			SelectedItemNum := this.L[LName].GetSelectedItem(this.GC.LLStartX, this.GC.LLStartY, x, y)
			if (SelectedItemNum = "" or this.t.Clipboard.DoesItemExist(SelectedItemNum) != 1)
				return	
			ItemString := this.t.Clipboard.Item2String(SelectedItemNum)
			this.SEG.EditSetText(ItemString), this.SEG.EditReadOnly(0), this.SEG.OkFocus()
			Gui 2:Show, , % "Item " SelectedItemNum " properties - Clipboard"
			this.D.SEG.1 := "Clipboard", this.D.SEG.2 := SelectedItemNum, this.D.SEG.3 := ItemString
			Gui 1:+Disabled
		}
		else
		this.D.SEG.1 := "", this.D.SEG.2 := "", this.D.SEG.3 := ""
	}
	OnGui2Ok() {
		if (this.D.SEG.1 = "")	
			return
		NewString := this.SEG.EditGetText()
		if (this.D.SEG.3 = NewString)	
			return
		if (this.D.SEG.1 = "Menu")
		{
			WasSuccessful := this.t.Menu.String2Item(NewString, this.D.SEG.2)
			if WasSuccessful
			{
				pBitmapItem := this.t.Menu.Item2BitmapForBoard(this.D.SEG.2, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
				this.RBoard.SetBitmap(pBitmapItem, this.D.SEG.2)
				Gdip_DisposeImage(pBitmapItem)
			}
			else
				this.RBoard.SetBitmap(this.Bitmaps.Empty, this.D.SEG.2)
			if (this.ViewType != "g")
				this.GC.EditSetText(this.t.Menu.Menu2String()), this.GC.InfoBarFocus()
		}
		else if (this.D.SEG.1 = "Clipboard")
		{
			WasSuccessful := this.t.Clipboard.String2Item(NewString, this.D.SEG.2)
			if WasSuccessful
			{
				pBitmapItem := this.t.Clipboard.Item2BitmapForBoard(this.D.SEG.2, this.Bitmaps.Full, this.Bitmaps.Empty, this.IB)
				this.LBoard.SetBitmap(pBitmapItem, this.D.SEG.2)
				Gdip_DisposeImage(pBitmapItem)
			}
			else
				this.LBoard.SetBitmap(this.Bitmaps.Empty, this.D.SEG.2)
		}
		else if (this.D.SEG.1 = "Notes")
		this.t.Notes := NewString
	}
	ShowNotes() {
		Gui 1:+Disabled
		this.SEG.EditSetText(this.t.Notes), this.SEG.EditReadOnly(0), this.SEG.EditFocus()
		Gui 2:Show, , Notes
		this.D.SEG.1 := "Notes", this.D.SEG.2 := "", this.D.SEG.3 := this.t.Notes
	}
	ShowDeletedItems() {
		Gui 1:+Disabled
		this.SEG.EditSetText(this.t.Deleted), this.SEG.EditReadOnly(1), this.SEG.OkFocus()
		Gui 2:Show, , Deleted items
		this.D.SEG.1 := "", this.D.SEG.2 := "", this.D.SEG.3 := ""
	}
	ShowAbout() {
		Gui 1:+Disabled
		this.SEG.EditSetText(this.About), this.SEG.EditReadOnly(1), this.SEG.OkFocus()
		Gui 2:Show, , About
		this.D.SEG.1 := "", this.D.SEG.2 := "", this.D.SEG.3 := ""
	}
	SetFontSizeConditions() {
		MouseGetPos,,,, ControlClass
		if ControlClass not contains Edit
			return
		ActiveWinID := WinExist("A")
		if (ActiveWinID = this.hGui1 or ActiveWinID = this.hGui2)
			return 1
	}
	IsEditFocused() {
		GuiControlGet, FocusedControl, 1:Focus
			if FocusedControl contains Edit
				return 1
		GuiControlGet, FocusedControl, 2:Focus
				if FocusedControl contains Edit
				return 1
	}
	IsMainWinActive() {
		if (WinExist("A") = this.hGui1)
			return 1
	}
	IsInCircle(Xstart, Ystart, Xend, Yend, radius) {
		a := Abs(Xend-Xstart), b := Abs(Yend-Ystart), c := Sqrt(a*a+b*b)
		Return c<radius ? 1:0   
	}
	GetCurContents() {
		if (this.D.Type = "t")
			CurContents := this.GC.EditGetText()
		else if (this.D.Type = "rm")
		{
			if (this.ViewType = "t")
			{
				CurContents := this.GC.EditGetText()		
				this.t.Menu.String2Menu(CurContents)		
				CurContents := this.t.Menu.Menu2String()	
			}
			else if (this.ViewType = "g")
				CurContents := this.t.Menu.Menu2String()	
		}
		return CurContents
	}
	Delete() {
		Gui 1:+OwnDialogs 
		if (this.D.Type = "" or this.D.FilePath = "")	
		return
		ShortName := this.D.ShortName, FilePath := this.D.FilePath
		MsgBox, 36, Confirm delete, Are you sure you want to delete %FilePath%?
		IfMsgBox, Yes
		{
			FileDelete, % FilePath
			this.D.Type := "", this.D.FilePath := ""
			this.D.LastSavedContents := "", this.D.ShortName := ""
			Progress, m2 b fs13 zh0 WMn700 w200, Deleted
			SetTimer, ProgressOff, -700
			this.SetView("h"), this.GC.InfoBarSetText("Welcome!")
		}
}
	AskToSaveChanges() {
		Gui 1:+OwnDialogs 
		if (this.D.Type = "")	
			return
		CurContents := this.GetCurContents()
		if (this.D.LastSavedContents != CurContents)
		{
			ShortName := this.D.ShortName
			MsgBox, 35, Radial menu designer, Do you want to save changes to "%ShortName%"?
			IfMsgBox, No
				return "No"
			IfMsgBox, Cancel
				return "Cancel"
			IfMsgBox, Yes
				return "Yes"
		}
	}
	SaveAs(RootDir="AppRootDir") {
		RootDir := (RootDir = "AppRootDir") ? this.Misc.RootDir : RootDir
		Gui 1:+OwnDialogs 
		if (this.D.Type = "")	
			return
		CurContents := this.GetCurContents()
		if (this.D.FilePath = "" and this.D.Type = "rm" and this.t.Menu.GetTotalITems() = 0)
			return
		Loop
		{
			FileSelectFile, SelectedFile, S, %RootDir%, Save file, *.txt
			if (SelectedFile != "")
			{
				SplitPath, SelectedFile,,, ext, ShortName
				if (ext = "")
					SelectedFile .= ".txt"
				if FileExist(SelectedFile)
				{
					MsgBox, 36, Save file, %SelectedFile% already exists.`nDo you want to replace it?
					IfMsgBox, Yes
						break
				}
				else
					break
			}
			else
			return "Cancel"				
		}
		this.D.FilePath := SelectedFile, this.D.LastSavedContents := "", this.D.ShortName := ShortName
		result := this.SaveHelper(CurContents)
		return result
	}
	Save() {
		Gui 1:+OwnDialogs 
		if (this.D.Type = "")	
		return
		if (this.D.FilePath = "")	
		{
			result := this.SaveAs()
			return result
		}
		CurContents := this.GetCurContents()
		if (this.D.LastSavedContents != CurContents)
		result := this.SaveHelper(CurContents)
		return result
	}
	SaveHelper(CurContents) {
		if (this.D.Type = "rm")
		{
			result := this.t.Menu.Menu2File(this.D.FilePath)
			if (result = "Cancel")
				return "Cancel"
			else if (result = "deleted")	
			{
				this.D.Type := "", this.D.FilePath := ""
				this.D.LastSavedContents := "", this.D.ShortName := ""
				Progress, m2 b fs13 zh0 WMn700 w200, Deleted
				SetTimer, ProgressOff, -700
				this.SetView("h"), this.GC.InfoBarSetText("Welcome!")
				return
			}
			else
				this.D.LastSavedContents := CurContents
		}
		else if (this.D.Type = "t")
		{
			FileDelete, % this.D.FilePath
			FileAppend, %CurContents%`n, % this.D.FilePath, UTF-8
			this.D.LastSavedContents := CurContents
		}
		this.GC.InfoBarSetText(this.D.ShortName)
		Progress, m2 b fs13 zh0 WMn700 w200, Saved
		SetTimer, ProgressOff, -700
	}
	OnExit(AskToSaveChanges=1) {
		Gui 1:+OwnDialogs 
		if AskToSaveChanges
		{
			result := this.AskToSaveChanges()
			if (result = "Yes")
			{
				result := this.Save()
				if (result = "Cancel")
					return "Cancel"
				else
					Sleep, 700	
			}
			else if (result = "Cancel")
				return "Cancel"
		}
	}
	New(AskToSaveChanges=1) {
		Gui 1:+OwnDialogs 
		if AskToSaveChanges
		{
			result := this.AskToSaveChanges()
			if (result = "Yes")
				this.Save()
			else if (result = "cancel")
				return
		}
		this.t.Menu := ""
		this.t.Menu := new this.c_MenuDefinition("", this.MenuOptions, this.MenuVariables)
		this.D.Type := "rm", this.D.FilePath := ""
		this.D.LastSavedContents := "", this.D.ShortName := "New radial menu"
		this.GC.EditSetText(""), this.GC.InfoBarSetText("New radial menu")
		this.RBoard.Hide(), this.GC.EditHide()
		this.RBoard.SetBitmap(this.Bitmaps.Empty)
		this.RBoard.Show(this.L.ToShow), this.LBoard.Show()
		this.ViewType := "g"
	}
	Open(FilePath, Type="", AskToSaveChanges=1, AlreadyCreatedMenu="") {
		Gui 1:+OwnDialogs 
		StringSplit, File, FilePath, `n	
		FilePath := File1
		P := SplitPath(FilePath)
		Var := P.Extension, CanOpenExtensions := this.Misc.CanOpenExtensions
		if Var not in %CanOpenExtensions%
			return
		if (P.Type != "file")	
			return
		if AskToSaveChanges
		{
			result := this.AskToSaveChanges()
			if (result = "Yes")
				this.Save()
			else if (result = "cancel")
				return
		}
		if (Type = "t") {
			FileRead, EditText, *t %FilePath%
			this.D.Type := "t", this.D.FilePath := FilePath
			this.D.LastSavedContents := EditText, this.D.ShortName := SplitPath(FilePath).ShortName
			this.GC.EditSetText(EditText), this.GC.InfoBarSetText(this.D.ShortName)
			this.SetView("t")
		}
		else if (Type = "rm") {			
			this.t.Menu := ""
			if IsObject(AlreadyCreatedMenu)
				this.t.Menu := AlreadyCreatedMenu
			else
				this.t.Menu := new this.c_MenuDefinition(FilePath, this.MenuOptions, this.MenuVariables)
			this.D.Type := "rm", this.D.FilePath := FilePath
			this.D.LastSavedContents := this.t.Menu.Menu2String(), this.D.ShortName := SplitPath(FilePath).ShortName
			InfoBarText := SplitPath(FilePath).ShortName
			this.GC.EditSetText(""), this.GC.InfoBarSetText(InfoBarText)
			this.RBoard.Hide(), this.GC.EditHide()
			this.Menu2Board("Menu")
			this.LBoard.Show(), this.ViewType := "g"
		}
		else if (Type = "") {	
			Extension := SplitPath(FilePath).Extension
			if Extension not in txt
			this.Open(FilePath, "t", 0)
			else
			{
				PotentionalMenu := new this.c_MenuDefinition(FilePath, this.MenuOptions, this.MenuVariables)
				if (PotentionalMenu._i.TotalItems = 0)
				this.Open(FilePath, "t", 0)
				else
				this.Open(FilePath, "rm", 0, PotentionalMenu)
			}
		}
	}
	SelectFileToOpen(RootDir="AppRootDir") {
		RootDir := (RootDir = "AppRootDir") ? this.Misc.RootDir : RootDir
		Gui 1:+OwnDialogs 
		FileSelectFile, SelectedFile, 3, %RootDir%, Open file, *.txt
		if SelectedFile
		this.Open(SelectedFile)
	}
	GuiShow(GuiNum=1) {
		Gui %GuiNum%:Show
	}
	GuiHide(GuiNum=1) {
		Gui %GuiNum%:Hide
	}
	AlwaysOnTop(State="Toggle") {
		WinSet, AlwaysOnTop, %State%, % "ahk_id " this.hGui1
	}
	EditSetFontSize(NewSize, RelativeToCurrentSize=1) {
		this.GC.EditSetFontSize(NewSize ,RelativeToCurrentSize), this.SEG.EditSetFontSize(NewSize, RelativeToCurrentSize)
	}
	WatchTutorialVideo() {
		Run, www.screenr.com/THMs
	}
	VisitRMDHomePage() {
		Run, www.autohotkey.com/community/viewtopic.php?f=2&t=50813
	}
	__Delete() {
		this.FakeItem := ""
		For k,v in this.Bitmaps
		Gdip_DisposeImage(v)
		Gdip_Shutdown(this.pToken)
	}
	Class c_RadialLayout {
		__New(Name) {	
			pi := 3.141593, MinRadius := 12	
			StringReplace, Name, Name, _, .,All		
			StringSplit, e, Name, x
			ItemSize := e1, RadiusSizeFactor := e2, ItemLayout := e3, FixedRadius := e4
			TotalItems := 0
			this.ItemSize := ItemSize, this.RadiusSizeFactor := RadiusSizeFactor, this.FixedRadius := e4
			this.Radiuses := [], this.RadiusesOuter := [], this.Offsets := [], this.ItemLayout := []
			StringSplit, ItemsInRing, ItemLayout, .
			TotalRings := ItemsInRing0
			this.TotalRings := TotalRings
			if !(TotalRings = 1)	
			FixedRadius := "", this.FixedRadius := ""
			Loop, %TotalRings%
			{
				this.ItemLayout.Insert(ItemsInRing%A_Index%)
				TotalItems += ItemsInRing%A_Index%
				RadiusRing%A_Index% := Round(ItemSize/(2*Sin(pi/ItemsInRing%A_Index%))*RadiusSizeFactor)
			}
			this.TotalItems := TotalItems
			if (FixedRadius = "")	
			{
				if (RadiusRing1 < ItemSize*RadiusSizeFactor)	
				RadiusRing1 := ItemSize*RadiusSizeFactor
				if (RadiusRing1-ItemSize/2 < MinRadius)			
				RadiusRing1 := MinRadius+ItemSize/2
			}
			else					
			{
				RadiusRing1 := FixedRadius-ItemSize/2
				if (RadiusRing1-ItemSize/2 < MinRadius)			
				RadiusRing1 := MinRadius+ItemSize/2
				this.FixedRadius := Round(RadiusRing1+ItemSize/2)		
			}
			Loop, %TotalItems%
			{
				CurItemsInRing := ItemsInRing%A_Index%
				CurRingRadius := RadiusRing%A_Index%
				Loop, %CurItemsInRing%
				{
					if A_index = 1
					rad := 90*pi/180
					Else
					{
						deg := deg ? deg+(360/CurItemsInRing): (360/CurItemsInRing)+90
						rad := deg*pi/180
					}
					xOffset := CurRingRadius*(-1*Cos(rad))-ItemSize/2, yOffset := CurRingRadius*(-1*Sin(rad))-ItemSize/2
					xOffset := Round(xOffset), yOffset := Round(yOffset)
					this.Offsets.Insert(xOffset ":" yOffset)	
				}
				deg := ""
			}
			this.ZeroRadius := Round(RadiusRing1 - (ItemSize/2))		
			Loop, %TotalRings%	
			{
				a := A_Index+1
				if (A_Index = TotalRings)								
				CurRad := Round(RadiusRing%A_Index%+ItemSize/2)
				else													
				CurRad := Round((RadiusRing%A_Index%+RadiusRing%a%)/2)
				this.Radiuses.Insert(CurRad)
				this.RadiusesOuter.Insert(Round(RadiusRing%A_Index%+ItemSize/2))
			}
		}
		GetSelectedItem(StartX, StartY, EndX, EndY, ForcedLastRing="") {		
			Radius := this.GetRadius(StartX, StartY, EndX, EndY)
			if (Radius < this.ZeroRadius)	
			Return 0
			if (ForcedLastRing = "")	
			LastRingToCheck := this.TotalRings
			else	
			LastRingToCheck := (ForcedLastRing < this.TotalRings) ? ForcedLastRing : this.TotalRings
			Loop, % LastRingToCheck	
			{
				if (A_index = LastRingToCheck and LastRingToCheck != this.TotalRings)
				CurRingRadius := this.RadiusesOuter[A_Index]	
				else													
				CurRingRadius := this.Radiuses[A_Index]			
				if (Radius <= CurRingRadius)
				{
					SelectedRing := A_Index
					Break
				}
			}
			if (SelectedRing = "") 	
			Return
			ItemsPerRing := this.ItemLayout[SelectedRing]
			Angle := this.GetAngle(StartX, StartY, EndX, EndY)
			AnglePerItem := 360/ItemsPerRing
			Loop, %ItemsPerRing%	
			{
				if A_index = 1
				AreaMax := AnglePerItem/2
				Else
				AreaMax += AnglePerItem
				if (Angle <= AreaMax)
				{
					SelectedNumber := A_index
					Break
				}
			}
			SelectedNumber := (SelectedNumber = "") ? 1 : SelectedNumber
			if SelectedRing = 1
			return SelectedNumber
			else		
			{
				ItemsFromPreviousRings := 0
				Loop, % SelectedRing - 1
				ItemsFromPreviousRings += this.ItemLayout[A_Index]
				Return SelectedNumber + ItemsFromPreviousRings
			}
		}
		Preview(GuiNum=1, SkinType=1, DrawControlOutlines=1, DrawCentralItem=0) {
			BitmapAdd := 1	
			ItemSize := this.ItemSize, RadiusSizeFactor := this.RadiusSizeFactor
			TotalRings := this.TotalRings, TotalItems := this.TotalItems
			LayoutRadius := this.RadiusesOuter[this.TotalRings]
			Center := LayoutRadius + BitmapAdd, BitmapSize := Center*2
			pBitmap := Gdip_CreateBitmap(BitmapSize, BitmapSize), G := Gdip_GraphicsFromImage(pBitmap)
			Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)
			if SkinType = 1	
			pPen := Gdip_CreatePen("0xff0044ff", 1), pBrush := Gdip_BrushCreateSolid("0x330044ff")
			else if SkinType = 2	
			pPen := Gdip_CreatePen("0xff5555aa", 1), pBrush := Gdip_BrushCreateSolid("0xffaaaaff")
			Loop, %TotalItems%
			{
				Offset := this.Offsets[A_Index]
				StringSplit, o, Offset, :
				Gdip_FillEllipse(G, pBrush, Center+o1, Center+o2, ItemSize, ItemSize)
				Gdip_DrawEllipse(G, pPen, Center+o1, Center+o2, ItemSize, ItemSize)
			}
			If DrawCentralItem
			{
				o1 := - ItemSize/2, o2 := - ItemSize/2
				Gdip_FillEllipse(G, pBrush, Center+o1, Center+o2, ItemSize, ItemSize)
				Gdip_DrawEllipse(G, pPen, Center+o1, Center+o2, ItemSize, ItemSize)
			}
			if DrawControlOutlines
			{
				CurY := Center - this.ZeroRadius
				Gdip_DrawEllipse(G, pPen, CurY, CurY, this.ZeroRadius*2, this.ZeroRadius*2)			
				Loop %TotalRings%	
				{
					CurY := Center - this.Radiuses[A_Index]
					Gdip_DrawEllipse(G, pPen, CurY, CurY, this.Radiuses[A_Index]*2, this.Radiuses[A_Index]*2)
					if (A_index = TotalRings)
					Gdip_DrawRectangle(G, pPen, CurY, CurY, this.Radiuses[A_Index]*2, this.Radiuses[A_Index]*2)
				}
			}
			Gdip_DeleteBrush(pBrush), Gdip_DeletePen(pPen), Gdip_DeleteGraphics(G)
			hwnd := this.CreateLayeredWin(GuiNum, pBitmap, DrawControlOutlines)	
			Gdip_DisposeImage(pBitmap)
			Return hwnd
		}
		CreateLayeredWin(GuiNum, pBitmap) {
			Gui %GuiNum%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop +OwnDialogs
			Gui %GuiNum%: Show, hide
			hwnd := WinExist()
			Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
			hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
			G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)
			Gdip_DrawImage(G, pBitmap, 0, 0, Width, Height)
			UpdateLayeredWindow(hwnd, hdc, (A_ScreenWidth-Width)/2, (A_ScreenHeight-Height)/2, Width, Height)
			SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
			Gui %GuiNum%: Show, NA
			Return hwnd
		}
		GetAngle(StartX, StartY, EndX, EndY)
		{
			x := EndX-StartX, y := EndY-StartY
			if x = 0
			{
				if y > 0
				Return 180
				Else if y < 0
				Return 360
				Else
				Return
			}
		   Angle := ATan(y/x)*57.295779513
		   if x > 0
		   return Angle + 90
		   Else
		   return Angle + 270	
		}
		GetRadius(StartX, StartY, EndX, EndY)
		{
			a := Abs(endX-startX), b := Abs(endY-startY), Radius := Sqrt(a*a+b*b)
			Return Radius    
		}
	}
	Class c_LinearLayout {
		__New(Name) {	
			StringReplace, Name, Name, _, .,All
			StringSplit, e, Name, x
			ItemSize := e1, RadiusSizeFactor := e2, TotalItems := e3, Direction := e4
			this.ItemSize := ItemSize, this.RadiusSizeFactor := RadiusSizeFactor, this.TotalItems := TotalItems, this.Direction := Direction
			this.Offsets := [], TempOffsets := [], this.Delimiters := [], this.DelimitersOuter := []
			overlap := ItemSize*(1-RadiusSizeFactor)
			Loop, % TotalItems
			{
				if A_Index = 1
				TempOffsets.Insert(0)
				else
				{
					CurOffset := ItemSize*RadiusSizeFactor*(A_Index-1)
					TempOffsets.Insert(Round(CurOffset))	
					this.DelimitersOuter.Insert(Round(CurOffset+overlap))
					this.Delimiters.Insert(Round(CurOffset+overlap/2))
				}
			}
			this.DelimitersOuter.Insert(Round(TempOffsets[TotalItems] + ItemSize))
			this.Delimiters.Insert(Round(TempOffsets[TotalItems] + ItemSize))
			if (Direction = "h")	
			{
				For k,v in TempOffsets
				this.Offsets.Insert(v ":" 0)
				this.Width := TempOffsets[TotalItems] + ItemSize	
				this.Height := ItemSize
			}
			else if (Direction = "v")	
			{
				For k,v in TempOffsets
				this.Offsets.Insert(0 ":" v)
				this.Width := ItemSize
				this.Height := TempOffsets[TotalItems] + ItemSize	
			}
		}
		GetSelectedItem(StartX, StartY, EndX, EndY, ForcedLastItem="") {		
			if (ForcedLastItem = "")	
			LastItemToCheck := this.TotalItems
			else	
			LastItemToCheck := (ForcedLastItem < this.TotalItems) ? ForcedLastItem : this.TotalItems
			if (this.Direction = "h")	
			{
				YDistance := EndY-StartY
				if (YDistance > this.Height or YDistance <= 0)	
				return
				Distance := EndX - StartX
			}
			else if (this.Direction = "v")	
			{
				XDistance := EndX-StartX
				if (XDistance > this.Width or XDistance <= 0)	
				return
				Distance := EndY - StartY
			}
			if (Distance < 0)	
			return
			Loop, % LastItemToCheck	
			{
				if (A_index = LastItemToCheck and LastItemToCheck != this.TotalItems)
				CurDelimiter := this.DelimitersOuter[A_Index]		
				else													
				CurDelimiter := this.Delimiters[A_Index]			
				if (Distance <= CurDelimiter)
				{
					SelectedItem := A_Index
					Break
				}
			}
			return SelectedItem
		}
		Preview(GuiNum=1, SkinType=1, DrawControlOutlines=1) {
			BitmapAdd := 1	
			pBitmap := Gdip_CreateBitmap(this.Width+BitmapAdd*2, this.Height+BitmapAdd*2), G := Gdip_GraphicsFromImage(pBitmap)
			Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)
			if SkinType = 1	
			pPen := Gdip_CreatePen("0xff0044ff", 1), pBrush := Gdip_BrushCreateSolid("0x330044ff")
			else if SkinType = 2	
			pPen := Gdip_CreatePen("0xff5555aa", 1), pBrush := Gdip_BrushCreateSolid("0xffaaaaff")
			Loop, % this.TotalItems
			{
				Offset := this.Offsets[A_Index]
				StringSplit, o, Offset, :
				Gdip_FillEllipse(G, pBrush, o1+BitmapAdd, o2+BitmapAdd, this.ItemSize, this.ItemSize)
				Gdip_DrawEllipse(G, pPen, o1+BitmapAdd, o2+BitmapAdd, this.ItemSize, this.ItemSize)
				if DrawControlOutlines
				{
					if (this.Direction = "h")
					Gdip_DrawLine(G, pPen, this.Delimiters[A_Index]+BitmapAdd, 0+BitmapAdd, this.Delimiters[A_Index]+BitmapAdd, this.ItemSize+BitmapAdd)
					else if (this.Direction = "v")
					Gdip_DrawLine(G, pPen, 0+BitmapAdd, this.Delimiters[A_Index]+BitmapAdd, this.ItemSize+BitmapAdd, this.Delimiters[A_Index]+BitmapAdd)
					Gdip_DrawRectangle(G, pPen, 0+BitmapAdd, 0+BitmapAdd, this.Width, this.Height)
				}
			}
			Gdip_DeleteBrush(pBrush), Gdip_DeletePen(pPen), Gdip_DeleteGraphics(G)
			hwnd := this.CreateLayeredWin(GuiNum, pBitmap, DrawControlOutlines)	
			Gdip_DisposeImage(pBitmap)
			Return hwnd
		}
		CreateLayeredWin(GuiNum, pBitmap) {
			Gui %GuiNum%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop +OwnDialogs
			Gui %GuiNum%: Show, hide
			hwnd := WinExist()
			Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
			hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
			G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)
			Gdip_DrawImage(G, pBitmap, 0, 0, Width, Height)
			UpdateLayeredWindow(hwnd, hdc, (A_ScreenWidth-Width)/2, (A_ScreenHeight-Height)/2, Width, Height)
			SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
			Gui %GuiNum%: Show, NA
			Return hwnd
		}
	}
	Class c_MenuDefinition {		
		__New(FileOrString, o, v) {
			this._i := Object()	
			this._i.v := v		
			this._i.MaxAllowedItems := (o.MaxAllowedItems = "") ? 200 : o.MaxAllowedItems
			this._i.EqualSign := (o.EqualSign = "") ? "=" : o.EqualSign
			this._i.MaxCharsInItemText := (o.MaxCharsInItemText = "") ? 25 : o.MaxCharsInItemText
			this._i.BuiltInVars := (o.BuiltInVars = "") ? "A_ScriptDir|A_AhkPath|A_Temp|A_WinDir|A_ProgramFiles|A_AppData|A_Desktop|A_StartMenu|A_Programs|A_Startup|A_AppDataCommon|A_DesktopCommon|A_StartMenuCommon|A_ProgramsCommon|A_StartupCommon|A_MyDocuments" : o.BuiltInVars		
			IconsFolder := (o.IconsFolder = "") ? A_ScriptDir : o.IconsFolder
			this._i.IconsFolder := RTrim(IconsFolder, "\")
			Att := FileExist(FileOrString)
			if (Att != "" and InStr(Att, "D") = 0)	
			{
				FileRead, String, %FileOrString%
				this._i.File := FileOrString
			}
			else	
			{
				String := FileOrString
				this._i.File := ""
			}
			this.String2Menu(String)
		}
		DeleteItem(ItemNum) {	
			if this.HasKey("Item" ItemNum)
			{
				this.Remove("Item" ItemNum)
				this._i.TotalItems := this.GetTotalITems()
				return 1
			}
		}
		MoveItem(FromItemNum,ToItemNum,Delete=1) {	
			if (this.HasKey("Item" FromItemNum) = 1 and this.HasKey("Item" ToItemNum) = 0 and ToItemNum <= this._i.MaxAllowedItems)
			{
				Clone := this["Item" FromItemNum].Clone()
				this.Insert("Item" ToItemNum, Clone)
				if Delete
				this.Remove("Item" FromItemNum)
				this._i.TotalItems := this.GetTotalITems()
				return 1
			}
		}
		ExportItem(ItemNum, Delete=1) {	
			if (this.HasKey("Item" ItemNum) = 1)
			{
				Clone := this["Item" ItemNum].Clone()
				if Delete
				this.Remove("Item" ItemNum)
				this._i.TotalItems := this.GetTotalITems()
				return Clone
			}
		}
		ImportItem(oItem,ToItemNum) {	
			if (this.HasKey("Item" ToItemNum) = 0 and ToItemNum <= this._i.MaxAllowedItems)
			{
				Clone := oItem.Clone()	
				this.Insert("Item" ToItemNum, Clone)
				this._i.TotalItems := this.GetTotalITems()
				return 1
			}
		}
		FullPathToItem(FullPath, ToItemNum) {	
			if (this.HasKey("Item" ToItemNum) = 0 and ToItemNum <= this._i.MaxAllowedItems)
			{
				r := this.SplitPath(FullPath)
				if (r.Type = "")	
				return
				NewItem := {}	
				if (r.Extension = "exe")	
				{
					pBitmap := Gdip_CreateBitmapFromFile(FullPath,1,48)
					IconName := this.GetFreeFileName(r.ShortName ".png", this._i.IconsFolder)
					success := Gdip_SaveBitmapToFile(pBitmap, this._i.IconsFolder "\" IconName)
					Gdip_DisposeImage(pBitmap)
					if (success = 0)	
					{
						NewItem.Icon := this._i.IconsFolder "\" IconName
						NewItem.Action := FullPath
					}
					else	
					{
						NewItem.Text := r.ShortName
						NewItem.Action := FullPath
					}
				}
				else	
				{
					NewItem.Text := r.ShortName
					NewItem.Action := FullPath
				}
				if NewItem.HasKey("Text")
				{
					Text := NewItem.Text
					if (StrLen(Text) > this._i.MaxCharsInItemText)	
					{
						NewItem.Text := SubStr(Text,1,this._i.MaxCharsInItemText)
						if (NewItem.ToolTip = "")
						NewItem.ToolTip := Text	
					}
				}
				Clone := NewItem.Clone()
				this.Insert("Item" ToItemNum, Clone)
				this._i.TotalItems := this.GetTotalITems()
				return 1
			}
		}
		Menu2String() {	
			SectionsSeparator := ";===================================================="
			t := A_Tab
			Loop, % this.GetTotalITems()	
			{
				if this.HasKey("Item" A_index)
				String .= "[Item" A_index "]`n" this.Item2String(A_Index) "`n`n"
			}
			if this.HasKey("General") {	
				String .= SectionsSeparator "`n[General]`n"
				k := "General"
				For k2,v2 in this.General
				{
					CurValue := this.Translator(k, k2, v2, "Human")
					StringReplace, CurValue, CurValue, `n, ``n, All
					StringReplace, CurValue, CurValue, %A_Tab%, ``t, All
					String .= k2 this._i.EqualSign t CurValue "`n"
				}
				String .= "`n"
			}
			For k in this	
			{
				if (SubStr(k,1,4) = "Item" or k = "_i" or k = "General")		
				continue
				String .= SectionsSeparator "`n[" k "]`n"
				For k2,v2 in this[k]
				{
					CurValue := this.Translator(k, k2, v2, "Human")
					StringReplace, CurValue, CurValue, `n, ``n, All
					StringReplace, CurValue, CurValue, %A_Tab%, ``t, All
					String .= k2 this._i.EqualSign t CurValue "`n"
				}
				String .= "`n"
			}
			return Trim(String, "`n")
		}
		Item2String(ItemNumber) {	
			Order := "Text,Icon,Action,Tooltip,Submenu,SpecItemBack,SpecItemFore"
			String := "", t := A_Tab
			if !this.HasKey("Item" ItemNumber)	
			return
			Loop, parse, Order, `,		
			{
				if A_LoopField in Text,Icon,Action	
				{
					CurValue := this.Translator("Item", A_LoopField, this["Item" ItemNumber][A_LoopField], "Human")
					StringReplace, CurValue, CurValue, `n, ``n, All
					StringReplace, CurValue, CurValue, %A_Tab%, ``t, All
					String .= A_LoopField this._i.EqualSign t CurValue "`n"
				}
				else if (this["Item" ItemNumber][A_LoopField] != "")	
				{
					CurValue := this.Translator("Item", A_LoopField, this["Item" ItemNumber][A_LoopField], "Human")
					StringReplace, CurValue, CurValue, `n, ``n, All
					StringReplace, CurValue, CurValue, %A_Tab%, ``t, All
					String .= A_LoopField this._i.EqualSign t CurValue "`n"
				}
			}
			For k,v in this["Item" ItemNumber]	
			{
				if k not in %Order%
				{
					CurValue := this.Translator("Item", k, this["Item" ItemNumber][k], "Human")
					StringReplace, CurValue, CurValue, `n, ``n, All
					StringReplace, CurValue, CurValue, %A_Tab%, ``t, All
					String .= k this._i.EqualSign t CurValue "`n"
				}
			}
			return Trim(String, "`n")
		}
		String2Menu(String){	
			this.RemoveKeysInMenu()	
			IsSectionValid := 0
			Loop, parse, String, `n
			{
				Field := Trim(A_LoopField, " `t`r")
				if Field is space						
				Continue
				if (SubStr(Field, 1, 1) = ";")			
				Continue
				if (SubStr(Field, 1, 1) = "[")
				{
					IsSectionValid := 0
					StringTrimLeft, Field, Field, 1
					StringTrimRight, Field, Field, 1
					if (Field = "")	
					continue
					if (SubStr(Field,1,2) = "_i")	
					continue
					if (SubStr(Field,1,4) = "Item")
					{
						StringTrimLeft, ItemNum, Field, 4
						if (ItemNum > this._i.MaxAllowedItems)	
						continue
					}
					IsSectionValid := 1
					CurSection := Field		
					if (CurSection != LastCurSection and IsSectionValid = 1)	
					{
						LastCurSection := CurSection
						this.Insert(CurSection, Object())
					}
					Continue
				}
				if IsSectionValid = 0
				continue
				EqualPos := InStr(Field, this._i.EqualSign)	
				if (EqualPos = 0)						
				Continue
				var := SubStr(Field, 1, EqualPos-1)		
				StringReplace, var, var, %A_Space%, ,all
				StringReplace, var, var, %A_Tab%, ,all
				if var is space	
				Continue
				val := SubStr(Field, EqualPos+1)		
				val := Trim(val, " `t")
				if !(var = "Action")	
				{
					StringReplace, val, val, |, %A_Space%, All		
					StringReplace, val, val, >, %A_Space%, All		
				}
				if val is space
				val := ""
				Val := this.Translator(CurSection, Var, Val, "Computer")
				if !(val = "")
				this[CurSection].Insert(Var, Val)	
			}
			this.CheckItemExistance()		
			this.RefineItemTextsInMenu()
		}
		CheckItemExistance() {	
			For k,v in this	
			{
				if (SubStr(k,1,4) = "Item")
				{
					Icon := this[k]["Icon"]
					if (this[k]["Text"] = "" and FileExist(Icon)  = "")	
					ToRemoveList .= k "`n"
				}
			}
			ToRemoveList := Trim(ToRemoveList, "`n")
			Loop, parse, ToRemoveList, `n
			this.Remove(A_LoopField)
			this._i.TotalItems := this.GetTotalITems()
		}
		String2Item(String, ItemNum){	
			CurSection := "Item" ItemNum		
			this.Remove(CurSection)	
			this[CurSection] := Object()	
			Loop, parse, String, `n
			{
				Field := Trim(A_LoopField, " `t`r")
				if Field is space						
				Continue
				if (SubStr(Field, 1, 1) = ";")			
				Continue
				EqualPos := InStr(Field, this._i.EqualSign)	
				if (EqualPos = 0)						
				Continue
				var := SubStr(Field, 1, EqualPos-1)		
				StringReplace, var, var, %A_Space%, ,all
				StringReplace, var, var, %A_Tab%, ,all
				if var is space	
				Continue
				val := SubStr(Field, EqualPos+1)		
				val := Trim(val, " `t")
				if !(var = "Action")	
				{
					StringReplace, val, val, |, %A_Space%, All		
					StringReplace, val, val, >, %A_Space%, All		
				}
				if val is space
				val := ""
				Val := this.Translator(CurSection, Var, Val, "Computer")
				if !(val = "")
				this[CurSection].Insert(Var, Val)	
			}
			Icon :=  this[CurSection]["Icon"]
			if (this[CurSection]["Text"] = "" and FileExist(Icon) = "")	
			this.Remove(CurSection), ToReturn := ""	
			else
			ToReturn := 1	
			if this[CurSection].HasKey("Text")
			{
				Text := this[k].Text
				if (StrLen(Text) > this._i.MaxCharsInItemText)	
				{
					this[k].Text := SubStr(Text,1,this._i.MaxCharsInItemText)
					if (this[k].ToolTip = "")
					this[k].ToolTip := Text	
				}
			}
			this._i.TotalItems := this.GetTotalITems()
			return ToReturn
		}
		GetTotalITems(){	
			TotalItems := 0
			For k,v in this
			{
				if (SubStr(k,1,4) = "Item")
				{
					StringTrimLeft, CurNum, k, 4
					TotalItems := (CurNum > TotalItems) ? CurNum : TotalItems
				}
			}
			return TotalItems
		}
		File2Menu(FilePath){	
			FileRead, String, %FilePath%
			this._i.File := FilePath
			this.String2Menu(String)
		}
		Menu2File(CustomFilePath="",AskConfirmDelete=1){	
			FilePath := (CustomFilePath = "") ? this._i.File : CustomFilePath
			if FilePath = ""	
			return
			if (this.GetTotalITems() = 0)	
			{
				if (AskConfirmDelete=1)	
				{
					MsgBox, 36, Menu without items - confirm delete, This menu has no items`, so its menu definition file will be deleted from disk.`nAre you sure you want to delete it?
					IfMsgBox, Yes
					{
						FileDelete, % FilePath
						return "deleted"
					}
					else
						return "cancel"
				}
				else
				FileDelete, % FilePath	
			}
			else 
			{
				FileDelete, % FilePath	
				Sleep, 50
				String := this.Menu2String()
				FileAppend, %String%`n, %FilePath%, UTF-8
			}
		}
		DoesItemExist(ItemNum) {	
			return this.HasKey("Item" ItemNum)
		}
		Item2BitmapForBoard(ItemNum, pItemBack, pEmptyItem, o="") {	
			if !this.HasKey("Item" ItemNum)	
			return
			ItemSize := (o.ItemSize = "") ? 64 : o.ItemSize
			AutoSubmenuMarking := (o.AutoSubmenuMarking = "") ? 0.94 : o.AutoSubmenuMarking
			TextBoxShrink := (o.TextBoxShrink = "") ? 0.92 : o.TextBoxShrink
			TextFont := (o.TextFont = "") ? "Arial" : o.TextFont
			TextSize := (o.TextSize = "") ? 11 : o.TextSize
			TextColor := (o.TextColor = "") ? "515311" : o.TextColor
			TextTrans := (o.TextTrans = "") ? "ff" : o.TextTrans
			TextRendering := (o.TextRendering = "") ? 5 : o.TextRendering
			TextShadow := (o.TextShadow = "") ? 1 : o.TextShadow
			TextShadowColor := (o.TextShadowColor = "") ? "ffffff" : o.TextShadowColor
			TextShadowTrans := (o.TextShadowTrans = "") ? "ff" : o.TextShadowTrans
			TextShadowOffset := (o.TextShadowOffset = "") ? 1 : o.TextShadowOffset
			IconShrink := (o.IconShrink = "") ? 0.74 : o.IconShrink
			IconTrans := (o.IconTrans = "") ? 0.84 : o.IconTrans
			ItemBackShrink := (o.ItemBackShrink = "") ? 1 : o.ItemBackShrink
			ItemBackTrans := (o.ItemBackTrans = "") ? 1 : o.ItemBackTrans
			ItemForeShrink := (o.ItemForeShrink = "") ? 1 : o.ItemForeShrink
			ItemForeTrans := (o.ItemForeTrans = "") ? 1 : o.ItemForeTrans
			SpecItemBackAndForeAddShrink := (o.SpecItemBackAndForeAddShrink = "") ? 0.95 : o.SpecItemBackAndForeAddShrink	
			Text := this["Item" ItemNum].Text
			Icon := this["Item" ItemNum].Icon
			Submenu := this["Item" ItemNum].Submenu
			SpecItemBack := this["Item" ItemNum].SpecItemBack
			SpecItemFore := this["Item" ItemNum].SpecItemFore
			SIBAFAS := ItemSize-SpecItemBackAndForeAddShrink*ItemSize	
			ItemBackShrink := ItemSize-ItemBackShrink*ItemSize	
			TextBoxShrink := ItemSize-TextBoxShrink*ItemSize
			TextW := ItemSize-TextBoxShrink*2, TextH := ItemSize-TextBoxShrink*2
			IconShrink := ItemSize-IconShrink*ItemSize
			if AutoSubmenuMarking
			AutoSubmenuMarking := ItemSize-AutoSubmenuMarking*ItemSize
			BitmapSize := ItemSize
			pBitmap := Gdip_CreateBitmap(BitmapSize, BitmapSize), G := Gdip_GraphicsFromImage(pBitmap)
			Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)
			x := 0, y := 0 	
			Gdip_DrawImage(G, pEmptyItem, x+ItemBackShrink, y+ItemBackShrink	
				, ItemSize-ItemBackShrink*2, ItemSize-ItemBackShrink*2,"","","","",ItemBackTrans)
			if SpecItemBack
			{
				if !(SpecItemBack = "nb" or SpecItemBack = "no back")	
				{
					pSpecItemBack := Gdip_CreateBitmapFromFile(SpecItemBack)
					Gdip_DrawImage(G, pSpecItemBack, x+ItemBackShrink+SIBAFAS, y+ItemBackShrink+SIBAFAS
					, ItemSize-ItemBackShrink*2-SIBAFAS*2, ItemSize-ItemBackShrink*2-SIBAFAS*2)
					Gdip_DisposeImage(pSpecItemBack)
				}
			}
			Else
			Gdip_DrawImage(G, pItemBack, x+ItemBackShrink, y+ItemBackShrink
			, ItemSize-ItemBackShrink*2, ItemSize-ItemBackShrink*2,"","","","",ItemBackTrans)
			pIcon := Gdip_CreateBitmapFromFile(Icon)
			Gdip_DrawImage(G, pIcon, x+IconShrink, y+IconShrink
			, ItemSize-IconShrink*2, ItemSize-IconShrink*2,"","","","",IconTrans)
			Gdip_DisposeImage(pIcon)
			TextX := x+TextBoxShrink, TextY := y+TextBoxShrink
			if TextShadow
			{
				ShadowX := TextX + TextShadowOffset, ShadowY := TextY + TextShadowOffset
				Options = x%ShadowX% y%ShadowY% Center Vcenter c%TextShadowTrans%%TextShadowColor% r%TextRendering% s%TextSize%
				Gdip_TextToGraphics(G, Text, Options, TextFont,TextW, TextH )  
			}
			Options = x%TextX% y%TextY% Center Vcenter c%TextTrans%%TextColor% r%TextRendering% s%TextSize% 
			Gdip_TextToGraphics(G, Text, Options, TextFont,TextW, TextH )  
			if Submenu
			{
				if AutoSubmenuMarking
				{
					SubMarkX := x, SubMarkY := y+AutoSubmenuMarking
					if TextShadow
					{
						SubMarkXShadow := SubMarkX + TextShadowOffset, SubMarkYShadow := SubMarkY + TextShadowOffset
						Options = x%SubMarkXShadow% y%SubMarkYShadow% Center c%TextShadowTrans%%TextShadowColor% r%TextRendering% s%TextSize%
						Gdip_TextToGraphics(G, "**", Options, TextFont,ItemSize, ItemSize-AutoSubmenuMarking*2 )  
					}
					Options = x%SubMarkX% y%SubMarkY% Center c%TextTrans%%TextColor% r%TextRendering% s%TextSize%
					Gdip_TextToGraphics(G, "**", Options, TextFont,ItemSize,ItemSize-AutoSubmenuMarking*2)
				}
			}
			if !(SpecItemFore = "nf" or SpecItemFore = "no fore")	
			{
				if SpecItemFore	
				{
					pSpecItemFore := Gdip_CreateBitmapFromFile(SpecItemFore)
					Gdip_DrawImage(G, pSpecItemFore, x+ItemForeShrink+SIBAFAS, y+ItemForeShrink+SIBAFAS
					, ItemSize-ItemForeShrink*2-SIBAFAS*2, ItemSize-ItemForeShrink*2-SIBAFAS*2)
					Gdip_DisposeImage(pSpecItemFore)
				}
			}	
			Gdip_DeleteGraphics(G)
			Return pBitmap
		}
		Translator(Section, Key, Value, ToWho){	
			if (SubStr(Section,1,4) = "Item")		
			{
				if (Key="Icon")
				this.TranslateIcon(Value,ToWho)
				else
				this.TranslateCustomVars(Section, Key, Value, ToWho), this.TranslateBuiltInVars(Value, ToWho)	
			}
			else if (Section = "General")			
			this.TranslateCustomVars(Section, Key, Value, ToWho), this.TranslateBuiltInVars(Value, ToWho)	
			else									
			this.TranslateBuiltInVars(Value, ToWho)
			return Value
		}
		TranslateCustomVars(Section, Key, ByRef Value, ToWho){ 
			if (SubStr(Section,1,4) = "Item")
			{
				if Key in Action,SpecItemBack,SpecItemFore
				{
					For k,v in this._i.v
					{
						if ToWho in c,Computer
						StringReplace, Value, Value, %k%, %v%, All
						else if ToWho in h,Human
						StringReplace, Value, Value, %v%, %k%, All
					}
				}
			}
			else if (Section = "General")
			{
				if Key in SpecMenuBack,SpecMenuFore,CentralImage
				{
					For k,v in this._i.v
					{
						if ToWho in c,Computer
						StringReplace, Value, Value, %k%, %v%, All
						else if ToWho in h,Human
						StringReplace, Value, Value, %v%, %k%, All
					}	
				}
			}
		}
		TranslateIcon(ByRef Icon,ToWho){	
			if (Icon = "")
			return	
			IconsFolder := this._i.IconsFolder 
			if ToWho in c,Computer
			{		
				if (FileExist(IconsFolder "\" Icon))
				RefIcon := IconsFolder "\" Icon
				else if (FileExist(IconsFolder "\" Icon ".png"))
				RefIcon := IconsFolder "\" Icon ".png"
				else	
				RefIcon := ""
				if Instr(FileExist(RefIcon), "D")	
				RefIcon := ""
				Icon := RefIcon
			}
			else if ToWho in h,Human
			{
				StringReplace, Icon, Icon, %IconsFolder%
				Icon := Trim(Icon, "\")
			}
		}
		TranslateBuiltInVars(ByRef String, ToWho){	
			BuiltInVars := this._i.BuiltInVars
			if ToWho in c,Computer
			Transform, String, Deref, %String%
			else if ToWho in h,Human
			{
				Loop, parse, BuiltInVars, |
				{
					el := %A_LoopField%
					Transform, Find, Deref, %el%	
					Replace := "%" A_LoopField "%"	
					StringReplace, String, String, %Find%, %Replace%, All 
				}
			}
		}
		RefineItemTextsInMenu(){
			For k,v in this
			{
				if (SubStr(k,1,4) = "Item")
				{
					if this[k].HasKey("Text")
					{
						Text := this[k].Text
						if (StrLen(Text) > this._i.MaxCharsInItemText)	
						{
							this[k].Text := SubStr(Text,1,this._i.MaxCharsInItemText)
							if (this[k].ToolTip = "")
							this[k].ToolTip := Text	
						}
					}	
				}
			}
		}
		RemoveKeysInMenu(){	
			For k,v in this
			{
				if !(k = "_i")
				ToRemove .= k "`n"
			}
			Loop, parse, ToRemove, `n
			this.Remove(A_LoopField)
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
		GetFreeFileName(DesiredFileName, InFolder){	
			DotPos := InStr(DesiredFileName, ".",0,0)	
			NameNE :=SubStr(DesiredFileName, 1, DotPos-1), ext := SubStr(DesiredFileName, DotPos)
			if !FileExist(InFolder "\" nameNE ext)
				return nameNE ext
			Loop
			{
				if !FileExist(InFolder "\" nameNE A_Index + 1 ext)
				return nameNE A_Index + 1 ext
			}
		}
	}
	Class c_GuiPicControl {		
		__New(GuiNum, VarPrefix, Count, w, h) {
			this.GuiNum := GuiNum, this.VarPrefix := VarPrefix, this.Count := Count, this.w := w,  this.h := h, this.AllNums := "", this.Hwnds := []
			GuiPicControlHelperFunction(GuiNum, VarPrefix, Count, W, H, 0)
			Loop, % this.Count
			{
				AllNums	.= A_Index ","
				ControlID := this.VarPrefix A_Index
				GuiControlGet, hControl, %GuiNum%:hwnd, %ControlID%
				this.Hwnds.Insert(hControl)
			}
			this.AllNums := Trim(AllNums, ",")
		}
		Add(HowMany) {	
			GuiPicControlHelperFunction(this.GuiNum, this.VarPrefix, HowMany, this.w, this.h, this.Count)
			GuiNum := this.GuiNum, StartNum := this.Count, AllNums := this.AllNums ","
			Loop, % HowMany
			{
				StartNum ++
				AllNums	.= StartNum ","
				ControlID := this.VarPrefix StartNum
				GuiControlGet, hControl, %GuiNum%:hwnd, %ControlID%
				this.Hwnds.Insert(hControl)
			}
			this.AllNums := Trim(AllNums, ",")
			this.Count := this.Count + HowMany
		}
		Show(ConNumList="") {	
			GuiNum := this.GuiNum
			ConNumList := (ConNumList = "") ? this.AllNums : ConNumList
			Loop, parse, ConNumList, `,
			{
				ControlID := this.VarPrefix A_LoopField
				GuiControl, %GuiNum%:Show, %ControlID%
				GuiControl, %GuiNum%:MoveDraw, %ControlID%		
			}
		}
		Hide(ConNumList="") {	
			GuiNum := this.GuiNum
			ConNumList := (ConNumList = "") ? this.AllNums : ConNumList
			Loop, parse, ConNumList, `,
			{
				ControlID := this.VarPrefix A_LoopField
				GuiControl, %GuiNum%:Hide, %ControlID%
			}
		}
		Move(x, y, relativeX=0, relativeY=0, ConNumList="") {	
			GuiNum := this.GuiNum
			ConNumList := (ConNumList = "") ? this.AllNums : ConNumList
			x += relativeX
			y += relativeY
			Loop, parse, ConNumList, `,
			{
				ControlID := this.VarPrefix A_LoopField
				GuiControl, %GuiNum%:MoveDraw, %ControlID%, % "x" x "y" y		
			}
		}
		MoveInArray(ArrayOfCoords, relativeX=0, relativeY=0) {	
			For k,v in ArrayOfCoords
			{
				if v = ""
				continue
				StringSplit, coord, v, :
				this.Move(coord1, coord2, relativeX, relativeY, k)
			}
		}
		SetPicture(FilePath, ConNumList="") {	
			GuiNum := this.GuiNum
			ConNumList := (ConNumList = "") ? this.AllNums : ConNumList
			Loop, parse, ConNumList, `,
			{
				ControlID := this.VarPrefix A_LoopField
				GuiControl, %GuiNum%:, %ControlID%, %FilePath%
				GuiControl, %GuiNum%:MoveDraw, %ControlID%		
			}
		}
		SetBitmap(pBitmap, ConNumList="") {	
			GuiNum := this.GuiNum
			ConNumList := (ConNumList = "") ? this.AllNums : ConNumList
			Loop, parse, ConNumList, `,
			{
				hControl := this.Hwnds[A_LoopField]
				ControlID := this.VarPrefix A_LoopField
				hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hControl, hBitmap), DeleteObject(hBitmap)	
				GuiControl, %GuiNum%:MoveDraw, %ControlID%	
			}
		}
	}
	Class c_GuiControl {
		__New(RadLayoutW, LinLayoutW, LinLayoutH, o="") {	
			BorderW := (o.BorderW = "") ? 5 : o.BorderW
			InfoBarH := (o.InfoBarH = "") ? 25 : o.InfoBarH
			ButtonW := (o.ButtonW = "") ? 80 : o.ButtonW
			this.GuiNum := GuiNum := (o.GuiNum = "") ? 1 : o.GuiNum
			this.GuiFontSize := GuiFontSize :=(o.GuiFontSize = "") ? 9 : o.GuiFontSize
			this.GuiFontRendering := GuiFontRendering :=  (o.GuiFontRendering = "") ? "Q5" : o.GuiFontRendering
			GuiFontColor := (o.GuiFontColor = "") ? "444444" : o.GuiFontColor
			GuiFontName  := (o.GuiFontName = "") ? "Arial" : o.GuiFontName
			GuiColor := (o.GuiColor = "") ? "f2f2f2" : o.GuiColor
			CmdText := (o.CmdText = "") ? "Cmd" : o.CmdText
			SaveText := (o.SaveText = "") ? "Save" : o.SaveText
			b := BorderW, rlw := RadLayoutW	
			CmdX := b, CmdY := b, CmdW := ButtonW, CmdH := InfoBarH
			IBX := b + ButtonW + b, IBY := b
			IBW := rlw  - b*2 - ButtonW*2, IBH := InfoBarH
			SaveX := b + ButtonW + b + IBW + b, SaveY := b
			SaveW := ButtonW, SaveH := InfoBarH
			EX := b, EY := b + InfoBarH + b
			EW := rlw, EH := rlw + b + LinLayoutH
			LLX := Round(b + (rlw - LinLayoutW)/2)
			LLY := b + InfoBarH + b + rlw + b
			this.GuiW := GuiW := rlw + b*2, this.GuiH := GuiH := EY + EH + b
			this.GuiMinSize := GuiMinSize := GuiW "x" GuiH
			this.RLStartX := Round(EX + rlw/2), this.RLStartY := Round(EY + rlw/2)
			this.LLStartX := LLX, this.LLStartY := LLY
			this.RadLayoutCoords := [EX,rlw,Ey,rlw]
			this.LinLayoutCoords := [LLX,LinLayoutW, LLY, LinLayoutH]
			this.RadLayoutW := RadLayoutW
			oParams := {}, Params := "GuiNum|GuiColor|GuiFontRendering|GuiFontSize|GuiFontColor|GuiFontName|CmdX|CmdY|CmdW|CmdH|CmdText|IBX|IBY|IBW|IBH|SaveX|SaveY|SaveW|SaveH|SaveText|EX|EY|EW|EH|GuiW|GuiH|GuiMinSize"
			Loop, Parse, Params, |
			oParams.Insert(A_LoopField,%A_LoopField%)
			ControlHwnds := GuiLayoutHelperFunction(oParams)
			For k,v in ControlHwnds
			this.Insert(k,v)
		}
		IsAreaAt(Area, x,y){	
			GuiNum := this.GuiNum
			if (Area = "Radial layout")
			{
				return this.IsInCircle(this.RLStartX, this.RLStartY, x, y, (this.RadLayoutW/2))
			}
			else if (Area = "Linear layout")
			{
				For k,v in this.LinLayoutCoords
				c%A_Index% := v		
				if (x >= c1 and x <= (c1+c2) and y >= c3 and y <= (c3+c4))
				return 1
			}
			else if (Area = "Edit")
			{
				GuiControlGet, Edit, %GuiNum%:Pos
				if (x >= EditX and x <= (EditX + EditW) and y >= EditY and y <= (EditY +EditH))
				return 1
			}
			else if (Area = "InfoBar")
			{
				GuiControlGet, InfoBar, %GuiNum%:Pos
				if (x >= InfoBarX and x <= (InfoBarX + InfoBarW) and y >= InfoBarY and y <= (InfoBarY +InfoBarH))
				return 1
			}
		}
		EditSetText(Text="",Escape=1) {
			GuiNum := this.GuiNum
			if !Escape
			{
				StringReplace, Text, Text, `n, ``n, All
				StringReplace, Text, Text, %A_Tab%, ``t, All
			}
			GuiControl, %GuiNum%:, Edit, %Text% 
		}
		EditGetText() {
			GuiNum := this.GuiNum
			GuiControlGet, Text, %GuiNum%:, Edit
			return Text
		}
		EditShow() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Show, Edit
		}
		EditHide() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Hide, Edit
		}
		EditEnable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Enable, Edit
		}
		EditDisable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Disable, Edit
		}
		EditFocus() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Focus, Edit
		}
		EditReadOnly(state) {
			GuiNum := this.GuiNum
			if state=1
			GuiControl, %GuiNum%:+ReadOnly, Edit
			else
			GuiControl, %GuiNum%:-ReadOnly, Edit
		}
		EditSetFontSize(NewSize,RelativeToCurrentSize=1) {
			GuiNum := this.GuiNum, GuiFontRendering := this.GuiFontRendering
			if RelativeToCurrentSize
				NewSize += this.GuiFontSize
			if NewSize not between 2 and 22
				return
			this.GuiFontSize := NewSize
			Gui %GuiNum%: Font, s%NewSize% q%GuiFontRendering%
			GuiControl, %GuiNum%: Font, Edit 
		}
		InfoBarSetText(Text="",Escape=1) {
			GuiNum := this.GuiNum
			if !Escape
			{
				StringReplace, Text, Text, `n, ``n, All
				StringReplace, Text, Text, %A_Tab%, ``t, All
			}
			GuiControl, %GuiNum%:, InfoBar, %Text% 
		}
		InfoBarGetText() {
			GuiNum := this.GuiNum
			GuiControlGet, Text, %GuiNum%:, InfoBar
			return Text
		}
		InfoBarShow() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Show, InfoBar
		}
		InfoBarHide() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Hide, InfoBar
		}
		InfoBarFocus() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Focus, InfoBar
		}
		CmdEnable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Enable, Cmd
		}
		CmdDisable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Disable, Cmd
		}
		CmdSetText(Text="",Escape=1) {
			GuiNum := this.GuiNum
			if !Escape
			{
				StringReplace, Text, Text, `n, ``n, All
				StringReplace, Text, Text, %A_Tab%, ``t, All
			}
			GuiControl, %GuiNum%:, Cmd, %Text% 
		}
		CmdFocus() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Focus, Cmd
		}
		SaveEnable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Enable, Save
		}
		SaveDisable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Disable, Save
		}
		SaveSetText(Text="",Escape=1) {
			GuiNum := this.GuiNum
			if !Escape
			{
				StringReplace, Text, Text, `n, ``n, All
				StringReplace, Text, Text, %A_Tab%, ``t, All
			}
			GuiControl, %GuiNum%:, Save, %Text% 
		}
		SaveFocus() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Focus, Save
		}
		IsInCircle(Xstart, Ystart, Xend, Yend, radius)
		{
		   a := Abs(Xend-Xstart), b := Abs(Yend-Ystart), c := Sqrt(a*a+b*b)
		   Return c<radius ? 1 : ""   
		}
	}
	Class c_SpecialEffect {
		__New(o="") {
			this.Width := Width := (o.Width = "") ? 64 : o.Width
			this.Height := Height := (o.Height = "") ? 64 : o.Height
			this.GuiNum := GuiNum := (o.GuiNum = "") ? 99 : o.GuiNum
			this.alpha := 255
			Gui %GuiNum%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop +OwnDialogs
			x := Round((A_ScreenWidth-Width)/2), y := Round((A_ScreenHeight-Height)/2)
			Gui %GuiNum%: Show, hide x%x% y%y% w%Width% h%Height%
			hwnd := WinExist()
			hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
			G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)
			this.hwnd := hwnd, this.hdc := hdc, this.obm := obm, this.hbm := hbm, this.G := G
		}
		__Delete() {
			SelectObject(this.hdc, this.obm), DeleteObject(this.hbm), DeleteDC(this.hdc), Gdip_DeleteGraphics(this.G)
		}
		SetBitmap(pBitmap) {
			Gdip_SetCompositingMode(this.G, 1)
			Gdip_DrawImage(this.G, pBitmap, 0, 0, this.Width, this.Height)
			oldDHW := A_DetectHiddenWindows
			DetectHiddenWindows, On
			UpdateLayeredWindow(this.hwnd, this.hdc,"","","","", this.alpha)
			DetectHiddenWindows, %oldDHW%
		}
		Show(x="",y="") {
			GuiNum := this.GuiNum
			if (x="" and y="")
			Gui %GuiNum%: Show, NA
			else
			Gui %GuiNum%: Show, x%x% y%y% NA
		}
		Hide() {
			GuiNum := this.GuiNum
			Gui %GuiNum%: Hide
		}
		ShowUM(xoffset="",yoffset="") {	
			GuiNum := this.GuiNum
			CoordMode, mouse, screen
			MouseGetPos, mx,my
			if xoffset in c,center,centered
			Gui %GuiNum%: Show, % "x" mx - this.Width/2 " y" my - this.Height/2  " NA"
			else if (xoffset="" and xoffset="")
			Gui %GuiNum%: Show, x%mx% y%my% NA
			else
			Gui %GuiNum%: Show, % "x" mx - xoffset " y" my - yoffset  " NA"
		}
		DragNotActivate(WhileKeyDown="LButton") {
			hwnd := this.hwnd
			CoordMode, mouse, screen
			MouseGetPos, mx,my
			WinGetPos, wx,wy,,, ahk_id %hwnd%
			offsetX := mx-wx, offsetY := my-wy
			owd := A_WinDelay
			SetWinDelay, -1
			While (GetKeyState(WhileKeyDown,"p")) {
				Sleep, 20
				MouseGetPos, x,y
				WinMove, ahk_id %hwnd%,, x-offsetX,y-offsetY
			}
			SetWinDelay, %owd%
		}
		GetPos(OfWinCenter=0) {	
			oldDHW := A_DetectHiddenWindows
			DetectHiddenWindows, On
			WinGetPos, wx,wy,,, % "ahk_id "this.hwnd
			DetectHiddenWindows, %oldDHW%
			if OfWinCenter
			wx := Round(wx + this.Width/2), wy := Round(wy + this.Height/2)
			return wx ":" wy 
		}
		FadeOut(Time=20) {
			alpha := this.alpha
			Loop, % (this.alpha)/15
			{
				Sleep, %Time%
				alpha -= 15
				UpdateLayeredWindow(this.hwnd, this.hdc,"","","","", alpha)
			}
			UpdateLayeredWindow(this.hwnd, this.hdc,"","","","", 0), this.alpha := 0
		}
		FadeIn(Time=20) {
			alpha := this.alpha
			Loop, % (255 - this.alpha)/15
			{
				Sleep, %Time%
				alpha += 15
				UpdateLayeredWindow(this.hwnd, this.hdc,"","","","", alpha)
			}
			UpdateLayeredWindow(this.hwnd, this.hdc,"","","","", 255), this.alpha := 255
		}
		SetTransparency(alpha=255) {
			UpdateLayeredWindow(this.hwnd, this.hdc,"","","","", alpha), this.alpha := alpha
		}
		Blink(Count=2,Sleep=130) {
			GuiNum := this.GuiNum
			Gui %GuiNum%: Show, NA
			Loop, % Count
			{
				Sleep, %Sleep%
				Gui %GuiNum%: Hide
				Sleep, %Sleep%
				Gui %GuiNum%: Show, NA
			}
		}
	}
	Class c_DevGui {	
		__New(GuiNum=80, FontSize=9) {
			this.GuiNum := GuiNum
			DevGuiHelperFunction(GuiNum, FontSize)
		}
		See(obj, Depth=12) {	
			Text := this.ExploreObj(obj, Depth)
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:, DevGuiEdit, %Text%
			GuiControl, %GuiNum%:Focus, DevGuiDefocuser
			Gui %GuiNum%:Show
		}
		ExploreObj(Obj, Depth=12, NewRow="`n", Equal="  =  ", Indent="`t", CurIndent="") {	
			static ShowChar := 60	
			For k,v in Obj {
				StringReplace, k, k, `n,,all
				StringReplace, k, k, `r,,all
				k := (StrLen(k) > ShowChar) ? SubStr(k,1,ShowChar) " ..." : k
				if (IsObject(v))
				ToReturn .= CurIndent . k . NewRow . (depth>1 ? this.ExploreObj(v, Depth-1, NewRow, Equal, Indent, CurIndent . Indent) . NewRow : "")
				else {
					StringReplace, v, v, `n,,all
					StringReplace, v, v, `r,,all
					v := (StrLen(v) > ShowChar) ? SubStr(v,1,ShowChar) " ..." : v, ToReturn .= CurIndent . k . Equal . v . NewRow
				}
			}
			return RTrim(ToReturn, NewRow)
		}
	}
	Class c_SimpleEditGui {
		__New(o="") {	
			EditW := (o.EditW = "") ? 500 : o.EditW
			EditH := (o.EditH = "") ? 150 : o.EditH
			BorderW := (o.BorderW = "") ? 5 : o.BorderW
			ButtonW := (o.ButtonW = "") ? 80 : o.ButtonW
			ButtonH := (o.ButtonH = "") ? 25 : o.ButtonH
			this.GuiNum := GuiNum := (o.GuiNum = "") ? 2 : o.GuiNum
			Prefix := GuiNum
			TabStops := (o.TabStops = "") ? "" : o.TabStops
			this.GuiFontSize := GuiFontSize :=(o.GuiFontSize = "") ? 9 : o.GuiFontSize
			this.GuiFontRendering := GuiFontRendering :=  (o.GuiFontRendering = "") ? "Q5" : o.GuiFontRendering
			GuiFontColor := (o.GuiFontColor = "") ? "444444" : o.GuiFontColor
			GuiFontName  := (o.GuiFontName = "") ? "Arial" : o.GuiFontName
			GuiColor := (o.GuiColor = "") ? "f2f2f2" : o.GuiColor
			OkText := (o.OkText = "") ? "Ok" : o.OkText
			CancelText := (o.CancelText = "") ? "Cancel" : o.CancelText
			b := BorderW
			EditX := b, EditY := b, EditW := EditW, EditH := EditH
			OkX := b, OkY := b + EditH + b, OkW := ButtonW, OkH := ButtonH
			CancelX := b+EditW-ButtonW, CancelY := b + EditH + b, CancelW := ButtonW, CancelH := ButtonH
			GuiW := EditW + b*2, GuiH :=  EditH + b*3 + ButtonH
			this.GuiMinSize := GuiMinSize := GuiW "x" GuiH
			oParams := {}, Params := "TabStops|Prefix|GuiNum|GuiColor|GuiFontRendering|GuiFontSize|GuiFontColor|GuiFontName|EditX|EditY|EditW|EditH|OkX|OkY|OkW|OkH|OkText|CancelX|CancelY|CancelW|CancelH|CancelText|GuiW|GuiH|GuiMinSize"
			Loop, Parse, Params, |
			oParams.Insert(A_LoopField,%A_LoopField%)
			ControlHwnds := SimpleEditGuiHelperFunction(oParams)
			For k,v in ControlHwnds
			this.Insert(k,v)
		}
		EditSetText(Text="",Escape=1) {
			GuiNum := this.GuiNum
			if !Escape
			{
				StringReplace, Text, Text, `n, ``n, All
				StringReplace, Text, Text, %A_Tab%, ``t, All
			}
			GuiControl, %GuiNum%:, %GuiNum%Edit, %Text% 
		}
		EditGetText() {
			GuiNum := this.GuiNum
			GuiControlGet, Text, %GuiNum%:, %GuiNum%Edit
			return Text
		}
		EditShow() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Show, %GuiNum%Edit
		}
		EditHide() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Hide, %GuiNum%Edit
		}
		EditEnable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Enable, %GuiNum%Edit
		}
		EditDisable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Disable, %GuiNum%Edit
		}
		EditFocus() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Focus, %GuiNum%Edit
		}
		EditReadOnly(state) {
			GuiNum := this.GuiNum
			if state=1
			GuiControl, %GuiNum%:+ReadOnly, %GuiNum%Edit
			else
			GuiControl, %GuiNum%:-ReadOnly, %GuiNum%Edit
		}
		EditSetFontSize(NewSize,RelativeToCurrentSize=1) {
			GuiNum := this.GuiNum, GuiFontRendering := this.GuiFontRendering
			if RelativeToCurrentSize
				NewSize += this.GuiFontSize
			if NewSize not between 2 and 22
				return
			this.GuiFontSize := NewSize
			Gui %GuiNum%: Font, s%NewSize% q%GuiFontRendering%
			GuiControl, %GuiNum%: Font, %GuiNum%Edit 
		}
		OkEnable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Enable, %GuiNum%Ok
		}
		OkDisable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Disable, %GuiNum%Ok
		}
		OkSetText(Text="",Escape=1) {
			GuiNum := this.GuiNum
			if !Escape
			{
				StringReplace, Text, Text, `n, ``n, All
				StringReplace, Text, Text, %A_Tab%, ``t, All
			}
			GuiControl, %GuiNum%:, %GuiNum%Ok, %Text% 
		}
		OkFocus() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Focus, %GuiNum%Ok
		}
		CancelEnable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Enable, %GuiNum%Cancel
		}
		CancelDisable() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Disable, %GuiNum%Cancel
		}
		CancelSetText(Text="",Escape=1) {
			GuiNum := this.GuiNum
			if !Escape
			{
				StringReplace, Text, Text, `n, ``n, All
				StringReplace, Text, Text, %A_Tab%, ``t, All
			}
			GuiControl, %GuiNum%:, %GuiNum%Cancel, %Text% 
		}
		CancelFocus() {
			GuiNum := this.GuiNum
			GuiControl, %GuiNum%:Focus, %GuiNum%Cancel
		}
	}
}