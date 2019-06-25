#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Language=1031
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; *** AutoSetup GUI ***
; *** Autor: Martin Aulenbach, Würzburg

#include <GUIConstants.au3>
#include <ProgressConstants.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#Include <Array.au3>
#include <WinAPIError.au3>
#include <GuiTreeView.au3>
#pragma compile(CompanyName, "Martin Aulenbach")
#pragma compile(FileDescription, "AutoSetup GUI")
#pragma compile(FileVersion, 1.0.0)
#pragma compile(InternalName, "Installer")
#pragma compile(LegalCopyright, "GNU GPLv3")
#pragma compile(OriginalFilename, AutoSetupGUI.exe)
#pragma compile(ProductName, "AutoSetup GUI")
#pragma compile(ProductVersion, 1.0.0)

AutoItSetOption("GUICloseOnESC", 0)
AutoItSetOption("TrayAutoPause", 0)
AutoItSetOption("TrayIconHide", 1)
AutoItSetOption("ExpandEnvStrings", 1)

Dim Const $caption                    = "AutoSetup Installer GUI"
Dim Const $version									  = "v1.0.0"
Dim Const $title										  = $caption & " " & $version
Dim Const $path_setup_files           = @ScriptDir & "\bin\"
Dim Const $setup_ini_name             = "AutoSetup.ini"

; Reg Constants
Dim Const $reg_key_hkcu_winmetrics    = "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
Dim Const $reg_key_hkcu_desktop       = "HKEY_CURRENT_USER\Control Panel\Desktop"

Dim Const $reg_val_applieddpi         = "AppliedDPI"
Dim Const $reg_val_logpixels          = "LogPixels"

; Defaults
Dim Const $msimax                     = 12
Dim Const $default_logpixels          = 96

; GUI vars
Dim $dlgheight, $txtwidth, $txtheight, $txtxoffset, $txtyoffset, $program_tree_view, $btn_start_setup, $progress, $btn_check_all, $btn_check_none
Dim $setupFolders = Null, $guilabel


