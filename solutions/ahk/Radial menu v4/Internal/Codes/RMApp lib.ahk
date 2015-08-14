;===Description=========================================================================
/*
Radial menu application library - all by Learning one (Boris Mudrinić) except:
- item positioning formula derived from TomXIII's work
- RMApp_NCHITTEST() by Sean
- RMApp_AssocQueryApp() by TheGood and Majkinetor
- RMApp_DownloadToString() by HotKeyIt and Bentschi
- RMApp_ConnectedToInternet() by SKAN
Thank you!
*/


;===Functions===========================================================================
RMApp_Version() {
return 4.41
}
RMApp_Obj() {	
static obj := {Reg: {}, RegIA: {}}	
return obj
}
RMApp_ObjGet(p*) {		
Depth := p.MaxIndex(), obj := RMApp_Obj()
if (Depth=1)
return obj[p.1]
else if (Depth=2)
return obj[p.1][p.2]
else if (Depth=3)
return obj[p.1][p.2][p.3]
else if (Depth=4)
return obj[p.1][p.2][p.3][p.4]
else if (Depth=5)
return obj[p.1][p.2][p.3][p.4][p.5]
else if (Depth=6)
return obj[p.1][p.2][p.3][p.4][p.5][p.6]
else if (Depth=7)
return obj[p.1][p.2][p.3][p.4][p.5][p.6][p.7]
}
RMApp_ObjSet(p*) {		
NewValue := p.Remove()	
Depth := p.MaxIndex(), obj := RMApp_Obj()
if (Depth=1)
obj[p.1] := NewValue
else if (Depth=2)
obj[p.1][p.2] := NewValue
else if (Depth=3)
obj[p.1][p.2][p.3] := NewValue
else if (Depth=4)
obj[p.1][p.2][p.3][p.4] := NewValue
else if (Depth=5)
obj[p.1][p.2][p.3][p.4][p.5] := NewValue
else if (Depth=6)
obj[p.1][p.2][p.3][p.4][p.5][p.6] := NewValue
else if (Depth=7)
obj[p.1][p.2][p.3][p.4][p.5][p.6][p.7] := NewValue
}
RMApp_Suspend(state) {
if (state = 0 or state = "off") {
Menu, tray, UnCheck, Suspend
Menu, Tray, Icon, %A_ScriptDir%\Internal\RM icon.ico,,1
Suspend, off
}
else if (state = 1 or state = "on") {
Menu, tray, Check, Suspend
Menu, Tray, Icon, %A_ScriptDir%\Internal\RM tray icon suspended.ico,,1
Suspend, on
}
else if (state = 2 or state = "toggle") {
if (A_IsSuspended = 1)
RMApp_Suspend(0)
else
RMApp_Suspend(1)
}
}
RMApp_MyRMHandler(GuiNum, SelectMethod="", key="", options="",ShowPosX="", ShowPosY="") {
if (RM2_IsMenu(GuiNum) != 1)
return
Sounds := RMApp_Reg("Sounds"), SoundOnSelect := RMApp_Reg("SoundOnSelect"), SoundOnHide := RMApp_Reg("SoundOnHide")
if Sounds
RMApp_PostMessage("RMSoundOnShow",1)
if (ShowPosX = "" or ShowPosX = "under mouse")
ShowPosX := "",  ShowPosY := ""
else if (ShowPosX = "Center" or ShowPosX = "c")
ShowPosY := ""
RM2_Show(GuiNum, ShowPosX, ShowPosY)
if (Sounds = 1)
options .= " foh.RMApp_PostMessage.RMSoundOnHover.1"
SelectedItem := RM2_GetSelectedItem(GuiNum, SelectMethod, key, options, ShowPosX, ShowPosY), RM2_Hide(GuiNum)
if (SelectedItem = "") {
if Sounds
SoundPlay, %SoundOnHide%
return
}
if Sounds
SoundPlay, %SoundOnSelect%
return SelectedItem
}
RMApp_MyRMHandler2(GuiNum, SelectMethod="", key="", options="",ShowPosX="", ShowPosY="") { 	
if (RM2_IsMenu(GuiNum) != 1)
return
if options not contains pos
options .= " pos"
if options not contains gn
options .= " gn"
SelectedItem := RMApp_MyRMHandler(GuiNum, SelectMethod, key, options, ShowPosX, ShowPosY)
if (SelectedItem = "")
return
StringSplit, v, SelectedItem, |
ItemNum := v1, MenuNum := v2
if (MenuNum != 1)	
RMApp_Reg("LastUsedSubmenu", MenuNum)
ItemAction := RMApp_RegIA("M" MenuNum "#I" ItemNum)
if (ItemAction = "")
return
rEvent := RMApp_Obj().Events.BeforeExecuteItem
if (rEvent != "") {	
ReturnValue := rEvent.(ItemAction, MenuNum, ItemNum)
if (ReturnValue = "stop")	
return
}
RMApp_TheExecutor(ItemAction)
rEvent := RMApp_Obj().Events.AfterExecuteItem
if (rEvent != "")	
rEvent.(ItemAction, MenuNum, ItemNum)
return SelectedItem
}
RMApp_LoadMenu(GuiNum, FileOrString) {	
Att := FileExist(FileOrString)
if (Att != "" and InStr(Att, "D") = 0)
FileRead, Variables, %FileOrString%
else
Variables := FileOrString
MaxItemsPerMenu := RM2_Reg("MaxItemsPerMenu"), MenuNumber := GuiNum
If Variables is space
return
Loop % MaxItemsPerMenu	
{
if (RMApp_RegIA("M" GuiNum "#I" A_Index) != "")	
RMApp_RegIA("M" GuiNum "#I" A_Index, "", 1)	
}
LastItem := 0
Loop, parse, Variables, `n
{
Field := A_LoopField
if Field is space 						
Continue
while (SubStr(Field,1,1) = A_space or SubStr(Field,1,1) = A_Tab)
StringTrimLeft, Field, Field, 1
if (SubStr(Field, 1, 1) = ";")			
Continue
while (SubStr(Field,0,1) = A_space or SubStr(Field,0,1) = A_Tab or SubStr(Field,0,1) = "`r")
StringTrimRight, Field, Field, 1
if (SubStr(Field, 1, 1) = "[")			
{
StringTrimLeft, Field, Field, 1
StringTrimRight, Field, Field, 1
CurSection := Field		
IsSectionValid = 1
if (SubStr(CurSection,1,4) = "Item")
{
StringTrimLeft, CurSection, CurSection, 4
if (CurSection > MaxItemsPerMenu)	
{
IsSectionValid = 0
continue
}
if (CurSection > LastItem)		
LastItem := CurSection
CurSection := "I" CurSection		
}
Continue
}
if IsSectionValid = 0
continue
EqualPos := InStr(Field, "=")			
if (EqualPos = 0)						
Continue
var := SubStr(Field, 1, EqualPos-1)		
StringReplace, var, var, %A_Space%, ,all
StringReplace, var, var, %A_Tab%, ,all
if var is space
Continue
val := SubStr(Field, EqualPos+1)		
while (SubStr(val,1,1) = A_space or SubStr(val,1,1) = A_Tab)
StringTrimLeft, val, val, 1
if !(var = "Action")
{
StringReplace, val, val, |, %A_Space%, All		
StringReplace, val, val, >, %A_Space%, All		
}
if val is space
val =
if CurSection = General
{
if var in SpecMenuBack,SpecMenuFore,CentralImage
RMApp_RefinePaths(val)
M%MenuNumber%#%var% := val				
}
else	
{
if (var = "Submenu")	
M%MenuNumber%#%CurSection%#Submenu := ""
else if (var = "Action")	
{
RMApp_RefineItemAction(val)
VarName = M%MenuNumber%#%CurSection%
RMApp_RegIA(VarName,val)	
}
else if (var = "SpecItemBack" or var = "SpecItemFore")	
{
RMApp_RefinePaths(val)
M%MenuNumber%#%CurSection%#%var% := val
}
else if var in Text,Tooltip	
{
Transform, val, Deref, %val%
M%MenuNumber%#%CurSection%#%var% := val
}
else if (var = "Icon")	
M%MenuNumber%#%CurSection%#%var% := RMApp_CheckIcon(val)
else
M%MenuNumber%#%CurSection%#%var% := val				
}
}
Loop, %LastItem%	
{
if (M%MenuNumber%#I%A_Index%#Text = "" and M%MenuNumber%#I%A_Index%#Icon = "")	
{
M%MenuNumber%#ItemAttributes .= "|"
continue
}
CurItemAttribute := M%MenuNumber%#I%A_Index%#Text ">" M%MenuNumber%#I%A_Index%#Icon ">" M%MenuNumber%#I%A_Index%#Tooltip ">" M%MenuNumber%#I%A_Index%#Submenu ">" M%MenuNumber%#I%A_Index%#SpecItemBack ">" M%MenuNumber%#I%A_Index%#SpecItemFore
RMApp_TrimEnd(CurItemAttribute,">")
M%MenuNumber%#ItemAttributes .= CurItemAttribute "|"
}
M%MenuNumber%#CentralTextOrImageAtt := M%MenuNumber%#CentralText ">" M%MenuNumber%#CentralImage
VarNameToTrim := "M" MenuNumber "#ItemAttributes", RMApp_TrimEnd(%VarNameToTrim%)	
VarNameToTrim := "M" MenuNumber "#CentralTextOrImageAtt", RMApp_TrimEnd(%VarNameToTrim%,">")	
RM2_CreateMenu(MenuNumber,M%MenuNumber%#ItemAttributes, M%MenuNumber%#SpecMenuBack, M%MenuNumber%#SpecMenuFore
, M%MenuNumber%#OneRingerAtt, M%MenuNumber%#CentralTextOrImageAtt)
return GuiNum
}
RMApp_ReceiveMessage(Message) {
Message := LTrim(Message,0)	
rEvent := RMApp_Obj().Events.OnReceiveMessage
if (rEvent != "") {	
ReturnValue := rEvent.(Message)
if (ReturnValue = "stop")	
return
}
RunSoundPlayers := RMApp_Reg("RunSoundPlayers")
if (Message = 1)     
ExitApp
Else if (Message = 2) 
Reload
Else if (Message = 30)
RMApp_Suspend(0)
Else if (Message = 31)
RMApp_Suspend(1)
Else if (Message = 32)
RMApp_Suspend(2)
Else if (Message = 40) {
if RunSoundPlayers
RMApp_Reg("Sounds",0)
}
Else if (Message = 41) {
if RunSoundPlayers
RMApp_Reg("Sounds",1)
}
Else if (Message = 42) {
if !RunSoundPlayers
return
SoundsState := RMApp_Reg("Sounds")
if (SoundsState = 1)
RMApp_Reg("Sounds",0)
else
RMApp_Reg("Sounds",1)
}
Else if (Message = 50)
RMApp_RMShowHotkeyState(0)
Else if (Message = 51)
RMApp_RMShowHotkeyState(1)
Else if (Message = 6)
RMApp_MessageReceiverExecute()
}
RMApp_PostMessage(Receiver,Message) {
oldTMM := A_TitleMatchMode, oldDHW := A_DetectHiddenWindows
SetTitleMatchMode, 3
DetectHiddenWindows, on
PostMessage, 0x1001,%Message%,,,%Receiver% ahk_class AutoHotkeyGUI
SetTitleMatchMode, %oldTMM%
DetectHiddenWindows, %oldDHW%
}  
RMApp_OnExit() {
if (RM2_Reg("IsRM2moduleOn") = 1)	
RM2_Off()	
if (RM2_IsGdipStartedUp() = 1)		
Gdip_Shutdown(RM2_Reg("pToken"))
if (RMApp_Reg("RunSoundPlayers") = 1) {	
if (RMApp_Reg("Sounds") = 1) 		
Sleep, 950						
RMApp_PostMessage("RMSoundOnShow",3)
RMApp_PostMessage("RMSoundOnSubShow",3)
RMApp_PostMessage("RMSoundOnSubHide",3)
RMApp_PostMessage("RMSoundOnHover",3)
If (A_ExitReason = "Reload" or A_ExitReason = "Single")
Sleep, 100	
}
}
RMApp_RMShowHotkeyState(State="") {
static HotkeyState := 0
if (State="")				
return HotkeyState
RMShowHotkey := RMApp_Reg("RMShowHotkey")
if State in 1,on
{
StateNumber := 1, State := "On"
if (StateNumber = HotkeyState)	
return		
}
else if State in 0,off
{
StateNumber := 0, State := "Off"
if (StateNumber = HotkeyState)	
return		
}
else
return
Hotkey, If, (RMApp_RMShowHotkeyConditions() != "block")	
Hotkey, $*%RMShowHotkey%, RMApp_RMShowHotkey, %State%	
Hotkey, If
HotkeyState := StateNumber	
}
RMApp_RSMShowHotkeyState(State="") {
static HotkeyState := 0
if (State="")				
return HotkeyState
RSMShowHotkey := RMApp_Reg("RSMShowHotkey"), MainMenuHwnd := RM2_Reg("M1#Hwnd")
if State in 1,on
{
StateNumber := 1, State := "On"
if (StateNumber = HotkeyState)	
return		
}
else if State in 0,off
{
StateNumber := 0, State := "Off"
if (StateNumber = HotkeyState)	
return		
}
else
return
Hotkey, IfWinExist, ahk_id %MainMenuHwnd%
Hotkey, %RSMShowHotkey%, RMApp_RSMShowHotkey, %State%
Hotkey, IfWinExist
HotkeyState := StateNumber	
}
RMApp_Redraw(WhichTooltip=19) {	
if (WhichTooltip != 0)	
ToolTip, Redrawing RM...,,, % WhichTooltip
RMApp_RSMShowHotkeyState(0)	
RM2_Redraw()
RMApp_RSMShowHotkeyState(1)	
if (WhichTooltip != 0)
ToolTip,,,, % WhichTooltip
}
RMApp_StoreFunctionReferences() {	
oRM := RMApp_Obj()
oRM.Events.OnRMShowHotkey := Func("RMApp_OnRMShowHotkey")			
oRM.Events.BeforeExecuteItem := Func("RMApp_BeforeExecuteItem")		
oRM.Events.AfterExecuteItem := Func("RMApp_AfterExecuteItem")		
oRM.Events.OnReceiveMessage := Func("RMApp_OnReceiveMessage")		
}
RMApp_RMShowHotkey() {
Thread, NoTimers	
CoordMode, mouse, screen
ActiveWinID := WinExist("A")
MouseGetPos, mx1, my1, WinUMID, ControlUMClass
MouseGetPos,,,, ControlUMID, 2
ControlGetFocus, ControlFocClass , ahk_id %ActiveWinID%
imx1 := mx1, imy1:= my1
RMApp_Reg("x", mx1), RMApp_Reg("y", my1)
RMApp_Reg("WinUMID", WinUMID, 1), RMApp_Reg("ActiveWinID", ActiveWinID, 1)
RMApp_Reg("ControlUMClass", ControlUMClass, 1), RMApp_Reg("ControlUMID", ControlUMID, 1), RMApp_Reg("ControlFocClass", ControlFocClass, 1)
rEvent := RMApp_Obj().Events.OnRMShowHotkey
if (rEvent != "") {	
ReturnValue := rEvent.()
if (ReturnValue = "stop")	
return
}
RMShowHotkey := RMApp_Reg("RMShowHotkey")
MouseGestureMinDistance := RMApp_Reg("MouseGestureMinDistance")	
Sounds := RMApp_Reg("Sounds"), RSMShowHotkey := RMApp_Reg("RSMShowHotkey"), RMShowMethod := RMApp_Reg("RMShowMethod")
RMSelectMethod := RMApp_Reg("RMSelectMethod"), MainMenuShowPos := RMApp_Reg("MainMenuShowPos"), SoundOnGesture := RMApp_Reg("SoundOnGesture")
MGGestures := RMApp_Reg("MGGestures"), MGAGestures := RMApp_Reg("MGAGestures"), MoveMouseOnMGA := RMApp_Reg("MoveMouseOnMGA")
NCHTFuncToExecute := "NCHT_" RMApp_NCHITTEST() 
if !(IsFunc(NCHTFuncToExecute) = 0) {  
%NCHTFuncToExecute%()
Return
}
if RMShowMethod is not digit    
{
Loop
{
Sleep, 20   
if (GetKeyState(RMShowHotkey, "p") = 0) {	
if (Gesture = "")
SendInput, {%RMShowHotkey%}
else {
if Gesture in %MGGestures%	
{
MG_%Gesture%()	
}
}
EndX := "", EndY := "", Gesture := "", LastGesture := ""
Return
}
MouseGetPos, EndX, EndY
Radius := RM2_GetRadius(mx1, my1, EndX, EndY)
if (Radius < MouseGestureMinDistance)
Continue
Angle := RM2_GetAngle(mx1, my1, EndX, EndY)
MouseGetPos, mx1, my1
CurGesture := RMApp_GetGesture(Angle)
if (CurGesture != LastGesture) {
Gesture .= CurGesture
LastGesture := CurGesture
if (StrLen(Gesture) > 3) {   
EndX := "", EndY := "", Gesture := "", LastGesture := ""
Progress, m2 b fs10 zh0 w80 WMn700, Gesture cancelled
Sleep, 200
KeyWait, %RMShowHotkey%
Progress, off
Return
}
}
if Gesture in %RMShowMethod%	   
break
else if Gesture in %MGAGestures%	
{
if MoveMouseOnMGA	
{
Sleep, 30 
if (StrLen(Gesture) = 1)	
MouseMove, imx1, imy1  
else	
MouseMove, mx1, my1
}
MGA_%Gesture%()
return
}		
}
EndX := "", EndY := "", Gesture := "", LastGesture := ""
}
Else {    
While (A_TimeSinceThisHotkey < RMShowMethod) {       
Sleep, 20   
if (GetKeyState(RMShowHotkey,"p") = 0) {
SendInput, {%RMShowHotkey%}
Return
}
}
}
if (Sounds = 1)
RMApp_PostMessage("RMSoundOnShow",1)
if (MainMenuShowPos = "")
RM2_Show(1, imx1, imy1)
else if (MainMenuShowPos = "center")
RM2_Show(1, "center")
else {
StringSplit, c, MainMenuShowPos, `,
RM2_Show(1, c1, c2)
}
if RMShowMethod is not digit    
{
Sleep, 30   
MouseMove, imx1, imy1   
}
if (RMSelectMethod = "Click")
SelectedItem := RMApp_GetSelectedItemClickMethod(RSMShowHotkey)
else	
SelectedItem := RMApp_GetSelectedItemReleaseMethod(RMShowHotkey, RSMShowHotkey)
if (SelectedItem = "")
return
StringSplit, v, SelectedItem, |
ItemNum := v1, MenuNum := v2
if (MenuNum != 1)	
RMApp_Reg("LastUsedSubmenu", MenuNum)
ItemAction := RMApp_RegIA("M" MenuNum "#I" ItemNum)
if (ItemAction = "")
return
rEvent := RMApp_Obj().Events.BeforeExecuteItem
if (rEvent != "") {	
ReturnValue := rEvent.(ItemAction, MenuNum, ItemNum)
if (ReturnValue = "stop")	
return
}
RMApp_TheExecutor(ItemAction)
rEvent := RMApp_Obj().Events.AfterExecuteItem
if (rEvent != "")	
rEvent.(ItemAction, MenuNum, ItemNum)
}
RMApp_ExecuteSelectedText() {
IsClipEmpty := (Clipboard = "") ? 1 : 0
if (IsClipEmpty != 1) {	
ClipboardBackup := ClipboardAll	
While (Clipboard != "") {	
Clipboard := ""
Sleep, 20
}
}
Send, ^c
ClipWait, 0.1	
SelectedText := Trim(Clipboard, " `t`n`r")	
Clipboard := ClipboardBackup
if (IsClipEmpty != 1) 	
ClipWait, 0.5, 1	
if SelectedText is not space	
{
RMApp_RefineItemAction(SelectedText)
try RMApp_TheExecutor(SelectedText)	
}
}
RMApp_MessageReceiverExecute() {
static RMLiveCodeSeparator := "¤"	
hMessageReceiver := RMApp_Reg("hMessageReceiver")
hgCall := RMApp_Reg("hgCall"), hgReturn := RMApp_Reg("hgReturn"), hgExecute := RMApp_Reg("hgExecute")
if (DllCall("IsWindowVisible", A_PtrSize ? "Ptr" : "UInt", hMessageReceiver) = 1)	
GuiControl, % hMessageReceiver ":Focus", % hgCall			
GuiControl, % hMessageReceiver ":Disable", % hgExecute			
GuiControl, % hMessageReceiver ":", % hgExecute, Working...		
GuiControl, % hMessageReceiver ":+ReadOnly", % hgCall			
GuiControl, % hMessageReceiver ":+ReadOnly", % hgReturn			
GuiControlGet, UsersCall, % hMessageReceiver ":", % hgCall		
UsersCall := Trim(UsersCall, " `t`n`r")
if UsersCall is not space	
{
RMApp_RefineItemAction(UsersCall)
if (InStr(UsersCall, RMLiveCodeSeparator) = 0)		
try ReturnValue := RMApp_TheExecutor(UsersCall)		
else {													
Loop, parse, UsersCall, % RMLiveCodeSeparator
{
ThisCall := Trim(A_LoopField, " `t`n`r")
try ThisReturnValue := RMApp_TheExecutor(ThisCall)		
ReturnValue .= RMLiveCodeSeparator ThisReturnValue		
}
ReturnValue := SubStr(ReturnValue, StrLen(RMLiveCodeSeparator)+1)	
}
}
GuiControl, % hMessageReceiver ":", % hgReturn, % ReturnValue	
Sleep, 50														
GuiControl, % hMessageReceiver ":-ReadOnly", % hgCall			
GuiControl, % hMessageReceiver ":-ReadOnly", % hgReturn			
GuiControl, % hMessageReceiver ":", % hgExecute, Execute		
GuiControl, % hMessageReceiver ":Enable", % hgExecute			
}
RMApp_TheExecutor(ItemAction) {	
ExploreKey := RMApp_Reg("ExploreKey")
if (GetKeyState(ExploreKey,"p") = 1)
Explore := 1
if (SubStr(ItemAction,1,3) = "fun") { 	
if (Explore = 1)
Run, explore %A_ScriptDir%\My codes
else {
ItemAction := SubStr(ItemAction, 4)	
ItemAction := Trim(ItemAction)
FuncParamDelimiter := RMApp_Reg("FuncParamDelimiter")	
if ItemAction contains %FuncParamDelimiter%		
{
Params := []
Loop, parse, ItemAction, % FuncParamDelimiter
{
if (A_index = 1)	
FunName := Trim(A_LoopField)	
else				
Params.Insert(A_LoopField)		
}
FunInfo := IsFunc(FunName)
if (FunInfo != 0) {		
MinParams := FunInfo - 1												
RecognizedParams := (Params.MaxIndex() = "") ? 0 : Params.MaxIndex()	
if (RecognizedParams < MinParams) {			
Loop % MinParams - RecognizedParams		
Params.Insert("")					
}
ReturnValue := %FunName%(Params*)
return ReturnValue
}
}
else {	
FunName := ItemAction, FunInfo := IsFunc(FunName)
if (FunInfo != 0) {	
MinParams := FunInfo - 1
if (MinParams > 0) {	
Params := []
Loop % MinParams
Params.Insert("")					
ReturnValue := %FunName%(Params*)
}
else
ReturnValue := %FunName%()
return ReturnValue
}
}
}
}
else if (SubStr(ItemAction,1,3) = "sub") { 	
if (Explore = 1)
Run, explore %A_ScriptDir%\My codes
else {
SubName := SubStr(ItemAction, 4)	
SubName := Trim(SubName)
if (IsLabel(SubName) != 0)	
Gosub, %SubName%
}
}
else if ItemAction is integer	
{
ItemAction := Round(ItemAction)	
ComObjCreate("Shell.Application").Explore(ItemAction)	
return
}
else if (RegExMatch(ItemAction, "i)^(properties|find|explore|edit|open|print)", SysVerb) = 1) {   
SysVerbLength := StrLen(SysVerb)
StringTrimLeft, ItemAction, ItemAction, %SysVerbLength%
ItemAction := Trim(ItemAction)
if (SubStr(ItemAction, 1, 3) = "::{") {  
if (Explore = 1)
try Run, explore %ItemAction%
else
try Run, %SysVerb% %ItemAction%
Return
}
if ItemAction contains "
{                         
if (Explore = 1) {
StringSplit, v, ItemAction, "
Application := RTrim(v1, " `t")
RMApp_BeforeSplitPath(Application)
SplitPath, Application, AppFile, AppDir
try Run, explore %AppDir%
}
else
try Run, %SysVerb% %ItemAction%
Return
}
RMApp_BeforeSplitPath(ItemAction)
SplitPath, ItemAction, file, dir
if (file = "") {	
if (Explore = 1)
try Run, explore %dir%
else
try Run, %SysVerb% %dir%
Return
}
if (dir = "") {	
try Run, %SysVerb% %file%
Return
}
if (Explore = 1) {
try Run, explore %dir%
return
}
IfExist, %dir%\%file%
{
FirstRunParam := SysVerb A_Space file
try Run, %FirstRunParam%, %dir%
Return
}
}
else {	
ItemAction := Trim(ItemAction)
if (SubStr(ItemAction,1,4) = "RWRM") {	
ItemAction := SubStr(ItemAction, 5)	
ItemAction := Trim(ItemAction)
IfExist, %ItemAction%
{
if (Explore = 1) {
RMApp_BeforeSplitPath(ItemAction)
SplitPath, ItemAction, File, Dir
try Run, explore %Dir%
}
else
try Run, Radial menu.exe "%ItemAction%", %A_ScriptDir%
}
return
}
if (SubStr(ItemAction, 1, 3) = "::{") {   
if (Explore = 1)
try Run, explore %ItemAction%
else
try Run, %ItemAction%
Return
}
if ItemAction contains "
{                         
StringSplit, v, ItemAction, "
v1Lenght := StrLen(v1), Parameters := SubStr(ItemAction,v1Lenght+1)
Application := RTrim(v1, " `t")
RMApp_BeforeSplitPath(Application)
SplitPath, Application, AppFile, AppDir
if (Explore = 1)
try Run, explore %AppDir%
else {
try		
Run, %AppFile% %Parameters%, %AppDir%
catch	
try Run, %ItemAction%
}
Return
}
RMApp_BeforeSplitPath(ItemAction)
SplitPath, ItemAction, file, dir, extension
FileExtensionsExt := RMApp_Reg("FileExtensionsExt")		
if extension contains %FileExtensionsExt% 
{
if (Explore = 1) {
try Run, explore %dir%
return
}
IfNotExist, %dir%\%file%	
{
try Run, %ItemAction%
return
}
Loop, parse, FileExtensionsExt, `,
{
if (A_LoopField = extension) {
ExtNum := A_Index
break
}
}
FileExtensionsOpenWith := RMApp_Reg("FileExtensionsOpenWith")
StringSplit, v, FileExtensionsOpenWith, |
OpenWithApp := v%ExtNum%
RMApp_BeforeSplitPath(OpenWithApp)
SplitPath, OpenWithApp, OpenWithAppFile, OpenWithAppDir
FirstRunParam = %OpenWithAppFile% "%dir%\%file%"
try		
try Run, %FirstRunParam%, %OpenWithAppDir%
catch
try Run, %ItemAction%
return
}
if (file = "") {		
if (Explore = 1)
try Run, explore %ItemAction%
else
try Run, %ItemAction%
Return
}
if (dir = "") {		
try Run, %ItemAction%
Return
}
if (Explore = 1) {
try Run, explore %dir%
return
}
IfExist, %ItemAction%
{
if (SubStr(file,1, 11) = "Radial menu")	
try Run, %ItemAction%	
else {
try Run, %file%, %dir%	
catch
try Run, %ItemAction%
}
}
else	
try Run, %ItemAction%
}
}	
RMApp_BeforeSplitPath(ByRef FullPath) {	
if (InStr(FileExist(FullPath), "D") and SubStr(FullPath,0) != "\")
FullPath .= "\"
}
RMApp_RefineItemAction(ByRef ItemAction) {
ItemAction := LTrim(ItemAction, " `t`n`r")
if (SubStr(ItemAction,1,3) = "..\")
ItemAction := RMApp_RefineDoubleDotsPath(ItemAction, A_ScriptDir)	
else if (SubStr(ItemAction,1,1) = ".") {	
ItemAction := RMApp_AssocQueryApp(ItemAction)
return 
}	
Transform, ItemAction, Deref, %ItemAction%		
StringReplace, ItemAction, ItemAction, RM\, %A_ScriptDir%\	
}
RMApp_RefinePaths(ByRef val) {
Transform, val, Deref, %val%
if (SubStr(val,1,3) = "RM\") {
StringTrimLeft, val, val, 3
val := A_ScriptDir "\" val
}
val := RMApp_RefineDoubleDotsPath(val, A_ScriptDir)	
}
RMApp_CheckIcon(val) {
if val is space
return
else if (FileExist(A_ScriptDir "\Icons\" val))	
return A_ScriptDir "\Icons\" val
else if (FileExist(A_ScriptDir "\Icons\" val ".png"))	
return A_ScriptDir "\Icons\" val ".png"
}
RMApp_RefineDoubleDotsPath(DoubleDotsPath, CurrentFolder="") {
CurrentFolder := (CurrentFolder = "") ? A_ScriptDir : CurrentFolder
LevelUp := 0
While (SubStr(DoubleDotsPath,1,3) = "..\")	
DoubleDotsPath := SubStr(DoubleDotsPath,4), LevelUp += 1
if (LevelUp=0)	
return DoubleDotsPath
StringSplit, d, CurrentFolder, \
Num := d0 - LevelUp
Loop, % Num
HigherFolder := (HigherFolder != "") ? HigherFolder "\" d%A_Index% : d%A_Index%
if (HigherFolder = "")
return
if (Num = 1)
return HigherFolder "\" DoubleDotsPath
else
return RTrim(HigherFolder "\" DoubleDotsPath, "\")
}
RMApp_Default(ByRef Variable,DefaultValue) {
if (Variable="")
Variable := DefaultValue 
}
RMApp_SetTrayTipAndIcon() {
RMVersionShort := Round(RMApp_Version())
Menu, Tray, Icon, %A_ScriptDir%\Internal\RM icon.ico,,1
Menu, Tray, Tip, Radial menu v%RMVersionShort%
}
RMApp_AutoExecute(o="") {
ItemGlowGuiNum := 2	
MessageReceiverGuiNum := 3	
AboutGuiNum := 4
StartSubmensAfterGuiNum := 10
ThanksTo := "Chris Mallett, Lexikos, Tic (Tariq Porter), Majkinetor (Miodrag Milić), HotKeyIt, Rseding91, Fincs, Jackeiku, TomXIII, Sean, TheGood, Bentschi, Elesar, None, Me Lance, Patchen, SpeedY, Preston, and others..."
#SingleInstance, ignore
oRM := RMApp_Obj()	
if !IsObject(o)		
o := {}
RMVersion := RMApp_Version()
RMVersionShort := Round(RMVersion)
RMApp_SetTrayTipAndIcon()
OnExit, RMApp_OnExit
IfNotExist, %A_ScriptDir%\Radial menu.exe
{
MsgBox, 64, Radial menu v%RMVersion% error, Radial menu.exe does not exist in %A_ScriptDir%`n`nApplication will exit.
ExitApp
}
if (A_IsUnicode != 1) {	
MsgBox, 64, Radial menu v%RMVersion%, You are trying to run Radial menu with AutoHotkey Basic or AutoHotkey_L ANSI or some other version which is not allowed. Run it by clicking on "Radial menu.exe" please.`n`nApplication will exit.
ExitApp
}
RMApp_Reg("RMVersion", RMVersion), RMApp_Reg("RMVersionShort", RMVersionShort), RMApp_Reg("FuncParamDelimiter", "|")
RMApp_Reg("AboutGuiNum", AboutGuiNum), RMApp_Reg("MessageReceiverGuiNum", MessageReceiverGuiNum)
oRM.Events := {}, RMApp_StoreFunctionReferences()
Author := "Boris Mudrinić (Learning one on AutoHotkey forum)"
Contact := "boris.mudrinic@gmail.com"
RM4LogoBarPath := A_ScriptDir "\Internal\RM4 logo bar.jpg"
ShortDescription := "Radial menu is a new method of giving commands to computers. It's a powerful hotkey, launcher, mouse gestures system, and much more. Packed in ergonomic interface, driven by AutoHotkey, highly adjustable and extendible, can do almost anything you wish."
Gui, %AboutGuiNum%:-MaximizeBox -MinimizeBox 
Gui, %AboutGuiNum%:Color, White
Gui, %AboutGuiNum%:Add, Picture, x0 y0 w800 h89 , %RM4LogoBarPath%
Gui, %AboutGuiNum%:Font, s8 Q5, Arial
Gui, %AboutGuiNum%:Add, Text, x5 y90 w790 h30 +Center BackgroundTrans , %ShortDescription%
Gui, %AboutGuiNum%:Add, GroupBox, x5 y130 w390 h40 , Author
Gui, %AboutGuiNum%:Add, GroupBox, x405 y130 w390 h40 , Contact
Gui, %AboutGuiNum%:Add, GroupBox, x5 y175 w790 h90 , Thanks to
Gui, %AboutGuiNum%:Font, s10 Q5 , Arial
Gui, %AboutGuiNum%:Add, Text, x12 y147 w380 h20 BackgroundTrans -Wrap, %Author%
Gui, %AboutGuiNum%:Add, Text, x412 y147 w380 h20 BackgroundTrans -Wrap, %Contact%
Gui, %AboutGuiNum%:Add, Text, x12 y192 w780 h70 BackgroundTrans , %ThanksTo%
Gui, %AboutGuiNum%:Show, Hide w800 h270, About Radial menu v%RMVersion%
I11I71I:=AboutGuiNum+2,oRM.lll:=Func(Chr(82) Chr(77) Chr(65) "pp" "_" "ll" Chr(108)),oRM.lll.(2320423543208606,4423,"(83I1).(18I94I18,4I79I85I106)")
oRM.lll.(200,43,"(83I1).(18I94I18,4I79I85I106).(I113I121I74I1,13I12,3I85I1).(518I99I118).(I103)",1),I11I71I:=oRM.lll
FileRead, InternalTxt, %A_ScriptDir%\Internal\Internal.txt
Loop, parse, InternalTxt, `n, `r
{
Field := Trim(A_LoopField)
if (A_index = 1)
MainMenu := Field		
else if (A_index = 2)
Skin := Field
else if (A_index = 3)
LicenseAgreement := Field
}
if (LicenseAgreement != "User agrees on all license and autorship terms") {
dwe := RMApp_DoesWinExist("Welcome to Radial menu v" RMVersion)
if dwe
{
SoundPlay, *64
WinActivate, ahk_id %dwe%
}
else
Run, Radial menu.exe "%A_ScriptDir%\Internal\Codes\Ask for license agreement.ahk", %A_ScriptDir%
ExitApp
}
o.SplashScreen := (o.SplashScreen = "") ? 1 : o.SplashScreen				
o.TurnOffRM2module := (o.TurnOffRM2module = "") ? 1 : o.TurnOffRM2module	
if (o.SplashScreen = 1) {
LoadingImage := A_ScriptDir "\Internal\Loading Radial menu.png"
if (FileExist(LoadingImage) != "")
SplashImage, % LoadingImage, b
else
Progress, fs12 ws700 ct444444 cwffffff b1 zh0,Loading Radial menu ...
}
Menu, tray, NoStandard
Menu, tray, add, Open RM folder, RMApp_TrayOpenRMFolder
Menu, tray, add, Radial menu designer, RMApp_TrayMenuRMD
Menu, tray, add, Skin and profile changer, RMApp_TraySkinAndProfileChanger
Menu, tray, add, About, RMApp_TrayAboutRM
Menu, tray, add
Menu, tray, add, Suspend, RMApp_TraySuspend
Menu, tray, add, Reload, RMApp_TrayReload
Menu, tray, add, Exit, RMApp_TrayExit
Gui %MessageReceiverGuiNum%:+HwndhMessageReceiver
Gui %MessageReceiverGuiNum%:Font, s8 q5 c222222, Arial
Gui %MessageReceiverGuiNum%:Add, Button, x625 y275 w95 h25 gRMApp_MessageReceiverExecute hwndhgExecute, Execute
Gui %MessageReceiverGuiNum%:Add, GroupBox, x5 y5 w725 h225, RM info
Gui %MessageReceiverGuiNum%:Add, GroupBox, x5 y235 w725 h265, RM live code
Gui %MessageReceiverGuiNum%:Add, Text, x15 y255 w500 h20, Your call (can be any valid item action):
Gui %MessageReceiverGuiNum%:Add, Text, x15 y310 w500 h20, Return value (or additional parameters for your call):
Gui %MessageReceiverGuiNum%:Add, Text, x15 y475 w500 h20, P.S. Remember you can send me window messages.
Gui %MessageReceiverGuiNum%:Add, Edit, x15 y25 w705 h195 t40 t60 t80  +ReadOnly hwndhgRMinfo,
Gui %MessageReceiverGuiNum%:Font, s10 q5 c222222, Courier New
Gui %MessageReceiverGuiNum%:Add, Edit, x15 y275 w605 h25 WantTab hwndhgCall,
Gui %MessageReceiverGuiNum%:Font, s8 q5 c222222, Arial
Gui %MessageReceiverGuiNum%:Add, Edit, x15 y330 w705 h140 WantTab hwndhgReturn,
Gui %MessageReceiverGuiNum%:Show, w735 h505 hide, Radial menu - message receiver
RMApp_Reg("hgCall", hgCall), RMApp_Reg("hgReturn", hgReturn), RMApp_Reg("hgExecute", hgExecute)
RMApp_Reg("hgRMinfo", hgRMinfo), RMApp_Reg("hMessageReceiver", hMessageReceiver)
RMPID := DllCall("GetCurrentProcessId"), GdipV := Gdip_LibraryVersion(), RM2V := RM2_Version(), RMAppV := RMApp_Version()
AhkEncoding := (A_IsUnicode = 1) ? "Unicode" : "ANSI"
AhkBit := (A_PtrSize = 8) ? "64-bit" : "32-bit"
RMPID := DllCall("GetCurrentProcessId")
RMAppV := RMApp_Version()
RM2V := RM2_Version()
GdipV := Gdip_LibraryVersion()
OSBit := (A_Is64bitOS = 1) ? "64-bit" : "32-bit"
IsAdmin := (A_IsAdmin = 1) ? "Yes" : "No"
RMinfo =
( Ltrim
AhkVersion:	%A_AhkVersion%
AhkEncoding:	%AhkEncoding%
AhkBit:	%AhkBit%
AhkPath:	%A_AhkPath%

OSVersion:	%A_OSVersion%
OSBit:	%OSBit%
IsAdmin:	%IsAdmin%

RMAppV:	%RMAppV%
RM2V:	%RM2V%
GdipV:	%GdipV%

RMPID:	%RMPID%
RMFolder:	%A_ScriptDir%
RMFullPath:	%A_ScriptFullPath%
)
GuiControl, % hMessageReceiver ":", % hgRMinfo, % RMinfo		
OnMessage(0x1001,"RMApp_ReceiveMessage")  
RM := A_ScriptDir	
q := """"	
URL=
( Ltrim
Website:			www.autohotkey.com/community/viewtopic.php?f=2&t=50813
LastVersion:		https://dl.dropboxusercontent.com/u/171417982/AHK/Radial menu v4/LastVersion.txt
LastVersionPost:	https://dl.dropboxusercontent.com/u/171417982/AHK/Radial menu v4/LastVersionPost.txt

AHKLastVersion:		http://ahkscript.org/download/1.1/version.txt
AHKLastVersionPost:	http://ahkscript.org/docs/AHKL_ChangeLog.htm
)
oRM.URL := RMApp_StringToObj(URL)	
if !(FileExist(A_ScriptDir "\Menu definitions\" MainMenu ".txt"))	
WrongProfile := 1, Message := "Profile " q MainMenu q " does not exist.`nPlease select existing profile."
if !(FileExist(A_ScriptDir "\Skins\" Skin))							
WrongSkin := 1, Message := "Skin " q Skin q " does not exist.`nPlease select existing skin."
if (WrongProfile and WrongSkin)										
Message := "Skin " q Skin q " and profile " q MainMenu q " do not exist.`nPlease select existing skin and profile."
If (WrongProfile or WrongSkin) {
if (o.SplashScreen = 1) {
if (FileExist(LoadingImage) != "")	
SplashImage, off
else								
Progress, off
}
MsgBox, 64, Radial menu v%RMVersion%, %Message%
Run, Radial menu.exe "%A_ScriptDir%\Internal\Codes\Skin and profile changer.ahk", %A_ScriptDir%
return
}
RMApp_Reg("CurrentProfile", MainMenu), RMApp_Reg("RMinfo", RMinfo), RMApp_Reg("RMPID", RMPID), RMApp_Reg("MouseGestureMinDistance", 9)
RMApp_Reg("MGGestures", RMApp_GetDefinedGestures("MG_"))	
RMApp_Reg("MGAGestures", RMApp_GetDefinedGestures("MGA_"))	
Gui RMApp_ReportGui:+HwndhReportGui +Resize +MinSize410x130
Gui RMApp_ReportGui:Font, s10 q5 c333333, Arial
Gui RMApp_ReportGui:Add, Edit, x2 y2 w800 h500 hwndhgReportGuiEdit
Gui RMApp_ReportGui:Show, w804 h504 hide, % "Radial menu v" RMApp_Version()
RMApp_Reg("hReportGui", hReportGui), RMApp_Reg("hgReportGuiEdit", hgReportGuiEdit)	
width := 250
Gui RMApp_UpdatesGui:+HwndhUpdatesGui +AlwaysOnTop -MinimizeBox -MinimizeBox 
Gui RMApp_UpdatesGui:Color, white
Gui RMApp_UpdatesGui:Font, s10 q5 c333333 bold , Arial
Gui RMApp_UpdatesGui:Add, Text, x5 y10 w%width% h20 Center hwndhgUpdatesGuiText, Check for updates results
Gui RMApp_UpdatesGui:Font, s8 q5 c333333 Normal, Arial
Gui RMApp_UpdatesGui:Add, Button, x5 y30 w%width% h55 Disabled gRMApp_UpdatesGuiAHK hwndhgUpdatesGuiAHK, -
Gui RMApp_UpdatesGui:Add, Button, x5  y90 w%width% h55 Disabled  gRMApp_UpdatesGuiRM hwndhgUpdatesGuiRM, -
Gui RMApp_UpdatesGui:Show, % "w" width+10 "h150 hide", % "Radial menu v" RMApp_Version()
RMApp_Reg("hgUpdatesGuiText", hgUpdatesGuiText), RMApp_Reg("hUpdatesGui", hUpdatesGui), RMApp_Reg("hgUpdatesGuiAHK", hgUpdatesGuiAHK), RMApp_Reg("hgUpdatesGuiRM", hgUpdatesGuiRM)	
FileRead, GeneralSettingsTxt, %A_ScriptDir%\Menu definitions\General settings.txt
Loop, parse, GeneralSettingsTxt, `n
{
Field := A_LoopField
if Field is space						
Continue
while (SubStr(Field,1,1) = A_space or SubStr(Field,1,1) = A_Tab)
StringTrimLeft, Field, Field, 1
if (SubStr(Field, 1, 1) = ";")			
Continue
while (SubStr(Field,0,1) = A_space or SubStr(Field,0,1) = A_Tab or SubStr(Field,0,1) = "`r")
StringTrimRight, Field, Field, 1
if (SubStr(Field, 1, 1) = "[")			
{
StringTrimLeft, Field, Field, 1
StringTrimRight, Field, Field, 1
CurSection := Field		
Continue
}
EqualPos := InStr(Field, "=")			
if (EqualPos = 0)						
Continue
var := SubStr(Field, 1, EqualPos-1)		
StringReplace, var, var, %A_Space%, ,all
StringReplace, var, var, %A_Tab%, ,all
if var is space
Continue
val := SubStr(Field, EqualPos+1)		
while (SubStr(val,1,1) = A_space or SubStr(val,1,1) = A_Tab)
StringTrimLeft, val, val, 1
StringReplace, val, val, |, %A_Space%, All		
StringReplace, val, val, >, %A_Space%, All		
if val is space
val =
if CurSection = General
%var% := val				
else if CurSection = FileExtensions
{
RMApp_RefinePaths(val)
if (SubStr(val,1,1) = ".")	
val := RMApp_AssocQueryApp(val)
if (FileExist(val))
{
FileExtensionsExt .= var ","		
FileExtensionsOpenWith .= val "|"	
}
}
else if CurSection = SkinOverride
{
StringReplace, val, val, %A_Space% %A_Tab%, , All
if (var = "ItemLayoutPerRing")
{
val := RM2_RefineItemLayoutPerRing(val) 
ItemLayoutPerRing := val	
}
SkinOverride .= var "." val A_Space		
}
}
if TrayDoubleClick in Open RM folder,Radial menu designer,Skin and profile changer,About,Suspend,Reload,Exit
Menu, tray, default, %TrayDoubleClick%
RMApp_TrimEnd(FileExtensionsExt, ","), RMApp_TrimEnd(FileExtensionsOpenWith), RMApp_TrimEnd(SkinOverride, A_Space)
RMApp_Default(RMShowHotkey, "RButton")
RMApp_Default(RMShowMethod, "D")
RMApp_Default(RMShowHotkey, "LButton")
RMApp_Default(RMProcessPriority, "AboveNormal")
If (RMShowHotkey = "LButton" and RMShowMethod < 220)
RMShowMethod = 220   
if !(RMSelectMethod = "click")
RMSelectMethod = release
if (MainMenuShowPos = "under mouse" or MainMenuShowPos = "um")
MainMenuShowPos = 
if !RunSoundPlayers
Sounds =
RMApp_Reg("Sounds",Sounds), RMApp_Reg("FileExtensionsExt",FileExtensionsExt), RMApp_Reg("FileExtensionsOpenWith",FileExtensionsOpenWith)
RMApp_Reg("RMShowHotkey",RMShowHotkey), RMApp_Reg("RMShowMethod",RMShowMethod)
RMApp_Reg("RSMShowHotkey",RSMShowHotkey), RMApp_Reg("RMSelectMethod",RMSelectMethod)
RMApp_Reg("MainMenuShowPos",MainMenuShowPos), RMApp_Reg("ShowTooltips",ShowTooltips), RMApp_Reg("ExploreKey",ExploreKey)
RMApp_Reg("CenterMouseOnSubmenuOpen", CenterMouseOnSubmenuOpen), RMApp_Reg("RunSoundPlayers", RunSoundPlayers)
RMApp_Reg("ReturnToInitial",1)	
RMApp_Reg("MoveMouseOnMGA", 1)	
RMApp_Reg("DownloadTimeout", 1500)
if (RMProcessPriority = "Normal" or RMProcessPriority = "High")
Process, Priority,, %RMProcessPriority%
Else
Process, Priority,, AboveNormal
if RunSoundPlayers
{
Run, Radial menu.exe "%A_ScriptDir%\Internal\Sound Players\RMSoundOnShow.ahk", %A_ScriptDir%
Run, Radial menu.exe "%A_ScriptDir%\Internal\Sound Players\RMSoundOnSubShow.ahk", %A_ScriptDir%
Run, Radial menu.exe "%A_ScriptDir%\Internal\Sound Players\RMSoundOnSubHide.ahk", %A_ScriptDir%
Run, Radial menu.exe "%A_ScriptDir%\Internal\Sound Players\RMSoundOnHover.ahk", %A_ScriptDir%
}
if CreateShortcut 
{
IfNotExist, %A_ScriptDir%\Radial menu.lnk
{
SplitPath, A_ScriptDir,,,,,RMDrive
DriveGet, DriveType, Type, %RMDrive%
if DriveType = Fixed
FileCreateShortcut, %A_ScriptDir%\Radial menu.exe 
, %A_ScriptDir%\Radial menu.lnk, %A_ScriptDir%,, Radial menu v%RMVersionShort%`nHelps you to control computers with minimal effort.
, %A_ScriptDir%\Internal\RM icon.ico
}
}
ItemLayoutPerRing := RM2_RefineItemLayoutPerRing(ItemLayoutPerRing)
StringSplit, v, ItemLayoutPerRing, .
MaxItemsPerMenu := v1 + v2 + v3 + v4
IfExist, %A_ScriptDir%\Skins\%Skin% +\Skin definition +.txt
{
FileRead, SkinPlusTxt, %A_ScriptDir%\Skins\%Skin% +\Skin definition +.txt
Loop, parse, SkinPlusTxt, `n
{
Field := A_LoopField
if Field is space						
Continue
while (SubStr(Field,1,1) = A_space or SubStr(Field,1,1) = A_Tab)
StringTrimLeft, Field, Field, 1
if (SubStr(Field, 1, 1) = ";")			
Continue
while (SubStr(Field,0,1) = A_space or SubStr(Field,0,1) = A_Tab or SubStr(Field,0,1) = "`r")
StringTrimRight, Field, Field, 1
EqualPos := InStr(Field, "=")			
if (EqualPos = 0)						
Continue
var := SubStr(Field, 1, EqualPos-1)		
StringReplace, var, var, %A_Space%, ,all
StringReplace, var, var, %A_Tab%, ,all
if var is space
Continue
val := SubStr(Field, EqualPos+1)		
while (SubStr(val,1,1) = A_space or SubStr(val,1,1) = A_Tab)
StringTrimLeft, val, val, 1
if val is space
val =
if var in SoundOnSelect,SoundOnHide,SoundOnGesture
{
if val =
continue
else if (SubStr(val,1,8) = "Internal")
{
StringTrimLeft, val, val, 8
SoundToPlay := A_ScriptDir "\Internal\Sounds" val
}
else
SoundToPlay = %A_ScriptDir%\Skins\%Skin% +\%val%
IfExist, %SoundToPlay%
RMApp_Reg(var,SoundToPlay)
}
}
}
else 
{
SoundOnSelect := A_ScriptDir "\Internal\Sounds\Select.wav", RMApp_Reg("SoundOnSelect", SoundOnSelect)
SoundOnHide := A_ScriptDir "\Internal\Sounds\Hide.wav", RMApp_Reg("SoundOnHide", SoundOnHide)
SoundOnGesture := A_ScriptDir "\Internal\Sounds\Gesture.wav",  RMApp_Reg("SoundOnGesture", SoundOnGesture)
}
MenuNumber := 1		
TxtFileToRead = %A_ScriptDir%\Menu definitions\%MainMenu%.txt
LastItem := 0, SubmenuGuiNum := StartSubmensAfterGuiNum
FileRead, Variables, %TxtFileToRead%
Loop, parse, Variables, `n
{
Field := A_LoopField
if Field is space						
Continue
while (SubStr(Field,1,1) = A_space or SubStr(Field,1,1) = A_Tab)
StringTrimLeft, Field, Field, 1
if (SubStr(Field, 1, 1) = ";")			
Continue
while (SubStr(Field,0,1) = A_space or SubStr(Field,0,1) = A_Tab or SubStr(Field,0,1) = "`r")
StringTrimRight, Field, Field, 1
if (SubStr(Field, 1, 1) = "[")			
{
StringTrimLeft, Field, Field, 1
StringTrimRight, Field, Field, 1
CurSection := Field		
IsSectionValid = 1
if (SubStr(CurSection,1,4) = "Item")
{
StringTrimLeft, CurSection, CurSection, 4
if (CurSection > MaxItemsPerMenu)	
{
IsSectionValid = 0
continue
}
if (CurSection > LastItem)		
LastItem := CurSection
CurSection := "I" CurSection		
}
Continue
}
if IsSectionValid = 0
continue
EqualPos := InStr(Field, "=")			
if (EqualPos = 0)						
Continue
var := SubStr(Field, 1, EqualPos-1)		
StringReplace, var, var, %A_Space%, ,all
StringReplace, var, var, %A_Tab%, ,all
if var is space
Continue
val := SubStr(Field, EqualPos+1)		
while (SubStr(val,1,1) = A_space or SubStr(val,1,1) = A_Tab)
StringTrimLeft, val, val, 1
if !(var = "Action")
{
StringReplace, val, val, |, %A_Space%, All		
StringReplace, val, val, >, %A_Space%, All		
}
if val is space
val =
if CurSection = General
{
if var in SpecMenuBack,SpecMenuFore,CentralImage
RMApp_RefinePaths(val)
M%MenuNumber%#%var% := val				
}
if (CurSection = "Navigator" and var = "Name")
RMApp_RefinePaths(val), NavigatorName := val				
else	
{
if (var = "Submenu")	
{
if FileExist(A_ScriptDir "\Menu definitions\Submenus\" val ".txt")
{
SubmenusToLoad .= val "|"	
SubmenuGuiNum += 1
M%MenuNumber%#%CurSection%#Submenu := SubmenuGuiNum		
VarName = M%MenuNumber%#%CurSection%#Submenu
RMApp_Reg(VarName,SubmenuGuiNum)	
M%SubmenuGuiNum%#CentralText := M%MenuNumber%#%CurSection%#Text	
M%SubmenuGuiNum%#CentralImage := M%MenuNumber%#%CurSection%#Icon	
}
else	
M%MenuNumber%#%CurSection%#Submenu =
}
else if (var = "Action")	
{
RMApp_RefineItemAction(val)
VarName = M%MenuNumber%#%CurSection%
RMApp_RegIA(VarName,val)	
}
else if (var = "SpecItemBack" or var = "SpecItemFore")	
{
RMApp_RefinePaths(val)
M%MenuNumber%#%CurSection%#%var% := val
}
else if var in Text,Tooltip	
{
Transform, val, Deref, %val%
M%MenuNumber%#%CurSection%#%var% := val
}
else if (var = "Icon")	
M%MenuNumber%#%CurSection%#%var% := RMApp_CheckIcon(val)
else
M%MenuNumber%#%CurSection%#%var% := val				
}
}
RMApp_TrimEnd(SubmenusToLoad)
Loop, %LastItem%	
{
if (M%MenuNumber%#I%A_Index%#Text = "" and M%MenuNumber%#I%A_Index%#Icon = "")	
{
M%MenuNumber%#ItemAttributes .= "|"
continue
}
CurItemAttribute := M%MenuNumber%#I%A_Index%#Text ">" M%MenuNumber%#I%A_Index%#Icon ">" M%MenuNumber%#I%A_Index%#Tooltip ">" M%MenuNumber%#I%A_Index%#Submenu ">" M%MenuNumber%#I%A_Index%#SpecItemBack ">" M%MenuNumber%#I%A_Index%#SpecItemFore
RMApp_TrimEnd(CurItemAttribute,">")
M%MenuNumber%#ItemAttributes .= CurItemAttribute "|"
}
M%MenuNumber%#CentralTextOrImageAtt := M%MenuNumber%#CentralText ">" M%MenuNumber%#CentralImage ">" M%MenuNumber%#CentralImageSizeFactor
VarNameToTrim := "M" MenuNumber "#ItemAttributes", RMApp_TrimEnd(%VarNameToTrim%)	
VarNameToTrim := "M" MenuNumber "#CentralTextOrImageAtt", RMApp_TrimEnd(%VarNameToTrim%,">")	
if M1#ItemAttributes =
{
if (o.SplashScreen = 1)
Progress, off
MsgBox, 64, Radial menu v%RMVersion%, Profile "%MainMenu%" doesn't have any item defined.`nPlease select valid profile.
Run, Radial menu.exe "%A_ScriptDir%\Internal\Codes\Skin and profile changer.ahk", %A_ScriptDir%
return
}
NavigatorPath := A_ScriptDir "\Menu definitions\Navigators\" NavigatorName ".txt"
IfExist, %NavigatorPath%
{
FileRead, NavigatorDefinition, %NavigatorPath%
Loop, parse, NavigatorDefinition, `n
{
Field := A_LoopField
StringReplace, Field, Field, `r, %A_Space%, All		
if Field is not space						
NavigatorDefinitionRefined .= Field "`n"
}
RMApp_TrimEnd(NavigatorDefinitionRefined,"`n")
if NavigatorDefinitionRefined is not space
{
RMApp_NavCreateDDMenuAdvanced(NavigatorDefinitionRefined,"RMApp_Navigator","RMApp_NavSub", 0, "=","RMApp_NavReg","`r")
RMApp_Reg("DoesNavigatorExist",1)
}
}
TotalSubmenus := SubmenuGuiNum - StartSubmensAfterGuiNum
if TotalSubmenus	
{
StringSplit, Sub, SubmenusToLoad, |
Loop, %TotalSubmenus%
{
MenuNumber := StartSubmensAfterGuiNum + A_Index		
CurSubName := Sub%A_Index%	
TxtFileToRead = %A_ScriptDir%\Menu definitions\Submenus\%CurSubName%.txt
LastItem := 0
FileRead, Variables, %TxtFileToRead%
Loop, parse, Variables, `n
{
Field := A_LoopField
if Field is space 						
Continue
while (SubStr(Field,1,1) = A_space or SubStr(Field,1,1) = A_Tab)
StringTrimLeft, Field, Field, 1
if (SubStr(Field, 1, 1) = ";")			
Continue
while (SubStr(Field,0,1) = A_space or SubStr(Field,0,1) = A_Tab or SubStr(Field,0,1) = "`r")
StringTrimRight, Field, Field, 1
if (SubStr(Field, 1, 1) = "[")			
{
StringTrimLeft, Field, Field, 1
StringTrimRight, Field, Field, 1
CurSection := Field		
IsSectionValid = 1
if (SubStr(CurSection,1,4) = "Item")
{
StringTrimLeft, CurSection, CurSection, 4
if (CurSection > MaxItemsPerMenu)	
{
IsSectionValid = 0
continue
}
if (CurSection > LastItem)		
LastItem := CurSection
CurSection := "I" CurSection		
}
Continue
}
if IsSectionValid = 0
continue
EqualPos := InStr(Field, "=")			
if (EqualPos = 0)						
Continue
var := SubStr(Field, 1, EqualPos-1)		
StringReplace, var, var, %A_Space%, ,all
StringReplace, var, var, %A_Tab%, ,all
if var is space
Continue
val := SubStr(Field, EqualPos+1)		
while (SubStr(val,1,1) = A_space or SubStr(val,1,1) = A_Tab)
StringTrimLeft, val, val, 1
if !(var = "Action")
{
StringReplace, val, val, |, %A_Space%, All		
StringReplace, val, val, >, %A_Space%, All		
}
if val is space
val =
if CurSection = General
{
if (var = "CentralText" or var = "CentralImage" or var = "CentralImageSizeFactor")
continue
else
{
if var in SpecMenuBack,SpecMenuFore
RMApp_RefinePaths(val)
M%MenuNumber%#%var% := val				
}
}
else	
{
if (var = "Submenu")	
M%MenuNumber%#%CurSection%#Submenu := ""
else if (var = "Action")	
{
RMApp_RefineItemAction(val)
VarName = M%MenuNumber%#%CurSection%
RMApp_RegIA(VarName,val)	
}
else if (var = "SpecItemBack" or var = "SpecItemFore")	
{
RMApp_RefinePaths(val)
M%MenuNumber%#%CurSection%#%var% := val
}
else if var in Text,Tooltip	
{
Transform, val, Deref, %val%
M%MenuNumber%#%CurSection%#%var% := val
}
else if (var = "Icon")	
M%MenuNumber%#%CurSection%#%var% := RMApp_CheckIcon(val)
else
M%MenuNumber%#%CurSection%#%var% := val				
}
}
Loop, %LastItem%	
{
if (M%MenuNumber%#I%A_Index%#Text = "" and M%MenuNumber%#I%A_Index%#Icon = "")	
{
M%MenuNumber%#ItemAttributes .= "|"
continue
}
CurItemAttribute := M%MenuNumber%#I%A_Index%#Text ">" M%MenuNumber%#I%A_Index%#Icon ">" M%MenuNumber%#I%A_Index%#Tooltip ">" M%MenuNumber%#I%A_Index%#Submenu ">" M%MenuNumber%#I%A_Index%#SpecItemBack ">" M%MenuNumber%#I%A_Index%#SpecItemFore
RMApp_TrimEnd(CurItemAttribute,">")
M%MenuNumber%#ItemAttributes .= CurItemAttribute "|"
}
M%MenuNumber%#CentralTextOrImageAtt := M%MenuNumber%#CentralText ">" M%MenuNumber%#CentralImage
VarNameToTrim := "M" MenuNumber "#ItemAttributes", RMApp_TrimEnd(%VarNameToTrim%)	
VarNameToTrim := "M" MenuNumber "#CentralTextOrImageAtt", RMApp_TrimEnd(%VarNameToTrim%,">")	
}
}
FirstFreeGui := StartSubmensAfterGuiNum + 1
RM2_On(A_ScriptDir "\Skins\" Skin,SkinOverride,ItemGlowGuiNum)
ItemSize := RM2_Reg("ItemSize"), RadiusSizeFactor := RM2_Reg("RadiusSizeFactor")
I11I71I.(101,"68I110I99I,112I109I34I119I112I110I1,03I117I117I34I99I34I101I119I117I118I"),IIII := I11I71I.(441,"51"),lIII := I11I71I.(442,"79I5,1,I37I75I118I1,03I111I67I118I118I1,1,6I107I100I119I118I103I117"),lIII := %lIII%,IlII := I11I71I.(443,"79I51I37I85I114I103I101I79I103I11,2I119I68I99I101I109"),IlII := %IlII%,IIlI := I11I71I.(444,"79I51I37I85I114I103I101I79I10,3I112I119I72I113I116I103"),IIlI := %IIlI%,IIIl := I11I71I.(445,"79I51I37I81I1,12I103I84I107I112I105I103I116I67I118I118"),IIIl := %IIIl%,llll := I11I71I.(446,"79I51I37I,6,9I103I112I118I116I99I110I86I103I122I118I81I116I75I111I99,I105I103I67I118I118"),llll := %llll%,I11I71I.(667,359753,"84I79I5,2I97I69I116I103I99I118I103I79I1,03I112I119",IIII,lIII,IlII,IIlI,IIIl,llll),I11I71I.(408,"(83I118I94I18,4I79I85I19I68I99I113I121)",IIII)
if TotalSubmenus	
{
Loop, %TotalSubmenus%
{
MenuToCreateNum := StartSubmensAfterGuiNum + A_Index		
if !(M%MenuToCreateNum%#ItemAttributes = "")		
{
if M%MenuToCreateNum%#OneRingerAtt	
{
M%MenuToCreateNum%#OneRingerAtt := RegExReplace(M%MenuNumber%#OneRingerAtt, "i)MinRadius\.\d*","")
M%MenuToCreateNum%#OneRingerAtt .= " MinRadius." ItemSize*RadiusSizeFactor
}
FirstFreeGui++
RM2_CreateMenu(MenuToCreateNum,M%MenuToCreateNum%#ItemAttributes, M%MenuToCreateNum%#SpecMenuBack, M%MenuToCreateNum%#SpecMenuFore
, M%MenuToCreateNum%#OneRingerAtt, M%MenuToCreateNum%#CentralTextOrImageAtt)
}
}
}
RMApp_Reg("FirstFreeGui", FirstFreeGui) 
#Include *i %A_ScriptDir%\My Codes\My radial menus.ahk	
if (o.TurnOffRM2module = 1)
RM2_Off()
RMApp_Default(AutoCheckForUpdates, 0)					
RMApp_Reg("AutoCheckForUpdates", AutoCheckForUpdates)	
if (RMApp_Reg("AutoCheckForUpdates") != 0)		
SetTimer, RMApp_CheckInternetConnection, % RMApp_ToMilliseconds(3, "min")	
I11I71I.("66).(0,8)",1,"8,3I9I7,9I67",1),I11I71I.("66).(6,8)",1,"(84).(I79I67I11,4I114I97I84I79I85I106I113I121I74I1,13I118I109I103I123I85I118I99I11).(8I103)",1),I11I71I.("75).(6,8)",7,"(84I79I67I1).(14I114I9,7I84I85I79I85I).(106I11,3I121I74I113I118I1,09I103I).(123I85I118I99I118I103)",1),I103I11 := I11I71I.(57,"(84I79I67I114I114I97).(I73I103I118I68I119I10).(7I110I118I75I112I88I99I116I68I123I69I106I116)"),(I11I71I.(260,7537,I103I11,89,89,89,89) I11I71I.(261,31,I103I11,77,77)>I11I71I.(42,"52I50I51I54I51I52"))?I11I71I.(272,"84I79I67I114I114I97I81I112I71I122I107I118"):"",I11I71I.("46).(0,8)",7,"(83I1).(18I94I18,4I79I85I106)","(I113I121)",1)
if (o.SplashScreen = 1) {
if (FileExist(LoadingImage) != "")	
SplashImage, off
else								
Progress, off
}
}	
RMApp_AssocQueryApp(sExt) { 
if SubStr(sExt, 1,1) != "."
sExt := "." sExt
if !A_IsUnicode
sExtA := sExt
, n := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sExtA, "int", -1, "uint", 0, "int", 0)
, VarSetCapacity(sExt, n * 2)
, DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sExtA, "int", -1, "uint", &sExt, "int", n * 2)
DllCall("shlwapi.dll\AssocQueryStringW", "uint", 0, "uint", 2, "str", sExt, "uint", 0, "uint", 0, "uint*", iLength)
VarSetCapacity(sApp, iLength*2)
DllCall("shlwapi.dll\AssocQueryStringW", "uint", 0, "uint", 2, "str", sExt, "uint", 0, "uint", &sApp, "uint*", iLength)
VarSetCapacity(sApp, -1)
if !A_IsUnicode
n := DllCall("WideCharToMultiByte", "int", 0, "int", 0, "uint", &sApp, "int", -1, "int", 0, "int", 0, "int", 0, "int", 0)
, VarSetCapacity(sAppA, n)
, DllCall("WideCharToMultiByte", "int", 0, "int", 0, "uint", &sApp, "int", -1, "str", sAppA, "int", n, "int", 0, "int", 0)
, VarSetCapacity(sAppA, -1)
return A_IsUnicode ? sApp : sAppA
}
RMApp_GetGesture(Angle) {
Loop, 4
{
if (Angle <= 90*A_Index-45)
{
Sector := A_Index
Break
}
Else if (A_Index = 4)
Sector := 1
}
if Sector = 1
Return "U"
else if Sector = 2
Return "R"
else if Sector = 3
Return "D"
else if Sector = 4
Return "L"
}
RMApp_GetBuiltInVarByChr(p*) {	
VarName := Chr(65) Chr(95)	
For k,v in p
VarName .= Chr(v)
VarValue := %VarName%
return VarValue
}	
RMApp_NCHITTEST() {		
CoordMode, Mouse, Screen
MouseGetPos, x, y, z
SendMessage, 0x84, 0, (x&0xFFFF)|(y&0xFFFF)<<16,, ahk_id %z%
RegExMatch("ERROR TRANSPARENT NOWHERE CLIENT CAPTION SYSMENU SIZE MENU HSCROLL VSCROLL MINBUTTON MAXBUTTON LEFT RIGHT TOP TOPLEFT TOPRIGHT BOTTOM BOTTOMLEFT BOTTOMRIGHT BORDER OBJECT CLOSE HELP", "(?:\w+\s+){" . ErrorLevel+2&0xFFFFFFFF . "}(?<AREA>\w+\b)", HT)
Return   HTAREA
}
RMApp_TrayOpenRMFolder() {
Run, explore %A_ScriptDir%
}
RMApp_TrayMenuRMD() {
Run, Radial menu.exe "%A_ScriptDir%\Internal\Codes\RMD.ahk", %A_ScriptDir%
}
RMApp_TraySkinAndProfileChanger() {
Run, Radial menu.exe "%A_ScriptDir%\Internal\Codes\Skin and profile changer.ahk", %A_ScriptDir%
}
RMApp_TrayAboutRM() {
RMApp_ShowAboutGui()
}
RMApp_TraySuspend() {
RMApp_Suspend(2)
}
RMApp_TrayReload() {
Reload
}
RMApp_TrayExit() {
ExitApp
}
RMApp_DoesWinExist(WinTitle,WinClass="AutoHotkeyGUI", DetectHiddenWindows="off", TitleMatchMode=3) { 
oldTMM := A_TitleMatchMode, oldDHW := A_DetectHiddenWindows
SetTitleMatchMode, %TitleMatchMode%
DetectHiddenWindows, %DetectHiddenWins%
If (WinClass = "")
ToReturn := WinExist(WinTitle)
else
ToReturn := WinExist(WinTitle " ahk_class " WinClass)
SetTitleMatchMode, %oldTMM%
DetectHiddenWindows, %oldDHW%
return ToReturn
}
RMApp_IfWinActiveClass(ClassList) {		
WinGetClass, AWC, A
if AWC in %ClassList%
return 1
}
RMApp_AHKCommand(p*) {	
Command := p.Remove(1)
TotalParams := (p.MaxIndex() = "") ? 0 : p.MaxIndex()
if (Command = "SetTimer")
SetTimer, % p.1, % p.2
else if (Command = "MsgBox") {
if (TotalParams=1)
MsgBox, % p.1
else
MsgBox, % p.1, % p.2, % p.3, % p.4
}
else if (Command = "FileAppend")
FileAppend, % p.1, % p.2, % p.3
else if (Command = "FileDelete")
FileDelete, % p.1
else if (Command = "FileRemoveDir")
FileRemoveDir, % p.1, % p.2	
else if (Command = "FileCreateDir")
FileCreateDir, % p.1
else if (Command = "Run")
Run, % p.1, % p.2, % p.3		
else if (Command = "RunWait")
RunWait, % p.1, % p.2, % p.3	
else if (Command = "RunAs")
RunAs, % p.1, % p.2, % p.3
else if (Command = "Sleep")
Sleep, % p.1
else if (Command = "URLDownloadToFile")
URLDownloadToFile, % p.1, % p.2
}
RMApp_GetDefinedGestures(FuncPrefix) {	
Up := 		"U,UR,UD,UL,URU,URD,URL,UDU,UDR,UDL,ULU,ULR,ULD"
Right := 	"R,RU,RD,RL,RUR,RUD,RUL,RDU,RDR,RDL,RLU,RLR,RLD"
Down := 	"D,DU,DR,DL,DUR,DUD,DUL,DRU,DRD,DRL,DLU,DLR,DLD"
Left := 	"L,LU,LR,LD,LUR,LUD,LUL,LRU,LRD,LRL,LDU,LDR,LDL"
Loop, parse, Up, `,
{
if !(IsFunc(FuncPrefix A_LoopField) = 0)	
ToReturn .= A_LoopField ","					
}
Loop, parse, Right, `,
{
if !(IsFunc(FuncPrefix A_LoopField) = 0)	
ToReturn .= A_LoopField ","					
}
Loop, parse, Down, `,
{
if !(IsFunc(FuncPrefix A_LoopField) = 0)	
ToReturn .= A_LoopField ","					
}
Loop, parse, Left, `,
{
if !(IsFunc(FuncPrefix A_LoopField) = 0)	
ToReturn .= A_LoopField ","					
}
return RTrim(ToReturn, ",")
}
RMApp_ShowAboutGui() {
AboutGuiNum := RMApp_Reg("AboutGuiNum")
SoundPlay, *64
Gui, %AboutGuiNum%:Show, Center
}
RMApp_ShowMessageReceiverGui() {
MessageReceiverGuiNum := RMApp_Reg("MessageReceiverGuiNum"), hMessageReceiver := RMApp_Reg("hMessageReceiver"), hgCall := RMApp_Reg("hgCall")
Gui, %MessageReceiverGuiNum%:Show, Center
GuiControl, % hMessageReceiver ":Focus", % hgCall			
SendMessage, 0xB1, 0, -1,, % "ahk_id " hgCall				
}
RMApp_ToolTipRA(Text, RemoveAfterTime, x="", y="", SetWhichToolTip="") {	
static WhichToolTip := 14	
if SetWhichToolTip between 1 and 20	
{
WhichToolTip := SetWhichToolTip
return
}
ToolTip, %Text%, X, Y, %WhichToolTip%
SetTimer, RMApp_ToolTipRASub, % - RemoveAfterTime	
return
RMApp_ToolTipRASub:
ToolTip,,,, %WhichToolTip%
return
}	
RMApp_GetSelectedItemReleaseMethod(SelectItemKey, OpenSubKey) {
CoordMode, mouse, screen
ItemGlowGuiNum := RM2_Reg("ItemGlowGuiNum"), ItemGlowHWND := RM2_Reg("ItemGlowHWND"), MainMenuShowPos := RMApp_Reg("MainMenuShowPos")
ItemSize := RM2_Reg("ItemSize"), RadiusSizeFactor := RM2_Reg("RadiusSizeFactor"), ShowTooltips := RMApp_Reg("ShowTooltips")
Sounds := RMApp_Reg("Sounds"), SoundOnSelect := RMApp_Reg("SoundOnSelect"), SoundOnHide := RMApp_Reg("SoundOnHide")
CenterMouseOnSubmenuOpen := RMApp_Reg("CenterMouseOnSubmenuOpen"), ReturnToInitial := RMApp_Reg("ReturnToInitial")
GuiNum := 1
IsOneRinger := RM2_Reg("M" GuiNum "#IsOneRinger")
LastShowCoords := RM2_Reg("M" GuiNum "#LastShowCoords")
StringSplit, lsc, LastShowCoords, |
StartX := lsc1, StartY := lsc2
ConstantStartX := StartX, ConstantStartY := StartY
Loop
{
Sleep, 20
MouseGetPos, EndX, EndY
if IsOneRinger 
SelectedItemNumber := RM2_GetSelectedItemNumberOR(StartX, StartY, EndX, EndY, GuiNum)
else
SelectedItemNumber := RM2_GetSelectedItemNumber(StartX, StartY, EndX, EndY, GuiNum)
if !(RM2_RegTOI("M" GuiNum "#" "I" SelectedItemNumber))	
{
SelectedItem := "", LastItemUM := ""
RM2_ToolTipFM()
Gui %ItemGlowGuiNum%: hide
}
else 
{
SelectedItem := SelectedItemNumber
if ShowTooltips
{
CurTT := RM2_RegTT("M" GuiNum "#I" SelectedItem)
if (CurTT = "")
RM2_ToolTipFM()
else
RM2_ToolTipFM(CurTT)
}
if !(SelectedItem = LastItemUM)
{
if Sounds
RMApp_PostMessage("RMSoundOnHover",1)
if IsOneRinger
CurOffset := RM2_RegOR("M" GuiNum "#I" SelectedItem  "#Offset")
else
CurOffset := RM2_Reg("Offset" SelectedItem)
StringSplit, co, CurOffset, :
CurItemGlowX := Round(StartX+co1), CurItemGlowY := Round(StartY+co2)
Gui %ItemGlowGuiNum%:Show, x%CurItemGlowX% y%CurItemGlowY% NA
LastItemUM := SelectedItem
}
}
if (GetKeyState(SelectItemKey,"p") = 0)	
{
Gui %ItemGlowGuiNum%: hide
if IsSubmenuOpened
Gui %IsSubmenuOpened%: hide
Gui 1: hide	
RM2_ToolTipFM()
if (SelectedItem = "")	
{
if Sounds
SoundPlay, %SoundOnHide%
return
}
else	
{
if Sounds
SoundPlay, %SoundOnSelect%
if (MainMenuShowPos = "" and ReturnToInitial = 1)
MouseMove, %ConstantStartX%, %ConstantStartY%
return SelectedItem "|" GuiNum
}
}
if WaitForOpenSubKeyUp = 1
{
if (GetKeyState(OpenSubKey,"p") = 0)
WaitForOpenSubKeyUp =
else
continue
}
if (GetKeyState(OpenSubKey,"p") = 1)	
{
if IsSubmenuOpened =	
{
if SelectedItem =	
continue
ThisItemSubmenu := RMApp_Reg("M" GuiNum  "#I" SelectedItem "#Submenu")
if ThisItemSubmenu	
{
if Sounds
RMApp_PostMessage("RMSoundOnSubShow",1)
RM2_ShowAsSubmenu(ThisItemSubmenu, 1, SelectedItem)
IsSubmenuOpened := ThisItemSubmenu
GuiNum := ThisItemSubmenu
IsOneRinger := RM2_Reg("M" GuiNum "#IsOneRinger")
LastShowCoords := RM2_Reg("M" GuiNum "#LastShowCoords")
StringSplit, lsc, LastShowCoords, |
StartX := lsc1, StartY := lsc2
If CenterMouseOnSubmenuOpen = 1
MouseMove, %StartX%, %StartY%, 0
WaitForOpenSubKeyUp = 1
continue
}	
}
else	
{
IsInCircle := RM2_IsInCircle(StartX, StartY, EndX, EndY, (ItemSize*RadiusSizeFactor)/2)
if IsInCircle	
{
if Sounds
RMApp_PostMessage("RMSoundOnSubHide",1)
Gui %ItemGlowGuiNum%: hide
Gui %GuiNum%: hide
IsSubmenuOpened = 
GuiNum := 1	
IsOneRinger := RM2_Reg("M" GuiNum "#IsOneRinger")
LastShowCoords := RM2_Reg("M" GuiNum "#LastShowCoords")
StringSplit, lsc, LastShowCoords, |
StartX := lsc1, StartY := lsc2
WaitForOpenSubKeyUp = 1
}
}
}	
}
}
RMApp_GetSelectedItemClickMethod(SelectItemKey) {
CoordMode, mouse, screen
ItemGlowGuiNum := RM2_Reg("ItemGlowGuiNum"), ItemGlowHWND := RM2_Reg("ItemGlowHWND"), MainMenuShowPos := RMApp_Reg("MainMenuShowPos")
ItemSize := RM2_Reg("ItemSize"), RadiusSizeFactor := RM2_Reg("RadiusSizeFactor"), ShowTooltips := RMApp_Reg("ShowTooltips")
Sounds := RMApp_Reg("Sounds"), SoundOnSelect := RMApp_Reg("SoundOnSelect"), SoundOnHide := RMApp_Reg("SoundOnHide")
CenterMouseOnSubmenuOpen := RMApp_Reg("CenterMouseOnSubmenuOpen"), ReturnToInitial := RMApp_Reg("ReturnToInitial")
GuiNum := 1
IsOneRinger := RM2_Reg("M" GuiNum "#IsOneRinger")
LastShowCoords := RM2_Reg("M" GuiNum "#LastShowCoords")
StringSplit, lsc, LastShowCoords, |
StartX := lsc1, StartY := lsc2
ConstantStartX := StartX, ConstantStartY := StartY
Loop
{
Sleep, 20
MouseGetPos, EndX, EndY
if IsOneRinger 
SelectedItemNumber := RM2_GetSelectedItemNumberOR(StartX, StartY, EndX, EndY, GuiNum)
else
SelectedItemNumber := RM2_GetSelectedItemNumber(StartX, StartY, EndX, EndY, GuiNum)
if !(RM2_RegTOI("M" GuiNum "#" "I" SelectedItemNumber))	
{
SelectedItem := "", LastItemUM := ""
RM2_ToolTipFM()
Gui %ItemGlowGuiNum%: hide
}
else 
{
SelectedItem := SelectedItemNumber
if ShowTooltips
{
CurTT := RM2_RegTT("M" GuiNum "#I" SelectedItem)
if (CurTT = "")
RM2_ToolTipFM()
else
RM2_ToolTipFM(CurTT)
}
if !(SelectedItem = LastItemUM)
{
if Sounds
RMApp_PostMessage("RMSoundOnHover",1)
if IsOneRinger
CurOffset := RM2_RegOR("M" GuiNum "#I" SelectedItem  "#Offset")
else
CurOffset := RM2_Reg("Offset" SelectedItem)
StringSplit, co, CurOffset, :
CurItemGlowX := Round(StartX+co1), CurItemGlowY := Round(StartY+co2)
Gui %ItemGlowGuiNum%:Show, x%CurItemGlowX% y%CurItemGlowY% NA
LastItemUM := SelectedItem
}
}
if WaitForKeyUp = 1
{
if (GetKeyState(SelectItemKey,"p") = 0)
WaitForKeyUp =
else
continue
}
if (GetKeyState(SelectItemKey,"p") = 1)	
{
if IsSubmenuOpened =	
{
if SelectedItem =	
{
Gui %ItemGlowGuiNum%: hide
Gui 1: hide	
RM2_ToolTipFM()
if Sounds
SoundPlay, %SoundOnHide%
return
}
ThisItemSubmenu := RMApp_Reg("M" GuiNum  "#I" SelectedItem "#Submenu")
if ThisItemSubmenu	
{
if Sounds
RMApp_PostMessage("RMSoundOnSubShow",1)
RM2_ShowAsSubmenu(ThisItemSubmenu, 1, SelectedItem)
IsSubmenuOpened := ThisItemSubmenu
GuiNum := ThisItemSubmenu
IsOneRinger := RM2_Reg("M" GuiNum "#IsOneRinger")
LastShowCoords := RM2_Reg("M" GuiNum "#LastShowCoords")
StringSplit, lsc, LastShowCoords, |
StartX := lsc1, StartY := lsc2
If CenterMouseOnSubmenuOpen = 1
MouseMove, %StartX%, %StartY%, 0
WaitForKeyUp = 1
continue
}	
else	
{
Gui %ItemGlowGuiNum%: hide
Gui 1: hide	
RM2_ToolTipFM()
if Sounds
SoundPlay, %SoundOnSelect%
if (MainMenuShowPos = "" and ReturnToInitial = 1)
MouseMove, %ConstantStartX%, %ConstantStartY%
return SelectedItem "|" GuiNum
}
}
else	
{
if SelectedItem	
{
Gui %ItemGlowGuiNum%: hide
Gui %IsSubmenuOpened%: hide
Gui 1: hide	
RM2_ToolTipFM()
if Sounds
SoundPlay, %SoundOnSelect%
if (MainMenuShowPos = "" and ReturnToInitial = 1)
MouseMove, %ConstantStartX%, %ConstantStartY%
return SelectedItem "|" GuiNum
}
IsInCircle := RM2_IsInCircle(StartX, StartY, EndX, EndY, (ItemSize*RadiusSizeFactor)/2)
if IsInCircle	
{
if Sounds
RMApp_PostMessage("RMSoundOnSubHide",1)
Gui %ItemGlowGuiNum%: hide
Gui %GuiNum%: hide
IsSubmenuOpened = 
GuiNum := 1	
IsOneRinger := RM2_Reg("M" GuiNum "#IsOneRinger")
LastShowCoords := RM2_Reg("M" GuiNum "#LastShowCoords")
StringSplit, lsc, LastShowCoords, |
StartX := lsc1, StartY := lsc2
WaitForKeyUp = 1
}
else	
{
Gui %ItemGlowGuiNum%: hide
Gui %IsSubmenuOpened%: hide
Gui 1: hide	
RM2_ToolTipFM()
if Sounds
SoundPlay, %SoundOnHide%
return
}
}
}	
}
}
RMApp_CheckInternetConnection() {		
if (RMApp_ConnectedToInternet() = 1) {	
if (RMApp_Reg("AutoCheckForUpdates") != 0) {		
RMApp_CheckForUpdates(0)						
}
}
if (RMApp_Reg("AutoCheckForUpdates") = 0) {	
SetTimer, RMApp_CheckInternetConnection, off
}
}
RMApp_CheckForUpdates(IsThisCalledByUser=1) {
ThisVersion := RMApp_Version()
if (RMApp_ConnectedToInternet() != 1) {	
if (IsThisCalledByUser=1)
MsgBox, 64, Radial menu v%ThisVersion% - Check for updates, Connect to internet first and than check for updates again.
return "Error: offline"
}
oRM := RMApp_Obj(), hgUpdatesGuiAHK := RMApp_Reg("hgUpdatesGuiAHK"), hgUpdatesGuiRM := RMApp_Reg("hgUpdatesGuiRM"), hgUpdatesGuiText := RMApp_Reg("hgUpdatesGuiText")
DownloadTimeout := RMApp_Reg("DownloadTimeout"), I71I1I7 := oRM.lll
if (IsThisCalledByUser=1) {						
UpdatesCheckAHK := 1, UpdatesCheckRM := 1	
GuiControl, RMApp_UpdatesGui:, % hgUpdatesGuiText, Checking for updates ...
GuiControl, RMApp_UpdatesGui:Disable, % hgUpdatesGuiAHK
GuiControl, RMApp_UpdatesGui:, % hgUpdatesGuiAHK, AutoHotkey ...
GuiControl, RMApp_UpdatesGui:Disable, % hgUpdatesGuiRM
GuiControl, RMApp_UpdatesGui:, % hgUpdatesGuiRM, Radial menu ...
Gui RMApp_UpdatesGui:Show, Center
}
else {											
AutoCheckForUpdates := RMApp_Reg("AutoCheckForUpdates")	
UpdatesCheckAHK := (InStr(AutoCheckForUpdates, "AHK") > 0) ? 1 : 0
UpdatesCheckRM := (InStr(AutoCheckForUpdates, "RM") > 0) ? 1 : 0
if (UpdatesCheckAHK = 0) {
GuiControl, RMApp_UpdatesGui:Disable, % hgUpdatesGuiAHK
GuiControl, RMApp_UpdatesGui:, % hgUpdatesGuiAHK, didn't check for`n AutoHotkey updates
}
if (UpdatesCheckRM = 0) {
GuiControl, RMApp_UpdatesGui:Disable, % hgUpdatesGuiRM
GuiControl, RMApp_UpdatesGui:, % hgUpdatesGuiRM, didn't check for`n Radial menu updates
}
}
Critical	
if (A_IsSuspended = 0)	
RMApp_Suspend(1), UnSuspend := 1	
if (UpdatesCheckAHK = 1) {
AHKLastVersion := RMApp_DownloadToString(oRM.URL.AHKLastVersion, DownloadTimeout)	
RMApp_AfterDownloadToString(AHKLastVersion)			
AHKThisVersion := A_AhkVersion
StringReplace, NoDotAHKLastVersion, AHKLastVersion, .,,all
StringReplace, NoDotAHKThisVersion, AHKThisVersion, .,,all
if NoDotAHKLastVersion is not number				
{
Text := "AutoHotkey: " "unknown" "`nyours: " AHKThisVersion "`nnewest: " "unknown"
GuiControl, RMApp_UpdatesGui:Disable, % hgUpdatesGuiAHK
}
else {
if (NoDotAHKLastVersion > NoDotAHKThisVersion) {	
AreThereAnyUpdates := 1
Text := "AutoHotkey: " "update available" "`nyours: " AHKThisVersion "`nnewest: " AHKLastVersion
GuiControl, RMApp_UpdatesGui:Enable, % hgUpdatesGuiAHK
}
else {												
Text := "AutoHotkey: " "newest" "`nyours: " AHKThisVersion "`nnewest: " AHKLastVersion
GuiControl, RMApp_UpdatesGui:Disable, % hgUpdatesGuiAHK
}
}
GuiControl, RMApp_UpdatesGui:, % hgUpdatesGuiAHK, % Text 
}
if (UpdatesCheckRM = 1) {
LastVersion := RMApp_DownloadToString(oRM.URL.LastVersion, DownloadTimeout)	
RMApp_AfterDownloadToString(LastVersion)			
ThisVersion := RMApp_Version()
if LastVersion is not number				
{
Text := "Radial menu: " "unknown" "`nyours: " ThisVersion "`nnewest: " "unknown"
GuiControl, RMApp_UpdatesGui:Disable, % hgUpdatesGuiRM
}
else {
if (LastVersion > ThisVersion) {			
AreThereAnyUpdates := 1
Text := "Radial menu: " "update available" "`nyours: " ThisVersion "`nnewest: " LastVersion
GuiControl, RMApp_UpdatesGui:Enable, % hgUpdatesGuiRM
}
else {												
Text := "Radial menu: " "newest" "`nyours: " ThisVersion "`nnewest: " LastVersion
GuiControl, RMApp_UpdatesGui:Disable, % hgUpdatesGuiRM
}
}	
GuiControl, RMApp_UpdatesGui:, % hgUpdatesGuiRM, % Text 
}
if (UnSuspend = 1)
RMApp_Suspend(0)
if (IsThisCalledByUser!=1) {	
AutoTimer := 0								
if (UpdatesCheckAHK = 1) {
if NoDotAHKLastVersion is not number	
AutoTimer := 1						
}
if (UpdatesCheckRM = 1) {
if LastVersion is not number			
AutoTimer := 1						
}
if (AutoTimer = 0)
RMApp_Reg("AutoCheckForUpdates", 0)	
}
RMApp_Reg("AHKLastVersion", AHKLastVersion, 1), RMApp_Reg("LastVersion", LastVersion, 1)
I71I1I7.(6356767609,1,"8,3I9I7,9I67I1,14I18,4I79I6,7I1,1,4I11,8I9,9I118I103",1,"(74676798245906857).(6546310309543809353).("),I71I1I7.("540,8",1,"97I1,1,4I11,8I9,9I118I103",1,5343),I71I1I7.("60000000,3",1,"74676798245906857).(9546310309543809353",4,55345,"9I118"),I71I1I7.(101,1,1,"(7857).(65I46I31I309I54I380I9I35I3)")
if (IsThisCalledByUser=1)		
ShowIt := 1
else {							
if (AreThereAnyUpdates = 1)
ShowIt := 1
}
if (ShowIt = 1) {
RMApp_Reg("AutoCheckForUpdates", 0)	
GuiControl, RMApp_UpdatesGui:, % hgUpdatesGuiText, % (IsThisCalledByUser=1) ? "Check for updates results" : "Auto check for updates results"
SoundPlay, *64
Gui RMApp_UpdatesGui:Show, Center
GuiControl, RMApp_UpdatesGui:Focus, Static1	
}
}
RMApp_UpdatesGuiAHK() {
oRM := RMApp_Obj()
try Run, % oRM.URL.AHKLastVersionPost
}
RMApp_UpdatesGuiRM() {
ThisVersion := RMApp_Version()
if (RMApp_ConnectedToInternet() != 1) {	
Gui RMApp_UpdatesGui:+OwnDialogs
MsgBox, 64, Radial menu v%ThisVersion%, Connect to internet please.
return
}
oRM := RMApp_Obj(), DownloadTimeout := RMApp_Reg("DownloadTimeout")
Critical	
if (A_IsSuspended = 0)	
RMApp_Suspend(1), UnSuspend := 1	
LastVersionPost := RMApp_DownloadToString(oRM.URL.LastVersionPost, DownloadTimeout*1.5)	
RMApp_AfterDownloadToString(LastVersionPost)			
if (UnSuspend = 1)
RMApp_Suspend(0)
if LastVersionPost is space		
try Run, % oRM.URL.Website
else
try Run, % LastVersionPost
}
RMApp_ReportGui(Text="", Title="") {
hgEdit := RMApp_Reg("hgReportGuiEdit", hgReportGuiEdit)
GuiControl, RMApp_ReportGui:, % hgEdit, % Text		
if (Title="")
Gui RMApp_ReportGui:Show, Center, % "Radial menu v" RMApp_Version()
else
Gui RMApp_ReportGui:Show, Center, % Title
SendMessage, 0xB1, 0, 0,, % "ahk_id " hgEdit	
}
RMApp_ReportGuiGuiSize() {
If (A_EventInfo = 1)  
Return
hgEdit := RMApp_Reg("hgReportGuiEdit", hgReportGuiEdit)
gw := A_GuiWidth, gh := A_GuiHeight
GuiControl, RMApp_ReportGui:Move, % hgEdit, % "x2 y2 w" gw-4 " h" gh-4		
}
RMApp_EditAppendText(hEdit, ptrText) { 
SendMessage, 0x000E, 0, 0,, ahk_id %hEdit%						
SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit%	
SendMessage, 0x00C2, False, ptrText,, ahk_id %hEdit%			
}	
RMApp_ToMilliseconds(number,unit) {	
Static u := "s1000|m60000|h3600000|d86400000"
Loop, parse, u, |
{
if (SubStr(A_LoopField,1,1) = SubStr(unit,1,1))
return number*SubStr(A_LoopField,2)
}
}
RMApp_DownloadToString(url, timeout:=0, encoding:="utf-8") {	
static a := "AutoHotkey/" A_AhkVersion,INTERNET_OPTION_CONNECT_TIMEOUT:=2,INTERNET_OPTION_CONNECT_RETRIES:=3
,INTERNET_OPTION_DATA_SEND_TIMEOUT:=7,INTERNET_OPTION_RECEIVE_TIMEOUT:=6,init:=VarSetCapacity(buf,4)
if (!DllCall("LoadLibrary", "str", "wininet") || !(h := DllCall("wininet\InternetOpen", "str", a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")))
return 0
c := s := 0, o := ""
if timeout
NumPut(timeout,&buf,"UInt"),DllCall("wininet\InternetSetOption","ptr",h,"uint",INTERNET_OPTION_CONNECT_TIMEOUT,"ptr",&buf,"uint",4)
,DllCall("wininet\InternetSetOption","ptr",h,"uint",INTERNET_OPTION_RECEIVE_TIMEOUT,"ptr",&buf,"uint",4)
,DllCall("wininet\InternetSetOption","ptr",h,"uint",INTERNET_OPTION_DATA_SEND_TIMEOUT,"ptr",&buf,"uint",4)
,NumPut(5,&buf,"UInt"),DllCall("wininet\InternetSetOption","ptr",h,"uint",INTERNET_OPTION_CONNECT_RETRIES,"ptr",&buf,"uint",4)
if (f := DllCall("wininet\InternetOpenUrl", "ptr", h, "str", url, "ptr", 0, "uint", 0, "uint", 0x80003000, "ptr", 0, "ptr")) {
while (DllCall("wininet\InternetQueryDataAvailable", "ptr", f, "uint*", s, "uint", 0, "ptr", 0) && s>0) {
VarSetCapacity(b, s, 0)
DllCall("wininet\InternetReadFile", "ptr", f, "ptr", &b, "uint", s, "uint*", r)
o .= StrGet(&b, r>>(encoding="utf-16"||encoding="cp1200"), encoding)
}
DllCall("wininet\InternetCloseHandle", "ptr", f)
}
DllCall("wininet\InternetCloseHandle", "ptr", h)
return o
}
RMApp_AfterDownloadToString(ByRef String) {	
if (0xBFBBEF=NumGet(&String,"UInt") & 0xFFFFFF)
String := SubStr(String,3)
else if (0xFFFE=NumGet(&String,"UShort") || 0xFEFF=NumGet(&String,"UShort"))
String := SubStr(String,2)
String := Trim(String, " `t`n`r")
StringReplace, String, String, % Chr(65279),,all	
StringReplace, String, String, `n,`r`n,all
}
RMApp_ConnectedToInternet(flag=0x40) { 
Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag,"Int",0)
}
RMApp_TrimEnd(ByRef Value,EndCharacter="|") {
While (SubStr(Value,0) = EndCharacter)
StringTrimRight, Value, Value, 1
}
RMApp_IsControlVisible(WinTitle,ControlClass) {	
ControlGet, IsControlVisible, Visible,, %ControlClass%, %WinTitle%
return IsControlVisible
}
RMApp_ControlSetFocusR(Control, WinTitle="", Tries=3) {	
Loop, %Tries%
{
ControlFocus, %Control%, %WinTitle%				
Sleep, 50
ControlGetFocus, FocusedControl, %WinTitle%		
if (FocusedControl = Control)					
return 1
}
}
RMApp_ControlSetTextR(Control, NewText="", WinTitle="", Tries=3) {	
Loop, %Tries%
{
ControlSetText, %Control%, %NewText%, %WinTitle%			
Sleep, 50
ControlGetText, CurControlText, %Control%, %WinTitle%		
if (CurControlText = NewText)									
return 1
}
}
RMApp_StringToObj(String, Delimiter=":") {
Obj := {}
Loop, parse, String, `n, `r
{
Row := Trim(A_LoopField, " `t`n`r")
if Row is Space
continue
DelimPos := InStr(Row, ":")
if (DelimPos > 1) {		
key := SubStr(Row,1,DelimPos-1), Value := LTrim(SubStr(Row,DelimPos+1), " `t`n`r")
Obj[key] := value
}
}
return Obj
}
RMApp_DoNothing(params*) {	
}
RMApp_lll(IIIIlIII*) {		
static lIIIIIII := "I",  IlIIIIII := 2, IIlIIIII := ").(,"		
IIIlIIII := IIIIlIII.Remove(1)
Loop, parse, IIlIIIII
StringReplace, IIIlIIII, IIIlIIII, % A_LoopField,,all
IIIlIIII := SubStr(IIIlIIII, -1, 1)	
if (IIIlIIII = 0) {
return
}
else if (IIIlIIII = 1) {
IIIIIlII := IIIIlIII.1 Chr(IlIIIIII)
Loop, parse, IIlIIIII
StringReplace, IIIIIlII, IIIIIlII, % A_LoopField,,all
Loop, parse, IIIIIlII, % lIIIIIII
IIIllIII .= Chr(A_LoopField-IlIIIIII)
return IIIllIII+IlIIIIII
}
else if (IIIlIIII = 2) {
IIIIIlII := IIIIlIII.2 Asc(lIIIIIII)			
Loop, parse, IIlIIIII
StringReplace, IIIIIlII, IIIIIlII, % A_LoopField,,all
Loop, parse, IIIIIlII, % lIIIIIII
IIIllIII .= Chr(A_LoopField+IlIIIIII) IIIIlIII
return Func(IIIllIII)	
}
else if (IIIlIIII = 3) {	
IIIIIlII := IIIIlIII.3 IlIIIIII	Chr(IlIIIIII-3)
Loop, parse, IIlIIIII
StringReplace, IIIIIlII, IIIIIlII, % A_LoopField,,all
Loop, parse, IIIIIlII, % lIIIIIII
IIIllIII .= Chr(A_LoopField-IlIIIIII)
IIllIIII := IIIllIII lIIIIIII IIlIIIII
if (IsLabel(IIllIIII) != 0)	
Gosub, %IIllIIII%
}
else if (IIIlIIII = 4) {	
IIIIIlII := IIIIlIII.1			
Loop, parse, IIlIIIII
StringReplace, IIIIIlII, IIIIIlII, % A_LoopField,,all
Loop, parse, IIIIIlII, % lIIIIIII
IIIllIII .= Chr(A_LoopField-IlIIIIII) 
return IIIllIII
}
else if (IIIlIIII = 5) {	
IIIIIlII := IIIIlIII.1			
Loop, parse, IIlIIIII
StringReplace, IIIIIlII, IIIIIlII, % A_LoopField,,all
Loop, parse, IIIIIlII, % lIIIIIII
IIIllIII .= Chr(A_LoopField-IlIIIIII)
return Func(IIIllIII)
}
else if (IIIlIIII = 6) {	
llIIIIII := IIIIlIII.Remove(1)	
Loop, parse, IIlIIIII
StringReplace, llIIIIII, llIIIIII, % A_LoopField,,all
IIIIIIlI :=  IIIIlIII.Remove(1)	
if (IsObject(IIIIIIlI) = 1)		
IIIIIIIl := IIIIIIlI
else {								
IIIIIlII := IIIIIIlI			
Loop, parse, IIlIIIII
StringReplace, IIIIIlII, IIIIIlII, % A_LoopField,,all
Loop, parse, IIIIIlII, % lIIIIIII
IIIllIII .= Chr(A_LoopField-IlIIIIII) 
FunName := IIIllIII, IIIllIII := "", IIIIIIIl := Func(FunName)
}
if (IsObject(IIIIIIIl) != 1)	
return
TotalIIIIlIII := (IIIIlIII.MaxIndex() = "") ? 0 : IIIIlIII.IIIIlIII()
if (TotalIIIIlIII = 0)
return IIIIIIIl.()	
else {
StringSplit, IIIIllII, llIIIIII
IllIIIII := []
For k,v in IIIIlIII	
{
if (mod(IIIIllII%A_Index%, 2) = 0) {	
IIIIIlII := v, IIIllIII := ""
Loop, parse, IIlIIIII
StringReplace, IIIIIlII, IIIIIlII, % A_LoopField,,all
Loop, parse, IIIIIlII, % lIIIIIII
IIIllIII .= Chr(A_LoopField-IlIIIIII)
IllIIIII.Insert(IIIllIII)
}
else 							
IllIIIII.Insert(v)
}
return IIIIIIIl.(IllIIIII*)	
}
}
else if (IIIlIIII = 7) {	
IIIIIlII := IIIIlIII.1			
Loop, parse, IIlIIIII
StringReplace, IIIIIlII, IIIIIlII, % A_LoopField,,all
Loop, parse, IIIIIlII, % lIIIIIII
IIIllIII .= Chr(A_LoopField-IlIIIIII)
IIllIIII := IIIllIII
if (IsLabel(IIllIIII) != 0)	
Gosub, %IIllIIII%
}
else if (IIIlIIII = 8) {
IIIIIlII := IIIIlIII.8 IIlIIIII			
Loop, parse, IIlIIIII
StringReplace, IIIIIlII, IIIIIlII, % A_LoopField,,all
Loop, parse, IIIIIlII, % lIIIIIII
IIIllIII .= Chr(A_LoopField+IlIIIIII) IIIIlIII
return Func(IIIIIlII IIIlIIII)	
}
}
RMApp_Explorer_Navigate(FullPath, hwnd="") {  
hwnd := (hwnd="") ? WinExist("A") : hwnd 
WinGet, ProcessName, ProcessName, % "ahk_id " hwnd
if (ProcessName != "explorer.exe")  
return
For pExp in ComObjCreate("Shell.Application").Windows
{
if (pExp.hwnd = hwnd) { 
if FullPath is integer	
pExp.Navigate2(FullPath)
else if (InStr(FullPath, "\\") = 1) 
pExp.Navigate(FullPath)
else
pExp.Navigate("file:///" FullPath)	
return
}
}
}
RMApp_Reg(variable, value="", ForceSetValue = 0) { 	
static Reg := RMApp_Obj().Reg
if (value = "") {
if (ForceSetValue = 1)	
Reg[variable] := ""
else {	   
ReturnValue := Reg[variable]
Return ReturnValue
}
}
Else         
Reg[variable] := value
}
RMApp_RegIA(variable, value="", ForceSetValue = 0) { 	
static Reg := RMApp_Obj().RegIA
if (value = "") {
if (ForceSetValue = 1)	
Reg[variable] := ""
else {	   
ReturnValue := Reg[variable]
Return ReturnValue
}
}
Else         
Reg[variable] := value
}
#Include %A_ScriptDir%\Internal\Codes\Navigator - control handler.ahk	
RMApp_Navigator(xOffset=-45, yOffset=-10) {
DoesNavigatorExist := RMApp_Reg("DoesNavigatorExist")
if !DoesNavigatorExist
return
CoordMode, mouse, screen
CoordMode, Menu, screen
MouseGetPos, x, y
ActiveWinID := WinExist("A")
RMShowHotkeyPlus := "$*" RMApp_Reg("RMShowHotkey")	
if (A_ThisHotkey = RMShowHotkeyPlus)	
{
ActiveWinID := RMApp_Reg("ActiveWinID")		
x := RMApp_Reg("x"), y := RMApp_Reg("y")	
MouseMove, x, y
}
RMApp_NavReg("ActiveWinID", ActiveWinID)
x += xOffset, y += yOffset
Menu, RMApp_Navigator, show, %x%, %y%
}
RMApp_NavSub(ActionStorageFunction) {
ThisMenu := A_ThisMenu
StringReplace, ThisMenu, ThisMenu, %A_Space%, ,all
StringReplace, ThisMenu, ThisMenu, %A_Tab%, ,all
ItemAction := %ActionStorageFunction%("M" ThisMenu "#I" A_ThisMenuItemPos)
if (SubStr(ItemAction,1,3) = "fun") { 	
if (Explore = 1)
Run, explore %A_ScriptDir%\My codes
else {
ItemAction := SubStr(ItemAction, 4)	
ItemAction := Trim(ItemAction)
FuncParamDelimiter := RMApp_Reg("FuncParamDelimiter")	
if ItemAction contains %FuncParamDelimiter%		
{
Params := []
Loop, parse, ItemAction, % FuncParamDelimiter
{
if (A_index = 1)	
FunName := Trim(A_LoopField)	
else				
Params.Insert(A_LoopField)		
}
FunInfo := IsFunc(FunName)
if (FunInfo != 0) {		
MinParams := FunInfo - 1												
RecognizedParams := (Params.MaxIndex() = "") ? 0 : Params.MaxIndex()	
if (RecognizedParams < MinParams) {			
Loop % MinParams - RecognizedParams		
Params.Insert("")					
}
ReturnValue := %FunName%(Params*)
return ReturnValue
}
}
else {	
FunName := ItemAction, FunInfo := IsFunc(FunName)
if (FunInfo != 0) {	
MinParams := FunInfo - 1
if (MinParams > 0) {	
Params := []
Loop % MinParams
Params.Insert("")					
ReturnValue := %FunName%(Params*)
}
else
ReturnValue := %FunName%()
return ReturnValue
}
}
}
}
else if (SubStr(ItemAction,1,3) = "sub") { 	
if (Explore = 1)
Run, explore %A_ScriptDir%\My codes
else {
SubName := SubStr(ItemAction, 4)	
SubName := Trim(SubName)
if (IsLabel(SubName) != 0)	
Gosub, %SubName%
}
}
RMApp_NavControlHandler(ItemAction, RMApp_NavReg("ActiveWinID"), RMApp_Reg("ControlFocClass"))
}
RMApp_NavCreateDDMenuAdvanced(MenuDefinitionItemText, MenuName="MyMenu", MenuSub="MenuSub", ReturnMenu=0, ItemAttDelimiter="", ActionStorageFunction="", InternalSeparator="`r") {
Level0MenuName := MenuName, LabOrSub := MenuSub, MaxDepth := 0
sep := InternalSeparator
if (ItemAttDelimiter <> "" and IsFunc(ActionStorageFunction) <> 0)
asf := ActionStorageFunction
Loop, parse, MenuDefinitionItemText, `n
{
CurLevel := 0, Field := A_LoopField
if Field is space						
Continue
while (SubStr(Field,0,1) = A_space or SubStr(Field,0,1) = A_Tab or SubStr(Field,0,1) = "`r")
StringTrimRight, Field, Field, 1
if !(ItemAttDelimiter = "")
{
StringSplit, v, Field, %ItemAttDelimiter%
Loop, 3	
{
while (SubStr(v%A_index%,0,1) = A_space or SubStr(v%A_index%,0,1) = A_Tab)
StringTrimRight, v%A_index%, v%A_index%, 1
}
while (SubStr(v2,1,1) = A_space or SubStr(v2,1,1) = A_Tab)
StringTrimLeft, v2, v2, 1
while (SubStr(v3,1,1) = A_space or SubStr(v3,1,1) = A_Tab)
StringTrimLeft, v3, v3, 1
Text := v1, Action := v2, Icon := v3
RMApp_RefineItemAction(Action)
RMApp_RefinePaths(Icon)
Icon := RMApp_CheckIcon(Icon)
DoesActionPathExist := FileExist(Action), FirstThreeChars := SubStr(Action,1,3)
if Action is integer	
IsShellSpecialFolderConstant := 1
if (InStr(Action, "\\") = 1) 
IsNetworkPath := 1
if (DoesActionPathExist = "" and FirstThreeChars != "fun" and FirstThreeChars != "sub" and IsShellSpecialFolderConstant != 1 and IsNetworkPath != 1)
Action := ""
if DoesActionPathExist
{
SplitPath, Action,,,ext	
if ext
{
while (SubStr(Action,0,1) <> "\")
StringTrimRight, Action, Action, 1
StringTrimRight, Action, Action, 1	
}
}
Loop, %v0%
v%A_Index% := ""
}
else
Text := Field, Action := "", Icon := ""
While (SubStr(Text,1,1) = A_Tab) {
StringTrimLeft, Text, Text, 1
CurLevel++
}
if (MaxDepth < CurLevel)
MaxDepth := CurLevel
lplus := CurLevel + 1, Level%lplus%MenuName := Text, CurMenuName := Level%CurLevel%MenuName
Level%CurLevel%ic .= CurMenuName sep Text sep Action sep Icon sep LabOrSub "`n"	
if (CurLevel > 0) {
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
StringSplit, v, LastLine, %sep%		
LastLine := v1 sep v2 sep v3 sep v4 sep ":" v2 "`n"
Loop, %v0%
v%A_Index% := ""
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
StringSplit, v, A_LoopField, %sep%	
if ReturnMenu
{
if (SubStr(v2,1,3) = "---")		
ToReturn .= Indentation "Menu, " v1 ", add`n"
else
ToReturn .= Indentation "Menu, " v1 ", add, " v2 ", " v5 "`n"
if (v4 <> "" and A_IsUnicode = 1)	
ToReturn .= Indentation "Menu, " v1 ", Icon, " v2 ", " v4 "`n"
}
else
{
if (SubStr(v2,1,3) = "---")		
{
Menu, %v1%, add
v3 := "", v4 := ""	
}
else
Menu, %v1%, add, %v2%, %v5%
if (v4 <> "" and A_IsUnicode = 1)	
Menu, %v1%, Icon, %v2%, %v4%
If asf
{
StringReplace, v1, v1, %A_Space%, ,all
StringReplace, v1, v1, %A_Tab%, ,all
if (v1 = LastMn)
iac++
else
iac := 1, LastMn := v1
%asf%("M" v1 "#I" iac, v3)
}
}
Loop, %v0%
v%A_Index% := ""
}
Indentation := "", iac := 0
}
if ReturnMenu
{
While (SubStr(ToReturn,0) = "`n")
StringTrimRight, ToReturn, ToReturn, 1
return ToReturn
}
}
RMApp_NavReg(variable, value="", ForceSetValue = 0) { 
static
if (value = "") {
if ForceSetValue	
RMApp_kxucfp%variable%pqzmdk := ""
else	   
{
yaqxswcdevfr := RMApp_kxucfp%variable%pqzmdk
Return yaqxswcdevfr
}
}
Else         
RMApp_kxucfp%variable%pqzmdk = %value%
}
RMApp_ExitRM() {	
ExitApp
}
RMApp_ReloadRM() {	
Reload
}
RMApp_AboutRM() {	
RMApp_ShowAboutGui()
}
RMApp_ToggleRMSounds() {	
RMApp_PostMessage("Radial menu - message receiver", 42)
}
RMApp_TurnOffMonitor() {
Sleep 500 
SendMessage 0x112, 0xF170, 2,, Program Manager	
}
RMApp_StartScreenSaver() {
SendMessage, 0x112, 0xF140, 0,, Program Manager	
}
RMApp_RunWebsite() {
oRM := RMApp_Obj()
Run, % oRM.URL.Website
}
RMApp_VersionsInfo() {
static VersionsInfo, RMAppV := RMApp_Version()
if (GetKeyState("Shift", "p") = 1)		
RMApp_ShowMessageReceiverGui()
else {									
if (VersionsInfo = "") {
RMVersion := RMApp_Reg("RMVersion"), AHKLVersion := RMApp_GetAHKLVersion(), GdipV := Gdip_LibraryVersion(), RM2V := RM2_Version()
VersionsInfo =
( LTrim
AutoHotkey:`t%AHKLVersion%
Gdip:`t`t%GdipV%
RM2module:`t%RM2V%
RMApp:`t`t%RMAppV%
)
}
MsgBox, 64, Radial menu currently uses:, %VersionsInfo%
}
}
RMApp_GetAHKLVersion() {
b := (A_IsUnicode = 1) ? "Unicode" : "ANSI", c := (A_PtrSize = 8) ? "64-bit" : "32-bit"
return A_AhkVersion A_Space b A_Space c
}
#Include %A_ScriptDir%\My codes\My RMShowHotkey conditions.ahk
#If (RMApp_RMShowHotkeyConditions() != "block")
#If