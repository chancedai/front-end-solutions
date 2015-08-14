/*
	Clipjump

	Copyright 2013 Avi Aryan

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

;@Ahk2Exe-SetName Clipjump
;@Ahk2Exe-SetDescription Clipjump
;@Ahk2Exe-SetVersion 11.3
;@Ahk2Exe-SetCopyright Avi Aryan
;@Ahk2Exe-SetOrigFilename Clipjump.exe

SetWorkingDir, %A_ScriptDir%
SetBatchLines,-1
#NoEnv
#SingleInstance, force
#ClipboardTimeout 0              ;keeping this value low as I already check for OpenClipboard in OnClipboardChange label
CoordMode, Mouse
CoordMode, Tooltip
FileEncoding, UTF-8
ListLines, Off
#KeyHistory 0
#HotkeyInterval 1000
#MaxHotkeysPerInterval 1000

global ini_LANG := "" , H_Compiled := RegexMatch(Substr(A_AhkPath, Instr(A_AhkPath, "\", 0, 0)+1), "iU)^(Clipjump).*(\.exe)$") && (!A_IsCompiled) ? 1 : 0
global mainIconPath := H_Compiled || A_IsCompiled ? A_AhkPath : "icons/icon.ico"

;*********Program Vars**********************************************************
; Capitalised variables (here and everywhere) indicate that they are global

global PROGNAME := "Clipjump"
global VERSION := "11.3"
global CONFIGURATION_FILE := "settings.ini"

ini_LANG := ini_read("System", "lang")
global TXT := Translations_load("languages/" ini_LANG ".txt") 		;Load translations

global UPDATE_FILE := "http://sourceforge.net/projects/clipjump/files/version.txt/download"
global PRODUCT_PAGE := "http://clipjump.sourceforge.net"
global HELP_PAGE := "http://clipjump.sourceforge.net/docs"
global AUTHOR_PAGE := "http://aviaryan.github.io"

global MSG_TRANSFER_COMPLETE := TXT.TIP_copied " " PROGNAME    ;not space
global MSG_CLIPJUMP_EMPTY := TXT.TIP_empty1 "`n`n" PROGNAME " " TXT.TIP_empty2 "`n`n" TXT.TIP_empty3 ;not `n`n
global MSG_ERROR := TXT.TIP_error
global MSG_MORE_PREVIEW := TXT.TIP_more
global MSG_PASTING := TXT.TIP_pasting
global MSG_DELETED := TXT.TIP_deleted
global MSG_ALL_DELETED := TXT.TIP_alldeleted
global MSG_CANCELLED := TXT.TIP_cancelled
global MSG_FIXED := TXT.TIP_fixed
global MSG_HISTORY_PREVIEW_IMAGE := TXT.HST_viewimage
global MSG_FILE_PATH_COPIED := TXT.TIP_filepath " " PROGNAME
global MSG_FOLDER_PATH_COPIED := TXT.TIP_folderpath " " PROGNAME

;History Tool
global hidden_date_no := 4 , history_w , history_partial := 1 ;start off with partial=1 <> much better
global PREV_FILE := "cache\prev.html"

;*******************************************************************************

;Creating Storage Directories
FileCreateDir, cache
FileCreateDir, cache/clips
FileCreateDir, cache/thumbs
FileCreateDir, cache/history
FileSetAttrib, -H, %A_WorkingDir%\cache

;Init Non-Ini Configurations
FileDelete, % A_temp "/clipjumpcom.txt"
try Clipboard := ""

;Global Data Holders
Sysget, temp, MonitorWorkArea
global WORKINGHT := tempbottom-temptop
global restoreCaller := 0

;Global Inits
global CN := {}, CUSTOMS := {}, CDS := {}, CPS := {}, SEARCHOBJ := {}, HISTORYOBJ := {}, TOTALCLIPS, ACTIONMODE := {}, PLUGINS := {}, STORE := {}
global cut_is_delete_windows := "XLMAIN QWidget" 			;excel, kingsoft office
global CURSAVE, TEMPSAVE, LASTCLIP, LASTFORMAT, Islastformat_Changed := 1, IScurCBACTIVE := 0, curPformat, curPfunction, curPisPreviewable
global NOINCOGNITO := 1, SPM := {}, protected_DoBeep := 1

;Initailizing Common Variables
global CALLER_STATUS, CLIPJUMP_STATUS := 1		; global vars are not declared like the below , without initialising
global CALLER := CALLER_STATUS := 1, IN_BACK := 0, MULTIPASTE, PASTEMODE_ACT
global CLIP_ACTION := "", ONCLIPBOARD := 1 , ISACTIVEEXCEL := 0 , HASCOPYFAILED := 0 , ctrlRef		;specific purpose global vars

;Init General vars
is_pstMode_active := 0

;Setting up Icons
FileCreateDir, icons
FileInstall, icons\no_history.Ico, icons\no_history.Ico, 0 			;Allow users to have their icons
FileInstall, icons\no_monitoring.ico, icons\no_monitoring.ico, 0

;Ini Configurations
Iniread, ini_Version, %CONFIGURATION_FILE%, System, Version

If !FileExist(CONFIGURATION_FILE)
{
	save_default(1)
	if !Instr(VERSION, "b") 		; betas have b
	{
		MsgBox, 52, Recommended, % TXT.ABT_seehelp
		IfMsgBox, Yes
			gosub, hlp
	}
	if !A_IsAdmin
		MsgBox, 16, WARNING, % TXT.ABT_runadmin
	try TrayTip, Clipjump, % TXT.ABT_cjready , 10, 1
}
else if (ini_Version != VERSION)
{
	save_default(0) 			;0 corresponds to selective save
	FileDelete, lib\classTool.ahk 		; REMOVED
	gosub Reload 		; Update plugin includes with what the user has incase he updates his Clipjump
}


;Global Ini declarations
global ini_IsImageStored , ini_Quality , ini_MaxClips , ini_Threshold , ini_IsChannelMin , ini_isMessage, CopyMessage
		, Copyfolderpath_K, Copyfilepath_K, Copyfilepath_K, channel_K, onetime_K, paste_k, actionmode_k, ini_is_duplicate_copied, ini_formatting
		, ini_CopyBeep , beepFrequency , ignoreWindows, ini_defEditor, ini_defImgEditor, ini_def_Pformat, pluginManager_k, holdClip_K, ini_PreserveClipPos
		, chOrg_K, ini_startSearch

; (search) paste mode keys 
global pastemodekey := {} , spmkey := {}
temp_keys := "a|c|s|z|space|x|e|up|down|f|h|Enter|t|F1"
loop, parse, temp_keys,|
	pastemodekey[A_LoopField] := "^" A_LoopField
temp_keys := "Enter|Up|Down|Home"
loop, parse, temp_keys,|
	spmkey[A_LoopField] := A_LoopField

global windows_copy_k, windows_cut_k

init_actionmode()
;Initialising Clipjump Channels
initChannels()
;loading Settings
load_Settings(1)
validate_Settings()
;load plugins
loadPlugins()
;load custom settings
loadCustomizations()

trayMenu()

loop
{
	IfNotExist, cache/Clips/%A_Index%.avc
	{
		CURSAVE := A_Index - 1 , TEMPSAVE := CURSAVE
		break
	}
}

;STARTUP
IfExist, %A_Startup%/Clipjump.lnk
{
	FileDelete, %A_Startup%/Clipjump.lnk
	FileCreateShortcut, % H_Compiled ? A_AhkPath : A_ScriptFullPath, %A_Startup%/Clipjump.lnk
	Menu, Options_Tray, Check, % TXT.TRY_startup
}

global CLIPS_dir := "cache/clips"
	, THUMBS_dir := "cache/thumbs"
	, FIXATE_txt := "fixed"
	, NUMBER_ADVANCED := 34 + CN.Total 					;the number stores the line number of ADVANCED section

;Setting Up shortcuts
hkZ( ( paste_k ? "$^" paste_k : emptyvar ) , "Paste")
hkZ("$^c", "NativeCopy") , hkZ("$^x", "NativeCut")
hkZ(Copyfilepath_K, "CopyFile") , hkZ(Copyfolderpath_K, "CopyFolder")
hkZ(history_K, "History")
hkZ(Copyfiledata_K, "CopyFileData") , hkZ(channel_K, "channelGUI")
hkZ(onetime_K, "oneTime") , hkZ(pitswap_K, "pitswap")
hkZ(actionmode_K, "actionmode") , hkZ(pluginManager_k, "pluginManagerGUI")
hkZ(holdClip_K, "holdClip") , hkZ(chOrg_K, "channelOrganizer")
;more shortcuts
hkZ(windows_copy_k, "windows_copy") , hkZ(windows_cut_k, "windows_cut")
;Environment
OnMessage(0x4a, "Receive_WM_COPYDATA")  ; 0x4a is WM_COPYDATA
;Clean History
historyCleanup()

;create Ignore windows group from | separated values
loop, parse, ignoreWindows,|
	GroupAdd, ignoreGroup, ahk_class %A_LoopField%
;group created

loadClipboardDataS()
OnExit, exit

fix_FixateFiles()

EmptyMem()
return

;Tooltip No 1 is used for Paste Mode tips, 2 is used for notifications , 3 is used for updates , 4 is used in Settings , 5 is used in Action Mode
;6 used in Class Tool, 7 in API (Plugin) , 8 used in Customizer, 9 used in history tool, 10 in edit clips, 11 in Channel Organizer

;OLD VERSION COMPATIBILITES TO REMOVE
; FIXATE

fix_FixateFiles(){
	loop % CN.Total
	{
		fp := "cache\fixate" (A_Index-1 ? A_index-1 : "") , rp := A_index-1
		if !FileExist(fp)
			continue
		else DidRun := 1
		CPS[rp] := {}  ; using 0 for ch 0
		loop, % fp "\*.fxt"
			CPS[rp][ cp := Substr(A_LoopFileName,1,-4) ] := {} , CPS[rp][cp][FIXATE_txt] := 1
		FileRemoveDir, % fp, 1
	}
	if DidRun
		Prefs2Ini()
}

;End Of Auto-Execute================================================================================================================

loadClipboardDataS(){
	API.showTip(TXT.TIP_initMsg)
	API.blockMonitoring(1)
	loop % CN.Total
	{
		fp := "cache\clips" ( A_index-1 ? A_index-1 : "" )
		CDS[R:=A_index-1] := {}
		CPS[R] := ini2Obj(fp "\prefs.ini")
		loop, % fp "\*.avc"
		{
			ONCLIPBOARD:="" , Z := ""
			if try_ClipboardfromFile(A_LoopFileFullPath, 300)
				Z := trygetVar("Clipboard", 500) 	; 300 tries minimize chances of Clipboard recorders like Exekutor to interrupt 
			else ONCLIPBOARD := 1 , Z := ""

			while !ONCLIPBOARD
				sleep 5
			CDS[R][Substr(A_LoopFileName,1,-4)] := Z
		}
	}
	API.removeTip()
	API.blockMonitoring(0)
}

paste:
	Critical, On
	IfWinActive, ahk_group ignoreGroup
	{
		Send ^{vk56}
		return
	}

	Gui, imgprv:Destroy
	CALLER := 0
	if !ctrlRef
		firstPasteMode := 1
	if ini_startSearch && firstPasteMode
		SPM.ACTIVE := 1
	ctrlRef := "pastemode"
	if IN_BACK
		IN_BACK_correction()

	if (TEMPSAVE>CURSAVE) or !TEMPSAVE
		TEMPSAVE := CURSAVE

	If !FileExist(CLIPS_dir "/" TEMPSAVE ".avc")
	{
		if !oldclip_exist
		{
			oldclip_exist := 1
			try oldclip_data := ClipboardAll
		}

		try Clipboard := ""
		hkZ(pastemodekey.up, "channel_up") , hkZ(pastemodekey.down, "channel_down") 		;activate the 2 keys to jump channels
		Tooltip, % "{" CN.Name "} " MSG_CLIPJUMP_EMPTY 				;No Clip Exists
		setTimer, ctrlCheck, 50
	}
	else
	{
		if !oldclip_exist 					;will be false when V is pressed for 1st time
		{
			oldclip_exist := 1
			try oldclip_data := ClipboardAll
			catch {
				makeClipboardAvailable(0)  						; make clipbboard available in case it is blocked
			}
		}
		else
			IScurCBACTIVE := 0 				;false it when V is pressed for the 2nd time

		if !is_pstMode_active
			hkZ_pasteMode(1) , is_pstMode_active := 1

		if !IScurCBACTIVE 				;if the current clipboard is not asked for , then only load from file
			try_ClipboardfromFile(A_WorkingDir "/" CLIPS_dir "/" TEMPSAVE ".avc") 	; gets file onto clipboard trying 100 times

		temp_clipboard := trygetVar("Clipboard")  	;gets variable with multiple tries

		fixStatus := fixCheck()
		realclipno := CURSAVE - TEMPSAVE + 1

		if temp_clipboard =
			showPreview()
		else
		{
			If strlen(temp_clipboard) > 200
				halfClip := Substr(temp_clipboard, 1, 200) "`n`n" MSG_MORE_PREVIEW
			else halfClip := temp_clipboard
			if curPisPreviewable
				halfClip := %curPfunction%(halfClip)
		}
		realActive := TEMPSAVE
		PasteModeTooltip(temp_clipboard)
		SetTimer, ctrlCheck, 50

		TEMPSAVE -= 1
		If (TEMPSAVE == 0)
			TEMPSAVE := CURSAVE
	}
	if ini_startSearch && firstPasteMode
		setTimer, run_searchpm, -10 	; dont open in this thrd. critical
	firstPasteMode := 0
	return

onClipboardChange:
	Critical, On
	if !ONCLIPBOARD
	{
		ONCLIPBOARD:=1 	; if let blank, the label ends quickly
		return
	}
	ONCLIPBOARD := 1 		;used by paste/or another to identify if OnCLipboard has been breached

	ifwinactive, ahk_group IgnoreGroup
		return

	If CALLER
	{
		if !WinActive("ahk_class XLMAIN")
			 try   clipboard_copy := makeClipboardAvailable() , ISACTIVEEXCEL := 0
		else try   clipboard_copy := LASTCLIP , ISACTIVEEXCEL := 1  	;so that Cj doesnt open excel clipboard (for a longer time) and cause problems 
		;clipboard_copy = lastclip as to remove duplicate copies in excel , ^x or ^c makes lastclip empty

		try eventinfo := A_eventinfo

		if ISACTIVEEXCEL
			isLastFormat_changed := 1                           ;same reason as above
		else
			try isLastFormat_changed :=  ( LASTFORMAT != (temp_lastformat := GetClipboardFormat(0)) )   ?   1   :   0
		if isLastFormat_changed or ( LASTCLIP != clipboard_copy) or ( clipboard_copy == "" )
			returnV := clipChange(eventinfo, clipboard_copy)
		LASTFORMAT := temp_lastformat , CLIP_ACTION := returnV ? "" : CLIP_ACTION  		;make CLIP_ACTION empty if copy/cut succeeded else let it be so that if window uses
			;2 transfers like Excel , the demand can be fulfilled
		IScurCBACTIVE := returnV 									;current clipboard is active after new data copied to clipboard SUCCESSFULLY
		if CPS[CN.NG][CURSAVE][FIXATE_txt]	; not active if the first clip is FIXED
			IScurCBACTIVE := 0
		if !ISACTIVEEXCEL 				;excel has known bugs with AHK and manipulating clipboard *infront* of it will cause errors
			makeClipboardAvailable(0) 						;close clipboard in case it is still opened by clipjump
	}
	else
	{
		LASTFORMAT := WinActive("ahk_class XLMAIN") ? "" : GetClipboardFormat(0)
		if restoreCaller
			restoreCaller := "" , CALLER := CALLER_STATUS
		if onetimeOn
		{
			onetimeOn := 0 ;--- To avoid OnClipboardChange label to open this routine [IMPORTANT]
			sleep 500 ;--- Allows the restore Clipboard Transfer in apps
			CALLER := CALLER_STATUS
			autoTooltip("One Time Stop " TXT.TIP_deactivated, 600, 2)
			changeIcon()
		}
	}
	return

clipChange(CErrorlevel, clipboard_copy) {

	If CErrorlevel = 1
	{
		if ( clipboard_copy != LASTCLIP ) or ( clipboard_copy == "" )        ;dont let go if lastclip = clipboard_copy = <empty>
		{
			CURSAVE += 1

			if ISACTIVEEXCEL
				LASTCLIP := clipsaver()
			else
				LASTCLIP := clipboard_copy , temp := clipSaver()

			If HASCOPYFAILED
			{
				CURSAVE -= 1 , TEMPSAVE := CURSAVE
				return
			}

			if NOINCOGNITO and ( CN.Name != "pit" )
				FileAppend, %LASTCLIP%, cache\history\%A_Now%.txt

			BeepAt(ini_CopyBeep, beepFrequency)
			ToolTip, %copyMessage%

			if CLIP_ACTION = CUT
			{
				WinGetClass, activeclass, A
				if Instr(cut_is_delete_windows, activeclass)
					Send {vk2e} 			;del
			}

			TEMPSAVE := CURSAVE
			if ( CURSAVE >= TOTALCLIPS )
				compacter()

			returnV := 1
		}
	}
	else If CErrorlevel = 2
	{
			CURSAVE += 1 , TEMPSAVE := CURSAVE , LASTCLIP := ""

			clipSaver()
			if HASCOPYFAILED
			{
				CURSAVE -= 1 , TEMPSAVE := CURSAVE
				return
			}

			BeepAt(ini_CopyBeep, beepFrequency)
			ToolTip, %copyMessage%
			thumbGenerator()

			if NOINCOGNITO and ini_IsImageStored and ( CN.Name != "pit" )
				FileCopy, %THUMBS_dir%\%CURSAVE%.jpg, cache\history\%A_Now%.jpg

			if ( CURSAVE >= TOTALCLIPS )
				compacter()

			returnV := 2
	}
	SetTimer, TooltipOff, 500
	emptyMem()
	return returnV
}

moveBack:
	Critical ;, On
	IfWinActive, ahk_group IgnoreGroup
		return
	Gui, imgprv:Destroy
	IN_BACK := true
	TEMPSAVE := realActive + 1
	if realActive = %CURSAVE%
		TEMPSAVE := 1
	realActive := TEMPSAVE
	IScurCBACTIVE := 0 			;the key will be always pressed after V
	try_ClipboardfromFile(CLIPS_dir "/" TEMPSAVE ".avc")
	temp_clipboard := trygetVar("Clipboard")

	fixStatus := fixCheck()
	realClipNo := CURSAVE - TEMPSAVE + 1
	if temp_clipboard =
		showPreview()
	else
	{
		if strlen(temp_clipboard) > 200
		{
			StringLeft, halfClip, temp_clipboard, 200
			halfClip := halfClip "`n`n" MSG_MORE_PREVIEW
		}
		else halfClip := temp_clipboard
		IF curPisPreviewable
			halfClip := %curPfunction%(halfClip)
	}
	PasteModeTooltip(temp_clipboard)
	SetTimer, ctrlCheck, 50
	return

IN_BACK_correction(){ 	; corrects TEMPSAVE value when C (backwards) is used in paste mode
	global
	IN_BACK := false
	If (TEMPSAVE == 1)
		TEMPSAVE := CURSAVE
	else
		TEMPSAVE -= 1
}

;-------------- paste mode tips ------------------------

multiPaste:
	if SPM.ACTIVE {
		WinHide, Clipjump_SPM ahk_class AutoHotkeyGUI
		WinWaitNotActive, Clipjump_SPM ahk_class AutoHotkeyGUI
		temp_spmWasActive := 1
	}
	MULTIPASTE := PASTEMODE_ACT := 1
	while PASTEMODE_ACT
		sleep 50 		; wait till ctrlCheck: runs
	if MULTIPASTE 		; if multipaste is still ON, becomes OFF due to release of ctrl (which doesnt disturb when spm is active)
		gosub paste
	if temp_spmWasActive {
		WinShow, Clipjump_SPM ahk_class AutoHotkeyGUI
		temp_spmWasActive := 0
	}
	return

cancel:
	Gui, Hide
	PasteModeTooltip(TXT.TIP_cancelm "`t(1)`n" TXT.TIP_modem, 1)
	ctrlref := "cancel"
	if SPM.ACTIVE
		gosub SPM_dispose 	; dispose it if There - Note that this step ends the label as ctrlCheck dies so ctrlRef is kept upwards to be updated
	hkZ_pasteMode(0, 0) , hkZ(pastemodekey.x, "Delete", 1)
	return

delete:
	PasteModeTooltip(TXT.TIP_delm "`t`t(2)`n" TXT.TIP_modem, 1)
	ctrlref := "delete"
	hkZ(pastemodekey.x, "Delete", 0) , hkZ(pastemodekey.x, "cutclip", 1)
	return

cutclip:
	PasteModeTooltip(TXT.TIP_move "`t`t(3)`n" TXT.TIP_modem, 1)
	ctrlref := "cut"
	hkZ(pastemodekey.x, "cutclip", 0) , hkZ(pastemodekey.x, "copyclip", 1)
	return

copyclip:
	PasteModeTooltip(TXT.TIP_copy "`t`t(4)`n" TXT.TIP_modem, 1)
	ctrlref := "copy"
	hkZ(pastemodekey.x, "copyclip", 0) , hkZ(pastemodekey.x, "DeleteAll", 1)
	return

deleteall:
	PasteModeTooltip(TXT.TIP_delallm "`t`t(5)`n" TXT.TIP_modem, 1)
	ctrlref := "deleteAll"
	hkZ(pastemodekey.x, "DeleteAll", 0) , hkZ(pastemodekey.x, "Cancel", 1)
	return

nativeCopy:
	Critical
	if WinActive("ahk_class XLMAIN")
	{
		hkZ("$^c", "nativeCopy", 0) , hkZ("$^c", "keyblocker")
		LASTCLIP := ""
		setTimer, ctrlforCopy, 50
	}
	if ini_is_duplicate_copied
		LASTCLIP := ""
	CLIP_ACTION := "COPY"
	Send, ^{vk43}
	return

nativeCut:
	Critical
	if WinActive("ahk_class XLMAIN")
	{
		hkZ("$^x", "nativeCut", 0) , hkZ("$^x", "keyblocker")
		LASTCLIP := ""
		setTimer, ctrlforCopy, 50
	}
	if ini_is_duplicate_copied
		LASTCLIP := ""
	CLIP_ACTION := "CUT"
	Send, ^{vk58}
	return

ctrlForCopy:
	if GetKeyState("Ctrl", "P") = 0		; if key is up
	{
		Critical 			;To make sure the hotkeys are changed
		hkZ("$^c", "NativeCopy") , hkZ("$^x", "NativeCut")
		SetTimer, ctrlforCopy, Off
	}
	return

Formatting:
	matched_pformat := 0 , curPformat := Trim(curPformat)
	if curPformat=
		matched_pformat := 1
	for key,value in PLUGINS["pformat"]
	{
		if matched_pformat {
			curPformat := value.name , curPfunction := value["*"] , matched_pformat := 0
			break
		}
		if ( value["name"] == curPformat )
			matched_pformat := 1
	}
	;rebuild show text
	if temp_clipboard != ""
	{
		If strlen(temp_clipboard) > 200
		{
			StringLeft,halfclip,temp_clipboard, 200
			halfClip := halfClip . "`n`n" MSG_MORE_PREVIEW
		}
		else halfClip := temp_clipboard
	}
	if matched_pformat
		curPformat := "" , curPisPreviewable := 0 ; case of switching to default
	else halfClip := (curPisPreviewable := value["Previewable"]) ? %curPfunction%(halfClip) : halfClip
	if ctrlRef = pastemode
		PasteModeTooltip(temp_clipboard) 	; rebuild prvw
	return

fixate:
	If CPS[CN.NG][realActive][FIXATE_txt]
		fixStatus := "" , CPS[CN.NG][realActive].remove(FIXATE_txt)
	else
		fixStatus := MSG_FIXED , AddClipPref(CN.NG, realActive, FIXATE_txt, 1)
	prefs_changed := 1
	PasteModeTooltip(temp_clipboard)
	return

TogglejumpClip:
	jumpClip_sign := !jumpClip_sign
	return

AddjumpClip:
	if IN_BACK
		IN_BACK_correction()
	TEMPSAVE += (!jumpClip_sign ? -Substr(A_ThisHotkey, 2)+1 : Substr(A_ThisHotkey, 2)+1)
	loop 	; as somthing like +9 could make tempsave = 17 when tempsave was 8 and the cursave is also 8
		if (TEMPSAVE>CURSAVE)
			TEMPSAVE := TEMPSAVE-CURSAVE
		else if TEMPSAVE<1
			TEMPSAVE := CURSAVE+TEMPSAVE
		else break
	gosub paste
	return

navigate_to_first:
	if IN_BACK
		IN_BACK_correction()
	TEMPSAVE := CURSAVE 		; make tempsave 29 if total clips (cursave) is 29 . so load the first (latest) clip
	gosub paste
	return

setClipTag:
	gosub endPastemode
	InputBox, ov, % TXT._tags, % TXT.TIP_tagprompt ,,,,,,,, % CPS[CN.NG][realActive]["Tags"]
	if !ErrorLevel
		AddClipPref(CN.NG, realActive, "Tags", ov), Prefs2Ini() , autoTooltip(TXT.TIP_done, 800, 2)
	else autoTooltip(TXT.TIP_cancelled, 800, 2)
	return

clipSaver() {
	FileDelete, %CLIPS_dir%/%CURSAVE%.avc
	HASCOPYFAILED := 0

	Tooltip, Processing,,, 7
	while !copied
	{
		if ( A_index=100 ) or HASCOPYFAILED {
			HASCOPYFAILED := 1
			Tooltip,,,, 7
			return
		}
		try {
			if ISACTIVEEXCEL
			{
				foolGUI(1) 										;foolGUI() is a blank gui to get focus over excel [crazy bug- crazy fix]
				tempC := ClipboardAll
				tempCB := Clipboard
				foolGUI(0)
			}
			else
				tempC := ClipboardAll

			if Substr(CN.Name, 1, 1) = "_" 		; protected channels
			{
				Critical, Off
				BeepAt(protected_DoBeep, 2000, 200)
				temp21 := TT_Console("{" CN.Name "} " TXT.TIP_confirmcopy, "Y N")
				Critical, On
			}
			if (temp21 = "Y") or (temp21 = "")
			{
				FileAppend, %tempC%, %CLIPS_dir%/%CURSAVE%.avc
				CDS[CN.NG][CURSAVE] := ISACTIVEEXCEL ? tempCB : Clipboard
				copied := 1
			}
			else LASTCLIP := "" , LASTFORMAT := "" , HASCOPYFAILED := 1 	; lastclip was not captured by cj

		} catch {
			if ISACTIVEEXCEL
				foolGUI(0)
		}
	}
	Tooltip,,,, 7
	; check for empty file
	FileRead, test, %CLIPS_dir%/%CURSAVE%.avc
	if test=
		return (HASCOPYFAILED := 1) * ablankvar 			;actually the return doesnt matter here

	manageFIXATE(CURSAVE, CN.NG, CN.N)
	return tempCB
}

manageFIXATE(clipAdded, channel, Dir_constant){
	; manages how Fixed clip are re-positioned when a new clip is added disturing the order.
	; It is necessary for the new clip to be added at Clip 1 position
	path_CLIPS := "cache\clips" Dir_constant
	path_THUMBS := "cache\thumbs" Dir_constant

	Loop, %clipAdded%
	{
		tempNo := clipAdded - A_Index + 1
		If CPS[channel][tempNo][FIXATE_txt]
		{
			t_TempNo := tempNo + 1
			FileMove, %path_CLIPS%\%t_TempNo%.avc,		%path_CLIPS%\%t_TempNo%_a.avc
			FileMove, %path_CLIPS%\%tempNo%.avc,		%path_CLIPS%\%t_TempNo%.avc
			FileMove, %path_CLIPS%\%t_TempNo%_a.avc,	%path_CLIPS%\%tempNo%.avc

			z := CDS[channel][t_TempNo] , CDS[channel][t_TempNo] := CDS[channel][tempNo] , CDS[channel][tempNo] := z
			IfExist, %path_THUMBS%\%tempNo%.jpg
			{
				FileMove, %path_THUMBS%\%t_TempNo%.jpg,	%path_THUMBS%\%t_TempNo%_a.jpg
				FileMove, %path_THUMBS%\%tempNo%.jpg,	%path_THUMBS%\%t_TempNo%.jpg
				FileMove, %path_THUMBS%\%t_TempNo%_a.jpg, %path_THUMBS%\%tempNo%.jpg
			}
			rmv := CPS[channel][t_tempNo] , CPS[channel][t_tempNo] := CPS[channel][tempNo] , CPS[channel][tempno] := rmv
			prefs_changed := 1
		}
	}
	if prefs_changed
		Prefs2Ini()
}


fixCheck() {
	If CPS[CN.NG][TEMPSAVE][FIXATE_txt]
		Return TXT.TIP_fixed
}

;Shows tooltips in Clipjump Paste Modes
PasteModeTooltip(cText, notpaste=0) {
	global
	if STORE["pstTipRebuild"] {
		Tooltip
		STORE["pstTipRebuild"] := 0
	}
	if notpaste {
		Tooltip, % cText, % SPM.X, % SPM.Y
	}
	else {
		tagText := (t := CPS[CN.NG][realActive]["Tags"]) != "" ? "(" t ")" : ""
		if cText =
			ToolTip % "{" CN.Name "} Clip " realclipno " of " CURSAVE fillWithSpaces("",7) tagText " " fixStatus 
		. (WinExist("Display_Cj") ? "" : "`n`n" MSG_ERROR "`n`n"), % SPM.X, % SPM.Y
		else
		ToolTip % "{" CN.Name "} Clip " realclipno " of " CURSAVE fillWithSpaces("",7) GetClipboardFormat() fillWithSpaces("",5) (curPformat ? "[" curPformat "]" : "") 
			. fillWithSpaces("",5) tagText " " fixstatus "`n`n" halfclip, % SPM.X, % SPM.Y
	}
}

ctrlCheck:
	if ((!GetKeyState("Ctrl")) && (!SPM.ACTIVE)) || PASTEMODE_ACT
	{
		Critical
		SetTimer, ctrlCheck, Off
		CALLER := false , sleeptime := 300 , TEMPSAVE := realActive 				; keep the current clip pos saved
		Gui, imgprv:Destroy
		; Change vars a/c MULTIPASTE
		if MULTIPASTE && !GetKeyState("Ctrl") && !temp_spmWasActive 		;if spmIsActive user is not expected to cancel by releasing Ctrl
			if ctrlRef = pastemode
				ctrlRef := "cancel"
		; ---
		if ctrlRef = cancel
		{
			ToolTip, %MSG_CANCELLED%
			sleeptime := 200
		}
		else if ctrlRef = deleteAll
		{
			Critical, Off 			;End Critical so that the below function can overlap this thread
			IScurCBACTIVE := 0 		; now not active in clipjump

			temp21 := TT_Console(TXT.TIP_delallprompt, "Y N")
			if temp21 = Y
			{
				Tooltip, %MSG_ALL_DELETED%
				clearData()
			}
			else
				Tooltip, %MSG_CANCELLED%

			Critical, On 			;Just in case this may be required.

		}
		else if ctrlRef = delete
		{
			IScurCBACTIVE := 0
			ToolTip, %MSG_DELETED%
			clearClip(realActive)
		}
		else if ctrlRef in cut,copy
		{
			Tooltip
			Critical, Off
			temp21 := choosechannelgui()
			if Instr(temp21, "-") != 1
			{
				API.manageClip( temp21 , empty, empty, ( ctrlref == "cut" ) ? 0 : 1 )
				Tooltip, % TXT.TIP_done
			}
			else Tooltip, % TXT.TIP_copycutfailed
			Critical, On
		}
		else if ctrlRef = pastemode
		{
			ToolTip, %MSG_PASTING%
			if curPformat 	;use curpf to get the func
			{
				Critical, Off
				API.blockMonitoring(1) 	; this is done to have the boomerang effect ONCLIPBOARD work.
				STORE.ClipboardChanged := 0
				try Coutput := %curPfunction%(Clipboard)
				if STORE.ClipboardChanged
					try Clipboard := Coutput , IScurCBACTIVE := 0
				else ONCLIPBOARD := 1
				API.blockMonitoring(0, 5)
				Critical, On
				Send, ^{vk56}
				sleeptime := 1
			}
			else
			{
				Send, ^{vk56}
				sleeptime := 100
			}
		}

		IN_BACK := is_pstMode_active := oldclip_exist := jumpClip_sign := 0
		hkZ_pasteMode(0)
		restoreCaller := 1 			; Restore CALLER in the ONC label . This a second line of defence wrt to the last line of this label.

		Critical, Off
		; The below thread will be interrupted when the Clipboard command is executed. The ONC label will exit as CALLER := 0 in the situtaion
		if !ini_PreserveClipPos
			TEMPSAVE := cursave 		; not preserve active clip

		if ctrlref in cancel, delete, DeleteAll
			if !IScurCBACTIVE 						;dont disturb current clipboard if it is already active
				try Clipboard := oldclip_data       ;The command opens, writes and closes clipboard . The ONCC Label is launched when writing takes place.

		sleep % sleeptime
		Tooltip

		restoreCaller := PASTEMODE_ACT := 0 	; restoreCaller - make it 0 in case Clipboard was not touched (Pasting was done)
		if !GetKeyState("Ctrl") && !SPM.ACTIVE
			MULTIPASTE := 0 		; deactivated when Ctrl released
		ctrlRef := ""
		CALLER := CALLER_STATUS
		if prefs_changed
			Prefs2Ini() 	; save preferences in memory
		EmptyMem()
	}
	return

endPastemode:
	; ends the paste abruptly - as required by export and suspend
	Gui, imgprv:Destroy
	Tooltip
	SetTimer, ctrlCheck, Off
	if SPM.ACTIVE
		gosub SPM_dispose
	if !ini_PreserveClipPos
		TEMPSAVE := cursave
	else TEMPSAVE := realActive
	API.blockMonitoring(1)
	if !IScurCBACTIVE
		try Clipboard := oldclip_data
	API.blockMonitoring(0)
	ctrlRef := "", restoreCaller := is_pstMode_active := IN_BACK := oldclip_exist := jumpClip_sign := 0
	hkZ_pasteMode(0) , CALLER := CALLER_STATUS
	if prefs_changed
		Prefs2Ini()
	EmptyMem()
	return

Ssuspnd:
	gosub endPastemode
	addToWinClip(realactive , "has Clip " realclipno)
	return

pstMode_Help:
	PasteModeTooltip(TXT.SET_shortcuts "`n" TXT.TIP_help, 1) , Tooltip_setFont("s8", "Courier New|Consolas")
	STORE["pstTipRebuild"] := 1
	return

hkZ_pasteMode(mode=0, disableAll=1){
; mode=0 is for initialising Clipjump
; mode=1 is for init Paste Mode
	Critical

	loop 9
		hkZ("^" A_index, "AddjumpClip", mode) 	; above them to allow any modifications
	hkZ("^-", "TogglejumpClip", mode)
	hkZ(pastemodekey.c, "MoveBack", mode) , hkZ(pastemodekey.x, "Cancel", mode) , hkZ(pastemodekey.z, "Formatting", mode)
	hkZ(pastemodekey.space, "Fixate", mode) , hkZ(pastemodekey.s, "Ssuspnd", mode) , hkZ(pastemodekey.e, "export", mode)
	hkZ(pastemodekey.up, "channel_up", mode) , hkZ(pastemodekey.down, "channel_down", mode) , hkZ(pastemodekey.a, "navigate_to_first", mode)
	hkZ(pastemodekey.f, "searchpm", mode) , hkZ(pastemodekey.h, "editclip", mode) , hkZ(pastemodekey.enter, "multiPaste", mode)
	hkZ(pastemodekey.t, "setClipTag", mode) , hkZ(pastemodekey.F1, "pstMode_Help", mode)

	if (!mode) && disableAll        ;init Cj
	{
		hkZ(pastemodekey.x, "DeleteAll", 0) , hkZ(pastemodekey.x, "Delete", 0)
		hkZ(pastemodekey.x, "cutclip", 0) , hkZ(pastemodekey.x, "copyclip", 0)
		hkZ("$^x", "keyblocker", 0) , hkZ("$^c", "keyblocker", 0) 			;taken as a preventive step
		hkZ("$^c", "NativeCopy") , hkZ("$^x", "NativeCut")
	}
}

;--------------------------- CHANNEL FUNCTIONS ----------------------------------------------------------------

channel_up:
	CN.NG += 2
channel_down:
	CN.NG -= 1 , correctTEMPSAVE()
	if Instr(CN.NG, "-")
		CN.NG := CN.Total-1
	else if (CN.NG == CN.Total) 		;if no of channels has exceeded
		CN.NG := 0
	changeChannel(CN.NG) , CN.pit_NG := ""
	gosub, paste
	return

pitSwap:
	if ( CN.pit_NG != "" )
	{
		changeChannel(CN.pit_NG) , CN.pit_NG := ""
		, autoTooltip("PitSwap Deactivated", 500)
		return
	}
	if (temp := channel_find("pit")) == ""
		autoTooltip("""Pit"" channel not found !", 800, 2)
	else
		CN.pit_NG := CN.NG , changeChannel(temp)
		, autoTooltip("PitSwap Activated", 500)
	return

holdClip:
	; cut - make own by clipjump custom ---- send = this, then del
	API.blockMonitoring(1) , ONCLIPBOARD := 0 , IScurCBACTIVE := 0
	Send % ( STORE.holdClip_send ? STORE.holdClip_send : "^{vk43}" )
	STORE.holdClip_send := "^{vk43}" 	; change it quickly
	while !ONCLIPBOARD
	{
		if A_Index>20
		{
			API.blockMonitoring(0)
			return
		}
		sleep 50
	}
	holdclip_continue := 1 , hkZ( ( paste_k ? "$^" paste_k : emptyvar ) , "Paste", 0) 	; disable paste mode
	try temp_cb := trygetVar("Clipboard")
	keyPressed := TT_Console(TXT.TIP_holdclip "`n`n" Substr(temp_cb, 1, 200) " ...", "Insert Esc",,,,,, 1)
	if keyPressed = Insert
	{
		try t_cb := ClipboardAll
		try Clipboard := ""
	}
	API.blockMonitoring(0)
	if keyPressed = Insert
		try Clipboard := t_cb
	hkZ( ( paste_k ? "$^" paste_k : emptyvar ) , "Paste")
	EmptyMem()
	return

;---------------     Clips management based functions       ------------------

correctTEMPSAVE(){
	TEMPSAVE += 1 		;to make active clip index be same when switching channels , counter-effects TEMPSAVE-=1 in paste_mode label.
	if in_back
		IN_BACK_correction()
	if TEMPSAVE > %CURSAVE%
		TEMPSAVE := 1
	return TEMPSAVE
}

compacter() {
	loop, %ini_Threshold%
	{
		CDS[CN.NG][A_index] := ""
		FileDelete, %A_WorkingDir%\%CLIPS_dir%\%A_Index%.avc
		FileDelete, %A_WorkingDir%\%THUMBS_dir%\%A_Index%.jpg
		CPS[CN.NG].remove(A_index)
	}
	loop % CURSAVE-ini_Threshold
	{
		avcNumber := A_Index + ini_Threshold
		CDS[CN.NG][A_index] := CDS[CN.NG][avcNumber] , CDS[CN.NG][avcNumber] := ""
		FileMove, %A_WorkingDir%/%CLIPS_dir%/%avcnumber%.avc, %A_WorkingDir%/%CLIPS_dir%/%A_Index%.avc, 1
		FileMove, %A_WorkingDir%/%THUMBS_dir%/%avcnumber%.jpg, %A_WorkingDir%/%THUMBS_dir%/%A_Index%.jpg, 1
		; Auto rmd := CPS[CN.NG].remove(avcnumber) , CPS[CN.NG][A_Index] := rmd
	}
	TEMPSAVE := CURSAVE := TOTALCLIPS - ini_Threshold
}

clearData() {
	API.emptyChannel(CN.NG)
}

clearClip(realActive) {
	LASTCLIP := ""
	CDS[CN.NG][realActive] := ""
	FileDelete, %CLIPS_dir%\%realactive%.avc
	FileDelete, %THUMBS_dir%\%realactive%.jpg
	CPS[CN.NG].remove(realActive)
	TEMPSAVE := realActive - 1
	if (TEMPSAVE == 0)
		TEMPSAVE := 1
	renameCorrect(realActive)
	CURSAVE -= 1
}

renameCorrect(realActive) {
	loopTime := CURSAVE - realactive
	loop, %loopTime%
	{
		newName := realActive
		realActive += 1
		CDS[CN.NG][newname] := CDS[CN.NG][realactive] , CDS[CN.NG][realActive] := ""
		FileMove, %CLIPS_dir%/%realactive%.avc,	 %CLIPS_dir%/%newname%.avc, 1
		FileMove, %THUMBS_dir%/%realactive%.jpg, %THUMBS_dir%/%newname%.jpg, 1
		; Auto rmv := CPS[CN.NG].remove(realActive) , CPS[CN.NG][newname] := rmv
	}
}

thumbGenerator() {
	Critical
	ClipWait, 3, 1 				;Dont need a Clipwait here , but just for special cases I put a wait of 3 secs
	Gdip_CaptureClipboard( A_WorkingDir "\" THUMBS_dir "\" CURSAVE ".jpg", ini_Quality)
}

Prefs2Ini(){
global
	loop % CN.Total
	{
		fp := "cache\clips" (A_index-1 ? A_index-1 : "")
		Obj2Ini( CPS[A_index-1] , fp "\prefs.ini" )
	}
	prefs_changed := 0
}

ClipPref_makeKeys(Ch, Cl){
	static l := "fixed|Tags"
	if !IsObject( CPS[Ch][Cl] )
		CPS[Ch][Cl] := {}
	loop, parse, l, |
		if !CPS[Ch][Cl].hasKey(A_LoopField)
			CPS[Ch][Cl][A_LoopField] := ""
}

AddClipPref(Ch, Cl, Pr, val){
	ClipPref_makeKeys(Ch, Cl)
	CPS[Ch][Cl][Pr] := val
}

;~ ;**************** GUI Functions ***************************************************************************

showPreview(){
	static scrnhgt := A_ScreenHeight / 2 , scrnwdt := A_ScreenWidth / 2
	static imagepreview

	Gui, imgprv:New
	Gui, imgprv:+LastFound +AlwaysOnTop -Caption +ToolWindow +Border
	Gui, add, picture,x0 y0 w400 h300 vimagepreview,

	if FileExist( (img := A_WorkingDir "\" THUMBS_dir "\" TEMPSAVE ".jpg") )
	{
		Gdip_getLengths(img, widthOfThumb, heightOfThumb)

		if ( heightOfThumb > scrnHgt ) or ( widthOfThumb > scrnWdt )
			displayH := heightOfThumb / 2
			, displayW := widthOfThumb / 2
		else 
			displayH := heightofthumb
			, displayW := widthOfThumb

		GuiControl, , imagepreview, *w%displayW% *h%displayH% %THUMBS_dir%\%TEMPSAVE%.jpg
		MouseGetPos, ax, ay
		ay := ay + (scrnHgt / 10)
		if (scrnwdt*2-ax < displayw/2)
			ax := 2
		if (scrnhgt*2-ay < displayh/2)
			ay := 2
		; Try ensures we dont see the error if it happens due to thread overlaps
		try Gui, imgprv:Show, x%ax% y%ay% h%displayh% w%displayw% NoActivate, Display_Cj
	}
}

historyCleanup()
;Cleans history in bunch
{
	global
	local cur_Time , temp_file_name

	if !ini_DaysToStore                    ;Dont delete old data
		return

	cur_Time := A_now
	Envadd, cur_Time, -%ini_DaysToStore%, D
	Loop, cache\history\*
	{
		temp_file_name := Substr(A_LoopFileName, 1, -4)
		EnvSub, temp_File_Name, cur_Time, S
		if temp_File_Name < 0
			FileDelete, cache\history\%A_LoopFileName%
	}
}


;----------------------- ACTION MODE ----------------------------------------------------

actionmode:
	update_actionmode()
	temp_am := TT_Console(ACTIONMODE.text, ACTIONMODE.keys, temp3, temp3, 5, "s8", "Consolas|Courier New")
	if ACTIONMODE[temp_am] != "Exit_actmd"
	{
		if Instr(ACTIONMODE[temp_am] , "(")
			RunFunc(ACTIONMODE[temp_am])
		else if ACTIONMODE[temp_am]
			gosub % ACTIONMODE[temp_am]
		else if temp_am is Integer 			; give user chance to override setting
			changeChannel(temp_am)
			, autoTooltip("Channel " temp_am " active", 800, 2)
	}
	else
		EmptyMem()
	return

init_actionmode() {
	ACTIONMODE := {H: "history", S: "channelGUI", O: "channelOrganizer", C: "copyfile", X: "copyfolder", F: "CopyFileData", D: "disable_clipjump"
		, P: "pitswap", T: "onetime", E: "settings", F1: "hlp", Esc: "Exit_actmd", M: "pluginManager_GUI()", F2: "OpenShortcutsHelp", L: "classTool"
		, H_caption: TXT.HST__name, S_caption: TXT.SET_chnl, O_caption: TXT.ORG__name, C_caption: TXT._cfilep, X_caption: TXT._cfolderp, F_caption: cfiled 
		, D_caption: TXT.ACT_disable " " PROGNAME, P_caption: TXT._pitswp, T_caption: TXT._ot, E_caption: TXT.SET__name
		, F1_caption: TXT.TRY_help, Esc_caption: TXT.ACT_exit, M_caption: TXT.PLG__name, F2_caption: TXT.try_pstmdshorts, L_caption: TXT.IGN__name}
}

update_actionmode(){
	static numadd := "0123456789"
	thetext := ""
	.  PROGNAME " " TXT.ACT__name
	. "`n-----------"
	. "`n"
	ACTIONMODE.remove("text") , ACTIONMODE.remove("keys")

	for k,v in ACTIONMODE
	if !Instr(k, "_") && (k != "Esc") && v{
		thekeys .= k " "
		thetext .= "`n" fillwithSpaces( ACTIONMODE[k "_caption"] ? ACTIONMODE[k "_caption"] : v , 35 ) " -  " k
	}
	if ACTIONMODE.Esc
		thetext .= "`n`n" fillwithSpaces( ACTIONMODE.Esc_caption ? ACTIONMODE.Esc_caption : ACTIONMODE.Esc , 35 ) " -  Esc" , thekeys .= "Esc"
	loop, parse, numadd
		thekeys .= " " A_LoopField
	ACTIONMODE.keys := Trim(thekeys)
	ACTIONMODE.text := thetext
}

;****************COPY FILE/FOLDER/DATA***************************************************************************

copyFile:
	copyMessage := MSG_FILE_PATH_COPIED
	selectedFile := GetFile()
	if ( selectedFile != "" )
		try Clipboard := selectedfile
	CopyMessage := MSG_TRANSFER_COMPLETE " {" CN.Name "}"
	return

copyFolder:
	copyMessage := MSG_FOLDER_PATH_COPIED
	openedFolder := GetFolder()
	if ( openedfolder != "" )
		try Clipboard := openedFolder
	copyMessage := MSG_TRANSFER_COMPLETE " {" CN.Name "}"
	return

CopyFileData:
	hkZ(Copyfiledata_K, "CopyFileData", 0) ;disable key for repeate copies

	selectedFile := GetFile()
	temp_extension := SubStr(selectedFile, Instr(selectedFile, ".", 0, 0)+1)

	if temp_extension in jpg,jpeg,tiff,png,bmp,gif
		Gdip_SetImagetoClipboard(selectedFile)

	else if temp_extension in cj,avc
	{
		API.blockMonitoring(1)
		try_ClipboardfromFile(selectedFile)
		ClipWait, 1, 1
		oldclip := ClipboardAll
		API.blockMonitoring(0)
		try Clipboard := oldclip
		oldclip := ""           ;The methodology is adopted due to an AHK Bug
	}
	else
	{
		FileRead, temp,% selectedFile
		try Clipboard := temp
	}

	sleep 1000
	hkZ(CopyFileData_k, "CopyFileData")
	return

;**********       Extra Functions and Labels            *******************************************************

hlp:
	if A_IsCompiled or H_Compiled
		run Clipjump.chm
	else
		run % FileExist("Clipjump.chm") ? "Clipjump.chm" : "chm_files\docs\index.html"
	return

strtup:
	Menu, Options_Tray, Togglecheck, % TXT.TRY_startup
	IfExist, %A_Startup%/Clipjump.lnk
		FileDelete, %A_Startup%/Clipjump.lnk
	else FileCreateShortcut, % H_Compiled ? A_AhkPath : A_ScriptFullPath, %A_Startup%/Clipjump.lnk
	return

updt:
	Tooltip, Checking for Updates ...... , , , 3
	URLDownloadToFile, %UPDATE_FILE%, %A_WorkingDir%/cache/latestversion.txt
	ToolTip, ,,, 3
	FileRead, temp, %A_WorkingDir%/cache/latestversion.txt
	lversion_changes := "`n`nCHANGES`n"
	loop, parse, temp, `n, `r
		if A_index=1
			latestVersion := A_LoopField
		else lversion_changes .= "`n" A_LoopField

	if !IsLatestRelease(VERSION, latestversion, "b|a")
	{
		MsgBox, 48, Clipjump Update available, % "Your Version: `t`t" VERSION "`nCurrent version: `t`t" latestVersion . lversion_changes
		IfMsgBox OK
			BrowserRun(PRODUCT_PAGE)
	}
	else MsgBox, 64, %PROGNAME%, % TXT.ABT_noupdate
	return

;************************************** Helper FUNCTIONS ****************************************

addToWinClip(lastEntry, extraTip)
{
	API.blockMonitoring()
	ToolTip, System Clipboard %extraTip%
	if CURSAVE
		try FileRead, Clipboard, *c %A_WorkingDir%/%CLIPS_dir%/%lastentry%.avc
	Sleep, 1000
	ToolTip
	API.blockMonitoring(0)
}

changeIcon(){
global

	if A_IsCompiled or H_Compiled 		; H_Compiled is a user var created if compiled with ahk_h
		Menu, tray, icon, % A_AhkPath
	else
		Menu, tray, icon, % mainIconPath
	if !NOINCOGNITO
		Menu, Tray, icon, icons\no_history.ico
	if !CALLER_STATUS or !CALLER
		Menu, Tray, icon, icons\no_monitoring.ico
}

oneTime:
	CALLER := false
	onetimeOn := 1
	autoTooltip("One Time Stop " TXT.TIP_activated, 600, 2)
	changeIcon()
	return

incognito:
	Menu, Options_Tray, Togglecheck, % TXT.TRY_incognito
	NOINCOGNITO := !NOINCOGNITO
	changeIcon()
	return

export:
	gosub endPastemode
	loop
		if !FileExist(temp := A_MyDocuments "\export" A_index ".cj")
			break
	Tooltip % "{" CN.Name "} Clip " realClipNo " " TXT._exportedto "`n" temp
	SetTimer, TooltipOff, 1000
	try FileAppend, %ClipboardAll%, % temp
	return

editclip:
	correctTEMPSAVE()
	editClip(CN.NG, CURSAVE-TEMPSAVE+1, "pstmd")
	return

editClip(cnl, clip, owner="none"){
; Opens def editor for editing a clip
	global
	local ClipLoc, EditImg, tmpsv, temp_clipboard2
	clipLoc := API.getClipLoc(cnl, clip) , tmpsv := API.getChStrength(cnl)-clip+1
	if owner != "pstmd"
	{
		API.blockMonitoring(1) 
		try_ClipboardfromFile(clipLoc) 
		API.blockMonitoring(0)
	}
	temp_clipboard := trygetVar("Clipboard")
	Tooltip, % TXT.TIP_editing,,, 10
	if owner = pstmd
	{
		IScurCBACTIVE := 1
		gosub endPastemode
	}
	EditImg := 0

	if !GetClipboardFormat()
	{
		EditImg := 1
		Gdip_CaptureClipboard(A_WorkingDir "\cache\edit.jpg", 100)
		if !FileExist("cache\edit.jpg")
		{
			autoTooltip(TXT.TIP_editnotdone, 800, 10)
			return
		}
		run, % ini_defImgEditor " """ A_WorkingDir "\cache\edit.jpg" """",,, editclip_pid
	}
	else {
		FileDelete, cache\edit.txt
		FileAppend, % temp_clipboard , cache\edit.txt
		run, % ini_defEditor " """ A_WorkingDir "\cache\edit.txt" """",,, editclip_pid
	}

	hkZ("Esc", "editclip_cancel", 1)
	Critical, Off

	loop {
		Process, Exist, % editclip_pid
		if !ErrorLevel
			break
		sleep 100
	}
	if (editclip_cancel) {
		editclip_cancel := "" , autoTooltip(TXT.TIP_editnotdone, 800, 10)
		return
	}

	if EditImg {
		API.blockMonitoring(1)
		Gdip_SetImagetoClipboard(A_WorkingDir "\cache\edit.jpg")
		ClipWait, 3, 1
		try FileAppend, %ClipboardAll%, % clipLoc
		Gdip_CaptureClipboard( A_WorkingDir "\cache\thumbs" (!cnl ? "" : cnl) "\" tmpsv ".jpg", ini_Quality)
		FileDelete, cache\edit.jpg
		API.blockMonitoring(0)
	} else {
		Fileread, temp_clipboard2, cache\edit.txt
		API.Text2Binary(temp_clipboard2, temp_clipboardall)
		FileDelete, % clipLoc
		FileAppend, % temp_clipboardall, % clipLoc
		CDS[CN.NG][tmpsv] := temp_clipboard2
	}

	autoTooltip(TXT.TIP_editdone, 800, 10)
	if owner = pstmd
		IScurCBACTIVE := false
	STORE.ErrorLevel := 1
	return EditImg ? TXT.HST_viewimage : temp_clipboard2

editclip_cancel:
	Critical, On
	editclip_cancel := 1
	hkZ("Esc", "editclip_cancel", 0)
	Process, Close, % editclip_pid
	return
}

windows_copy:
	API.blockMonitoring(1)
	Send ^{vk43}
	sleep 100
	makeClipboardAvailable(0)   ;wait till Clipboard is ready
	API.blockMonitoring(0)
	return

windows_cut:
	API.blockMonitoring(1)
	Send ^{vk58}
	sleep 100
	makeClipboardAvailable(0)
	API.blockMonitoring(0)
	return

;Copies text to a var in the script without invoking Clipjump
CopytoVar(clipwait_time=3, send_macro="^{vk43}"){
	CALLER := 0
    try oldclip := ClipboardAll
    try Clipboard := ""
    Send % send_macro
    ClipWait, % clipwait_time
    try var := Clipboard
    try Clipboard := oldclip
    CALLER := CALLER_STATUS
    return var
}

disable_clipjump:
	CLIPJUMP_STATUS := !CLIPJUMP_STATUS
	CALLER := CALLER_STATUS := CLIPJUMP_STATUS
	, hkZ("$^c", "NativeCopy", CLIPJUMP_STATUS) , hkZ("$^x", "NativeCut", CLIPJUMP_STATUS)
	changeIcon()

	hkZ( ( paste_k ? "$^" paste_k : emptyvar ) , "Paste", CLIPJUMP_STATUS)
	Menu, Options_Tray, % !CLIPJUMP_STATUS ? "Check" : "Uncheck", % TXT.TRY_disable " " PROGNAME
	init_actionmode() 			;refresh enable/disable text in action mode
	return

routines_Exit() {
	Ini_write("Clipboard_history_window", "partial", history_partial, 0)
	Prefs2Ini()
	updatePluginIncludes()
}

;#################### COMMUNICATION ##########################################

;The function enables/disables Clipjump with respect to the Communicator.
Act_CjControl(C){
	global
	local p:=0,d

	if C = 1
	{
		CALLER := CALLER_STATUS := CLIPJUMP_STATUS := 1
		, hkZ("$^c", "NativeCopy") , hkZ("$^x", "NativeCut")
		, hkZ(Copyfilepath_K, "CopyFile") , hkZ(Copyfolderpath_K, "CopyFolder"), hkZ(CopyFileData_K, "CopyFileData") 
		, hkZ(Channel_K, "channelGUI") , hkZ(onetime_K, "onetime") 
		, hkZ( ( paste_k ? "$^" paste_k : emptyvar ) , "Paste") , hkZ(history_K, "History")
		changeIcon()
		Menu, Options_Tray, UnCheck, % TXT.TRY_disable " " PROGNAME
		return
	}

	;--- Backward Compatibility
	if C<1
		C := 2+4+64
	;--- 

	if C = 1048576
		d := "2 4 8 16 32 64 128 256"
	else
		d := getParams(C)

	loop, parse, d, %A_space%
		if A_LoopField = 2
			CALLER := 0 , CALLER_STATUS := 0
			, hkZ("$^c", "NativeCopy", 0) , hkZ("$^x", "NativeCut", 0)
			, changeIcon()
		else if A_LoopField = 4
			hkZ( ( paste_k ? "$^" paste_k : emptyvar ) , "Paste", 0)
		else if A_LoopField = 8
			hkZ(Copyfilepath_K, "CopyFile", 0)
		else if A_LoopField = 16
			hkZ(Copyfolderpath_K, "CopyFolder", 0)
		else if A_LoopField = 32
			hkZ(CopyFileData_K, "CopyFileData", 0)
		else if A_LoopField = 64
			hkZ(history_K, "History", 0)
		else if A_LoopField = 128
			hkZ(Channel_K, "channelGUI", 0)
		else if A_LoopField = 256
			hkZ(onetime_K, "onetime", 0)

	if !Instr(d, "2 4")
	{
		CLIPJUMP_STATUS := 1
		Menu, Options_Tray, UnCheck, % TXT.TRY_disable " " PROGNAME
	}

}

Receive_WM_COPYDATA(wParam, lParam)
{
	global
    Local D
    static k := "API:" , cmd := "cmd:"

   D := StrGet( NumGet(lParam + 2*A_PtrSize) )  ;unicode transfer
    if D is not Integer
    	if !Instr(D, k) 	; if both are false and so the input is garbled (chinese)
    		D := StrGet( NumGet(lParam + 2*A_PtrSize), 8, "UTF-8")  ;ansi conversion
    if Instr(D, k)
    	Act_API(D, k) 	; done to not cause error if no lib is included
    else Act_CjControl(D)

    while !FileExist(A_temp "\clipjumpcom.txt")
    	FileAppend, a,% A_temp "\clipjumpcom.txt"

    EmptyMem()
    return 1
}

;##############################################################################

#Include %A_ScriptDir%\lib\Searchpastemode.ahk
#Include %A_ScriptDir%\lib\Customizer.ahk
#Include %A_ScriptDir%\lib\API.ahk
#Include %A_ScriptDir%\lib\translations.ahk
#Include %A_ScriptDir%\lib\multi.ahk
#Include %A_ScriptDir%\lib\aboutgui.ahk
#include %A_ScriptDir%\lib\TT_Console.ahk
#include %A_ScriptDir%\lib\Gdip_min.ahk
#include %A_ScriptDir%\lib\HotkeyParser.ahk
#include %A_ScriptDir%\lib\anticj_func_labels.ahk
#include %A_ScriptDir%\lib\settings gui plug.ahk
#include %A_ScriptDir%\lib\history gui plug.ahk
#include %A_ScriptDir%\lib\pluginManager.ahk
#include %A_ScriptDir%\lib\channelOrganizer.ahk
#include *i %A_ScriptDir%\plugins\_registry.ahk

;------------------------------------------------------------------- X -------------------------------------------------------------------------------