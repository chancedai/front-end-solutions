GuiDropFiles:
App.OnGuiDropFiles()
return
2GuiDropFiles:
App.OnGui2DropFiles()
return
GuiClose:
ExitApp
ProgressOff:
Progress, off
return
GuiContextMenu:
App.GuiContextMenu()
return
CmdButton:
Gui, 1:+OwnDialogs 
MsgBox, 64, Status, Not implemented yet., 1
return
SaveButton:
App.Save()
return
2GuiClose:
2CancelButton:
Gui, 1:-Disabled
Gui 2:Hide
return
2OKButton:
Gui, 1:-Disabled
Gui 2:Hide
App.OnGui2Ok()
return