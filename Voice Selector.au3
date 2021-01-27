#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Timboli.

 Script Function:
	Setup and/or Toggle game voices (US/UK) and set game audio (stereo or mono).

#ce ----------------------------------------------------------------------------

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <Misc.au3>
#include <File.au3>

_Singleton("voice-selector-gogsteam")

If StringRight(@ScriptDir, 10) <> "\Normality" Then
	MsgBox(262192, "Path Error", "This program needs to be in the 'Normality' folder!", 5)
	Exit
EndIf

Global $Button_cleanup, $Button_info, $Button_mono, $Button_restore, $Button_setup, $Button_stereo, $Button_uk, $Button_usa

Global $ans, $bat, $batfile, $config, $dosbox, $height, $left, $MainGUI, $new, $normalbak, $normalfile, $normaluk
Global $normalusa, $normbak, $normfile, $normnew, $normuk, $normusa, $patch, $patchexe, $read, $res, $scard
Global $sdma, $top, $txtfile, $width

$batfile = @ScriptDir & "\NormalityUsVoices_RunMe.BAT"
$config = @ScriptDir & "\CONFIG.INI"
$dosbox = @ScriptDir & "\dosboxNORMAL.conf"
$normbak = @ScriptDir & "\NORM.EXE.BAK"
$normalbak = @ScriptDir & "\NORMAL.GOG.BAK"
$normfile = @ScriptDir & "\NORM.EXE"
$normalfile = @ScriptDir & "\NORMAL.GOG"
$normuk = @ScriptDir & "\NORM.EXE.UK"
$normaluk = @ScriptDir & "\NORMAL.GOG.UK"
$normusa = @ScriptDir & "\NORM.EXE.USA"
$normalusa = @ScriptDir & "\NORMAL.GOG.USA"
$patchexe = @ScriptDir & "\NormalityUsVoices_VPatch.exe"
$txtfile = @ScriptDir & "\NormalityUsVoices_Readme.txt"

If FileExists($batfile) Then
	$bat = 1
Else
	$bat = 4
EndIf

If FileExists($patchexe) Then
	$patch = 1
Else
	$patch = 4
EndIf

If FileExists($config) Then
	If Not FileExists($config & ".bak") Then
		FileCopy($config, $config & ".bak", 0)
	EndIf
EndIf
If FileExists($dosbox) Then
	If Not FileExists($dosbox & ".bak") Then
		FileCopy($dosbox, $dosbox & ".bak", 0)
	EndIf
EndIf

If FileExists($normbak) Then
	$ans = MsgBox(262144 + 33 + 256, "Rename Query", "It appears that you may have already used the" _
		& @LF & "'NormalityUsVoices_RunMe.BAT' file to setup" _
		& @LF & "American Voices. Or perhaps you have added" _
		& @LF & "'.BAK' manually to one or both relevant game" _
		& @LF & "files, maybe because you are using an image" _
		& @LF & "file of your game CD, etc." & @LF _
		& @LF & "WARNING - It is presumed that these '.BAK'" _
		& @LF & "files are for the original British (UK) version" _
		& @LF & "of the game, and they will be renamed that." & @LF _
		& @LF & "As in 'NORM.EXE.UK' and 'NORMAL.GOG.UK'" & @LF _
		& @LF & "Do you want to rename for use with this program?" & @LF _
		& @LF & "ADVICE - If that isn't what the '.BAK' files are, and" _
		& @LF & "you want to use this program, then change them" _
		& @LF & "to what they really are, and restart this program." & @LF _
		& @LF & "(i.e. 'NORM.EXE.USA' and 'NORMAL.GOG.USA')", 0)
	If $ans = 1 Then
		FileMove($normbak, $normuk, 0)
		If FileExists($normalbak) Then
			FileMove($normalbak, $normaluk, 0)
		EndIf
	Else
		Exit
	EndIf
EndIf

