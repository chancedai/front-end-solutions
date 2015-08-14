;===Messages===
; 1 = PlaySound
; 2 = StopPlaying
; 3 = ExitApp
;=============


;===Settings============================================================================
SoundPlayerType = SubHide


;===Auto-execute========================================================================
#SingleInstance force
#NoTrayIcon
RMDir := GetHigherDir(2)
FileRead, InternalTxt, %RMDir%\Internal\Internal.txt
Loop, parse, InternalTxt, `n
{
	Field := A_LoopField
	while (SubStr(Field,1,1) = A_space or SubStr(Field,1,1) = A_Tab)
	StringTrimLeft, Field, Field, 1
	while (SubStr(Field,0,1) = A_space or SubStr(Field,0,1) = A_Tab or SubStr(Field,0,1) = "`r")
	StringTrimRight, Field, Field, 1
	if A_index = 2
	Skin := Field
}

TxtFileToRead = %RMDir%\Skins\%Skin% +\Skin definition +.txt
SearchedSound = SoundOn%SoundPlayerType%

IfExist, %TxtFileToRead%
{
	FileRead, TxtVariables, %TxtFileToRead%
	Loop, parse, TxtVariables, `n
	{
		Field := A_LoopField
		if (Field = "") 						
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

		if (var = SearchedSound)
		{
			val := SubStr(Field, EqualPos+1)		
			while (SubStr(val,1,1) = A_space or SubStr(val,1,1) = A_Tab)
			StringTrimLeft, val, val, 1
			if val is space
			val =
			SoundToPlay := val
			break
		}
	}

	if (SubStr(SoundToPlay,1,8) = "Internal")
	{
		StringTrimLeft, SoundToPlay, SoundToPlay, 8
		SoundToPlay := RMDir "\Internal\Sounds" SoundToPlay
	}
	else
	SoundToPlay = %RMDir%\Skins\%Skin% +\%SoundToPlay%
}
else ; Skin + does not exist - use default sounds
SoundToPlay := RMDir "\Internal\Sounds\" SoundPlayerType ".wav"


OnMessage(0x1001,"ReceiveMessage")
Gui 1: Show, Hide, RMSoundOn%SoundPlayerType%
EmptyMem()
Return


;===Functions===========================================================================
ReceiveMessage(Message)
{
	global SoundToPlay, SoundPlayerType
	if Message = 1 
	{
		if SoundPlayerType = Hover
		SoundPlay, %SoundToPlay%, wait
		else
		SoundPlay, %SoundToPlay%
	}
	Else if Message = 2       
	SoundPlay, ooo.ooo
	Else if Message = 3
	ExitApp
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

EmptyMem(pid="") {	; by heresy. http://www.autohotkey.com/forum/topic32876.html
	pid := (pid="") ? DllCall("GetCurrentProcessId") : pid
	h := DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
	DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", h)
}