Func CalcGUISize()
  Dim $reg_val

  If ( (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") _
    OR (@OSVersion = "WIN_8") OR (@OSVersion = "WIN_2012") OR (@OSVersion = "WIN_81") OR (@OSVersion = "WIN_2012R2") _
    OR (@OSVersion = "WIN_10") OR (@OSVersion = "WIN_2016") ) Then
    DllCall("user32.dll", "int", "SetProcessDPIAware")
  EndIf
  $reg_val = RegRead($reg_key_hkcu_winmetrics, $reg_val_applieddpi)
  If ($reg_val = "") Then
    $reg_val = RegRead($reg_key_hkcu_desktop, $reg_val_logpixels)
  EndIf
  If ($reg_val = "") Then
    $reg_val = $default_logpixels
  EndIf
  $dlgheight = 280 * $reg_val / $default_logpixels
  $txtwidth = 200 * $reg_val / $default_logpixels
  $txtheight = 20 * $reg_val / $default_logpixels
  $btnwidth = 80 * $reg_val / $default_logpixels
  $btnheight = 25 * $reg_val / $default_logpixels
  $txtxoffset = 10 * $reg_val / $default_logpixels
  $txtyoffset = 10 * $reg_val / $default_logpixels
  Return 0
EndFunc ;~ CalcGUISize

Func ReadFolderList()
	Local $i

	; read available folders and sort alphabetically
	$folders = _FileListToArray($path_setup_files, Default, 2)
	_ArraySort($folders)

	; build gui entries
	If IsArray($folders) Then
		Dim $setupFolders[$folders[0]+1] ; set the array size for the folder list array
		$setupFolders[0] = $folders[0] ; set the first entry to hold the count of numbers
		For $i = 1 to $folders[0]
			Local $ini_path = $path_setup_files & $folders[$i] & "\" & $setup_ini_name
			Local $bPreCheck = False

			If FileExists($ini_path) Then
				Dim $bPreCheck = IniRead($ini_path, "AutoSetup", "basicSetup", False)
			EndIf

			$setupFolders[$i] = GUICtrlCreateTreeViewItem($folders[$i], $program_tree_view) ; create tree view items
			If $bPreCheck == True Then
				GUICtrlSetState($setupFolders[$i], $GUI_CHECKED)
			EndIf
		Next
	EndIf
EndFunc ;~ ReadFolderList

Func WriteLogEntry($entry)
EndFunc ;~ WriteLogEntry

Func RunInstaller()
	Local $folder, $ini_path, $script, $script_path, $command, $current_setup_name, $exitcode

	$count = _GUICtrlTreeView_GetCount($program_tree_view)

	; ProgressBar starten
	GUICtrlSendMsg($progress, $PBM_SETMARQUEE, True, 50)

	For $i = 1 To $count
		If(_GUICtrlTreeView_GetChecked($program_tree_view, $setupFolders[$i]) == True) Then
;~ 			MsgBox(0, "isChecked", _GUICtrlTreeView_GetChecked($program_tree_view, $setupFolders[$i]) & @LF & GUICtrlRead($setupFolders[$i], 1))

			; Markierten Verzeichnisnamen auslesen
			$folder = GUICtrlRead($setupFolders[$i], 1)
			$ini_path = $path_setup_files & $folder & "\" & $setup_ini_name

			If Not FileExists($ini_path) Then ;~ Existiert die ini
				MsgBox($MB_ICONERROR, $setup_ini_name & " nicht gefunden", "Die Konfiguration für " & $folder & " wurde nicht gefunden.")
				ContinueLoop
			EndIf

			; Script zur installation aus ini lesen
			$script = IniRead($ini_path, "AutoSetup", "installer", Null)
			$script_path = $path_setup_files & $folder & "\" & $script
			; Kommando zur installation aus ini lesen
			$command = IniRead($ini_path, "AutoSetup", "command", Null)

			; Name der Installation auslesen und auf das label schreiben
			$current_setup_name = IniRead($ini_path, "AutoSetup", "clearName", $folder)
			GUICtrlSetData($guilabel, $current_setup_name)

			; installation ausführen
			If $command <> Null And $command <> "" Then ; Kommando hat Prio über das Script
				$exitcode = RunWait(@ComSpec & " /c " & $command, $path_setup_files & $folder, @SW_HIDE)
			ElseIf $script <> Null And FileExists($script_path) Then
				$exitcode = RunWait(@ComSpec & " /c " & $script, $path_setup_files & $folder, @SW_HIDE)
			Else ; Keines von beiden Methoden wurde in der Datei gefunden
				MsgBox($MB_SYSTEMMODAL, "Script nicht gefunden", "Das Skript oder Kommando zur Installation wurde nicht gefunden." & @LF & $script_path)
			EndIf
		EndIf
	Next

	; ProgressBar stoppen
	GUICtrlSendMsg($progress, $PBM_SETMARQUEE, False, 20)
	GUICtrlSendMsg($progress, $PBM_SETPOS, 0, 0)
	; Label leeren
	GUICtrlSetData($guilabel, "")
	; Info anzeigen
	MsgBox($MB_ICONINFORMATION, "Fertig", "Fertig mit der Installation.")
EndFunc ;~ RunInstaller


; Main Dialog
CalcGUISize()
$groupwidth = 2 * $txtwidth + 2 * $txtxoffset
$maindlg = GUICreate($title, $groupwidth + 4 * $txtxoffset, $dlgheight)
GUISetFont(8.5, 400, 0, "Sans Serif")

$program_tree_view = GUICtrlCreateTreeView(10, 10, $groupwidth / 2, $dlgheight - 55, $TVS_CHECKBOXES)

; alle keine buttons
$btn_check_all = GUICtrlCreateButton("Alle", 10, $dlgheight - 35, 100)
$btn_check_none = GUICtrlCreateButton("Keine", 110, $dlgheight - 35, 100)

; install button
$btn_start_setup = GUICtrlCreateButton("Auswahl installieren", $groupwidth / 2 + 20, $dlgheight - 35, $groupwidth / 2)

; install label
$guilabel = GUICtrlCreateLabel("", $groupwidth / 2 + 20, $dlgheight - 60, $groupwidth / 2, 20)

; progressbar
$progress = GUICtrlCreateProgress($groupwidth / 2 + 20, $dlgheight - 80, $groupwidth / 2, 20, $PBS_MARQUEE)

; fill available programs
ReadFolderList()


; GUI message loop
GUISetState()
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE    ; Window closed
			ExitLoop

		Case $btn_start_setup
			RunInstaller()

		Case $btn_check_all
			For $i = 1 To $setupFolders[0]
				_GUICtrlTreeView_SetChecked($program_tree_view, $setupFolders[$i])
			Next

		Case $btn_check_none
			For $i = 1 To $setupFolders[0]
				_GUICtrlTreeView_SetChecked($program_tree_view, $setupFolders[$i], False)
			Next

    EndSwitch
WEnd