$width = 180
$height = 320
$left = Default
$top = Default
$MainGUI = GuiCreate("Voices Selector", $width, $height, $left, $top, $WS_OVERLAPPED + $WS_POPUP + $WS_CAPTION _
						  + $WS_VISIBLE + $WS_CLIPSIBLINGS + $WS_SYSMENU, $WS_EX_TOPMOST + $WS_EX_ACCEPTFILES)
; CONTROLS
$Button_usa = GUICtrlCreateButton("Enable U.S.A. Voices", 10, 10, 160, 45)
GUICtrlSetFont($Button_usa, 9, 600)
GUICtrlSetTip($Button_usa, "Use American Voices with the game!")
;
$Button_uk = GUICtrlCreateButton("Enable U.K. Voices", 10, 65, 160, 45)
GUICtrlSetFont($Button_uk, 9, 600)
GUICtrlSetTip($Button_uk, "Use British Voices with the game!")
;
$Button_stereo = GUICtrlCreateButton("STEREO", 10, 120, 81, 30)
GUICtrlSetFont($Button_stereo, 9, 600)
GUICtrlSetTip($Button_stereo, "Set game audio to be stereo!")
;
$Button_mono = GUICtrlCreateButton("MONO", 101, 120, 69, 30)
GUICtrlSetFont($Button_mono, 9, 600)
GUICtrlSetTip($Button_mono, "Set game audio to be mono!")
;
$Button_setup = GUICtrlCreateButton("SETUP VOICES", 10, 160, 160, 30)
GUICtrlSetFont($Button_setup, 9, 600)
GUICtrlSetTip($Button_setup, "Setup for use of alternate voices!")
;
$Button_cleanup = GUICtrlCreateButton("CLEANUP", 10, 200, 95, 30)
GUICtrlSetFont($Button_cleanup, 9, 600)
GUICtrlSetTip($Button_cleanup, "Cleanup (remove) the setup files!")
;
$Button_info = GUICtrlCreateButton("Info", 115, 200, 55, 30)
GUICtrlSetFont($Button_info, 9, 600)
GUICtrlSetTip($Button_info, "Program Information!")
;
$Button_restore = GUICtrlCreateButton("RESTORE to original state", 10, 240, 160, 30)
GUICtrlSetFont($Button_restore, 7, 600, 0, "Small Fonts")
GUICtrlSetTip($Button_restore, "Restore game to original state!")
;
$Button_shortcut = GUICtrlCreateButton("Create Desktop Shortcut", 10, 280, 160, 30)
GUICtrlSetFont($Button_shortcut, 7, 600, 0, "Small Fonts")
GUICtrlSetTip($Button_shortcut, "Create a desktop shortcut for this program!")
;
; SETTINGS
If $patch = 4 Then GUICtrlSetState($Button_setup, $GUI_DISABLE)
If $patch = 4 and $bat = 4 Then GUICtrlSetState($Button_cleanup, $GUI_DISABLE)
;
If FileExists($normuk) Then
	GUICtrlSetState($Button_usa, $GUI_DISABLE)
	If $patch = 1 Then GUICtrlSetState($Button_setup, $GUI_DISABLE)
ElseIf FileExists($normusa) Then
	GUICtrlSetState($Button_uk, $GUI_DISABLE)
	If $patch = 1 Then GUICtrlSetState($Button_setup, $GUI_DISABLE)
Else
	GUICtrlSetState($Button_usa, $GUI_DISABLE)
	GUICtrlSetState($Button_uk, $GUI_DISABLE)
	GUICtrlSetState($Button_restore, $GUI_DISABLE)
EndIf
;
If FileExists($config) Then
	$read = FileRead($config)
	$scard = StringSplit($read, "SoundCard=", 1)
	If $scard[0] = 2 Then
		$scard = $scard[2]
		$scard = StringSplit($scard, @CRLF, 1)
		$scard = $scard[1]
		;MsgBox(262192, "Key Value", $scard, 0, $MainGUI)
		If $scard = "0xe000" Then
			GUICtrlSetState($Button_mono, $GUI_DISABLE)
		Else
			GUICtrlSetState($Button_stereo, $GUI_DISABLE)
		EndIf
	Else
		GUICtrlSetState($Button_stereo, $GUI_DISABLE)
		GUICtrlSetState($Button_mono, $GUI_DISABLE)
	EndIf
Else
	GUICtrlSetState($Button_stereo, $GUI_DISABLE)
	GUICtrlSetState($Button_mono, $GUI_DISABLE)
EndIf

GuiSetState()
While 1
	$msg = GuiGetMsg()
	Select
	Case $msg = $GUI_EVENT_CLOSE
		; Close, Quit or Exit Program
		GUIDelete($MainGUI)
		ExitLoop
	Case $msg = $Button_usa
		; Use American Voices with the game
		If FileExists($normfile) Then
			$res = FileMove($normfile, $normuk, 0)
			If $res = 1 Then
				$res = FileMove($normusa, $normfile, 0)
				If $res = 1 Then
					If FileExists($normalfile) Then
						$res = FileMove($normalfile, $normaluk, 0)
						If $res = 1 Then
							FileMove($normalusa, $normalfile, 0)
							If $res = 0 Then
								MsgBox(262192, "Rename Error", "File could not be renamed - Part 2B.", 0, $MainGUI)
							EndIf
						Else
							MsgBox(262192, "Rename Error", "File could not be renamed - Part 2A.", 0, $MainGUI)
						EndIf
					Else
						MsgBox(262192, "Path Error", $normalfile & " cannot be found!", 0, $MainGUI)
					EndIf
				Else
					MsgBox(262192, "Rename Error", "File could not be renamed - Part 1B.", 0, $MainGUI)
				EndIf
			Else
				MsgBox(262192, "Rename Error", "File could not be renamed - Part 1A.", 0, $MainGUI)
			EndIf
			If $res = 1 Then
				GUICtrlSetState($Button_usa, $GUI_DISABLE)
				GUICtrlSetState($Button_uk, $GUI_ENABLE)
				GUIDelete($MainGUI)
				ExitLoop
			Else
				MsgBox(262192, "Rename Error", "Voices could not be changed!", 0, $MainGUI)
			EndIf
		Else
			MsgBox(262192, "Path Error", $normfile & " cannot be found!", 0, $MainGUI)
		EndIf
	Case $msg = $Button_uk
		; Use British Voices with the game
		If FileExists($normfile) Then
			$res = FileMove($normfile, $normusa, 0)
			If $res = 1 Then
				$res = FileMove($normuk, $normfile, 0)
				If $res = 1 Then
					If FileExists($normalfile) Then
						$res = FileMove($normalfile, $normalusa, 0)
						If $res = 1 Then
							$res = FileMove($normaluk, $normalfile, 0)
							If $res = 0 Then
								MsgBox(262192, "Rename Error", "File could not be renamed - Part 2B.", 0, $MainGUI)
							EndIf
						Else
							MsgBox(262192, "Rename Error", "File could not be renamed - Part 2A.", 0, $MainGUI)
						EndIf
					Else
						MsgBox(262192, "Path Error", $normalfile & " cannot be found!", 0, $MainGUI)
					EndIf
				Else
					MsgBox(262192, "Rename Error", "File could not be renamed - Part 1B.", 0, $MainGUI)
				EndIf
			Else
				MsgBox(262192, "Rename Error", "File could not be renamed - Part 1A.", 0, $MainGUI)
			EndIf
			If $res = 1 Then
				GUICtrlSetState($Button_uk, $GUI_DISABLE)
				GUICtrlSetState($Button_usa, $GUI_ENABLE)
				GUIDelete($MainGUI)
				ExitLoop
			Else
				MsgBox(262192, "Rename Error", "Voices could not be changed!", 0, $MainGUI)
			EndIf
		Else
			MsgBox(262192, "Path Error", $normfile & " cannot be found!", 0, $MainGUI)
		EndIf
	Case $msg = $Button_stereo
		; Set game audio to be stereo
		If FileExists($config) Then
			$read = FileRead($config)
			$scard = StringSplit($read, "SoundCard=", 1)
			If $scard[0] = 2 Then
				$scard = $scard[2]
				$scard = StringSplit($scard, @CRLF, 1)
				$scard = "SoundCard=" & $scard[1]
				$new = "SoundCard=" & "0xe018"
				$res = _ReplaceStringInFile($config, $scard, $new)
				If $res = 1 Then
					$sdma = StringSplit($read, "SoundDMA=", 1)
					If $sdma[0] = 2 Then
						$sdma = $sdma[2]
						$sdma = StringSplit($sdma, @CRLF, 1)
						$sdma = "SoundDMA=" & $sdma[1]
						$new = "SoundDMA=" & "5"
						$res = _ReplaceStringInFile($config, $sdma, $new)
						If $res = 1 Then
							IniWrite($dosbox, "sblaster", "sbtype", "sb16")
							GUICtrlSetState($Button_stereo, $GUI_DISABLE)
							GUICtrlSetState($Button_mono, $GUI_ENABLE)
						Else
							MsgBox(262192, "CONFIG Error", "SoundDMA value could not be changed!", 0, $MainGUI)
						EndIf
					Else
						MsgBox(262192, "CONFIG Error", "SoundDMA value not found!", 0, $MainGUI)
					EndIf
				Else
					MsgBox(262192, "CONFIG Error", "SoundCard value could not be changed!", 0, $MainGUI)
				EndIf
			Else
				MsgBox(262192, "CONFIG Error", "SoundCard value not found!", 0, $MainGUI)
			EndIf
		Else
			MsgBox(262192, "Path Error", $config & " cannot be found!", 0, $MainGUI)
		EndIf
	Case $msg = $Button_shortcut
		; Create a desktop shortcut for this program
		FileCreateShortcut(@ScriptFullPath, @DesktopDir & "\Voice Selector for Normality.lnk", @ScriptDir, "", "Toggle Game Voices (Original 0r American) for Normality.", @ScriptDir & "\goggame-1207658949.ico")
	Case $msg = $Button_setup
		; Setup for use of alternate voices
		If FileExists($patchexe) Then
			If FileExists($normalfile) Then
				If FileExists($normfile) Then
					GUICtrlSetState($Button_setup, $GUI_DISABLE)
					GUISetState(@SW_MINIMIZE, $MainGUI)
					FileChangeDir(@ScriptDir)
					RunWait(@ComSpec & " /c echo - Patching US differences into UK file (Part 1 - create new file) && NormalityUsVoices_VPatch.exe NORMAL.GOG NORMAL.NEW")
					$normnew = @ScriptDir & "\NORMAL.NEW"
					If FileExists($normnew) Then
						$res = FileMove($normalfile, $normaluk, 0)
						If $res = 1 Then
							$res = FileMove($normnew, $normalfile, 0)
							If $res = 1 Then
								RunWait(@ComSpec & " /c echo Patching US differences into UK file (Part 2 - create new file) && NormalityUsVoices_VPatch.exe NORM.EXE NORM.NEW")
								$normnew = @ScriptDir & "\NORM.NEW"
								If FileExists($normnew) Then
									$res = FileMove($normfile, $normuk, 0)
									If $res = 1 Then
										$res = FileMove($normnew, $normfile, 0)
										If $res = 1 Then
											GUICtrlSetState($Button_usa, $GUI_DISABLE)
											GUICtrlSetState($Button_uk, $GUI_ENABLE)
											GUICtrlSetState($Button_restore, $GUI_ENABLE)
										Else
											MsgBox(262192, "Rename Error", "File could not be renamed - Part 2B.", 0, $MainGUI)
										EndIf
									Else
										MsgBox(262192, "Rename Error", "File could not be renamed - Part 2A.", 0, $MainGUI)
									EndIf
								Else
									MsgBox(262192, "Process Error", "Patching appears to have failed - Part 2.", 0, $MainGUI)
									;GUICtrlSetState($Button_setup, $GUI_ENABLE)
								EndIf
							Else
								MsgBox(262192, "Rename Error", "File could not be renamed - Part 1B.", 0, $MainGUI)
							EndIf
						Else
							MsgBox(262192, "Rename Error", "File could not be renamed - Part 1A.", 0, $MainGUI)
						EndIf
					Else
						MsgBox(262192, "Process Error", "Patching appears to have failed - Part 1.", 0, $MainGUI)
						GUICtrlSetState($Button_setup, $GUI_ENABLE)
					EndIf
					GUISetState(@SW_RESTORE, $MainGUI)
				Else
					MsgBox(262192, "Path Error", $normfile & " cannot be found!", 0, $MainGUI)
				EndIf
			Else
				MsgBox(262192, "Path Error", $normalfile & " cannot be found!", 0, $MainGUI)
			EndIf
		Else
			MsgBox(262192, "Path Error", $patchexe & " cannot be found!", 0, $MainGUI)
		EndIf
	Case $msg = $Button_restore
		; Restore game to original state
		$ans = MsgBox(262144 + 33 + 256, "Restore Query - Part 1", "This process will delete the American files and" _
			& @LF & "if necessary reinstate the British ones." & @LF _
			& @LF & "Do you want to restore game to original state?", 0, $MainGUI)
		If $ans = 1 Then
			If FileExists($normusa) Then FileDelete($normusa)
			If FileExists($normalusa) Then FileDelete($normalusa)
			If FileExists($normuk) Then
				If FileExists($normfile) Then FileDelete($normfile)
				FileMove($normuk, $normfile, 1)
			EndIf
			If FileExists($normaluk) Then
				If FileExists($normalfile) Then FileDelete($normalfile)
				FileMove($normaluk, $normalfile, 1)
			EndIf
			GUICtrlSetState($Button_uk, $GUI_DISABLE)
			GUICtrlSetState($Button_usa, $GUI_DISABLE)
			If FileExists($patchexe) Then GUICtrlSetState($Button_setup, $GUI_ENABLE)
		EndIf
		$ans = MsgBox(262144 + 33 + 256, "Restore Query - Part 2", "This process will delete the Audio configuration" _
			& @LF & "files and reinstate the backup ones." & @LF _
			& @LF & "WARNING - If you have since made other" _
			& @LF & "changes to these files, then you probably" _
			& @LF & "shouldn't go ahead with this." & @LF _
			& @LF & "Do you want to restore audio to original state?", 0, $MainGUI)
		If $ans = 1 Then
			If FileExists($config & ".bak") Then
				If FileExists($config) Then FileDelete($config)
				FileMove($config & ".bak", $config, 1)
			EndIf
			If FileExists($dosbox & ".bak") Then
				If FileExists($dosbox) Then FileDelete($dosbox)
				FileMove($dosbox & ".bak", $dosbox, 1)
			EndIf
			GUICtrlSetState($Button_mono, $GUI_DISABLE)
			GUICtrlSetState($Button_stereo, $GUI_DISABLE)
		EndIf
	Case $msg = $Button_mono
		; Set game audio to be mono
		If FileExists($config) Then
			$read = FileRead($config)
			$scard = StringSplit($read, "SoundCard=", 1)
			If $scard[0] = 2 Then
				$scard = $scard[2]
				$scard = StringSplit($scard, @CRLF, 1)
				$scard = "SoundCard=" & $scard[1]
				$new = "SoundCard=" & "0xe000"
				$res = _ReplaceStringInFile($config, $scard, $new)
				If $res = 1 Then
					$sdma = StringSplit($read, "SoundDMA=", 1)
					If $sdma[0] = 2 Then
						$sdma = $sdma[2]
						$sdma = StringSplit($sdma, @CRLF, 1)
						$sdma = "SoundDMA=" & $sdma[1]
						$new = "SoundDMA=" & "1"
						$res = _ReplaceStringInFile($config, $sdma, $new)
						If $res = 1 Then
							IniWrite($dosbox, "sblaster", "sbtype", "sb1")
							GUICtrlSetState($Button_mono, $GUI_DISABLE)
							GUICtrlSetState($Button_stereo, $GUI_ENABLE)
						Else
							MsgBox(262192, "CONFIG Error", "SoundDMA value could not be changed!", 0, $MainGUI)
						EndIf
					Else
						MsgBox(262192, "CONFIG Error", "SoundDMA value not found!", 0, $MainGUI)
					EndIf
				Else
					MsgBox(262192, "CONFIG Error", "SoundCard value could not be changed!", 0, $MainGUI)
				EndIf
			Else
				MsgBox(262192, "CONFIG Error", "SoundCard value not found!", 0, $MainGUI)
			EndIf
		Else
			MsgBox(262192, "Path Error", $config & " cannot be found!", 0, $MainGUI)
		EndIf
	Case $msg = $Button_info
		; Program Information
		MsgBox(262208, "Program Information", _
			"This program can toggle between UK and USA voices for the game." & @LF & _
			"It can also set the game sound to be either Stereo or Mono (default)." & @LF & @LF & _
			"By default, the GOG and Steam versions of the game come with the" & @LF & _
			"original UK voices. Many Americans are familiar with the USA voices" & @LF & _
			"instead.   If you have the original CD with the American voices, then" & @LF & _
			"you could use that with this program if you wish to toggle between. " & @LF & _
			"Or if you have obtained the 'NormalityUsVoicesPatch.zip' (provided" & @LF & _
			"by Sweetz for GOG version), you could extract that into the game's" & @LF & _
			"main folder, then run this program there." & @LF & @LF & _
			"If patching, then click the SETUP VOICES button first and wait until" & @LF & _
			"the resulting console window processes have finished and it closes." & @LF & _
			"American Voices should now be the default, and user can change" & @LF & _
			"that at the click of a button." & @LF & @LF & _
			"Changing the audio can also be done clicking the available button." & @LF & _
			"PLEASE NOTE - This program only changes 3 values for audio, two" & @LF & _
			"in the 'CONFIG.INI' file and one only in the 'dosboxNORMAL.conf'" & @LF & _
			"file. This is all that needed to be changed with my game install. If" & @LF & _
			"it is otherwise on yours, please let me know. Other than creating" & @LF & _
			"file backups, my program does not store original data/values, so" & @LF & _
			"I do not want to mess with whatever a user's settings might be." & @LF & @LF & _
			"NOTE - The CLEANUP button removes (deletes) all files extracted" & @LF & _
			"from the 'NormalityUsVoicesPatch.zip' file ... so perhaps keep a" & @LF & _
			"backup of that zip file." & @LF & @LF & _
			"THANKS to Sweetz (patch) and Nilex (audio)." & @LF & @LF & _
			"© January 2021 - 'Voice Selector' created by Timboli.", 0, $MainGUI)
	Case $msg = $Button_cleanup
		; Cleanup (remove) the setup files
		GUICtrlSetState($Button_cleanup, $GUI_DISABLE)
		If FileExists($txtfile) Then FileDelete($txtfile)
		If FileExists($batfile) Then FileDelete($batfile)
		If FileExists($patchexe) Then FileDelete($patchexe)
		GUICtrlSetState($Button_setup, $GUI_DISABLE)
	Case Else
		;;;
	EndSelect
WEnd

Exit
