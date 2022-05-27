#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Mouse, Client  ; Sets coordinate mode (what to use from Window Spy)
SetTitleMatchMode,2

;Global variables declaration
LogFileName = %A_ScriptDir%\%A_Now%_Results_Log.txt
InputFileName = %A_ScriptDir%\Input_File.txt
assembly_var := [], sbl_var := [], app_var := [], eq_var := [], nvh_var := []

;Main function

If FileExist("Input_File.txt")
{
	FileRead, part_numbers, Input_File.txt
	sds_array := StrSplit(part_numbers, "`n")
	var1 := sds_array.Length()
	If (mod(var1, 7) = 0)
	{
		Loop % sds_array.Length()//7
		{
			var_1 := 1 + (A_Index - 1) * 7
			assembly_var[A_Index] := sds_array[var_1]
			sbl_var[A_Index] := sds_array[var_1 + 1]
			app_var[A_Index] := sds_array[var_1 + 5]
			eq_var[A_Index] := sds_array[var_1 + 2]
			nvh_var[A_Index] := sds_array[var_1 + 3]
			
			assembly = % assembly_var[A_Index]
			StringReplace,assembly,assembly,`r,,A
			sbl = % sbl_var[A_Index]
			StringReplace,sbl,sbl,`r,,A
			app = % app_var[A_Index]
			StringReplace,app,app,`r,,A
			eq = % eq_var[A_Index]
			StringReplace,eq,eq,`r,,A
			nvh = % nvh_var[A_Index]
			StringReplace,nvh,nvh,`r,,A
			CreateSDSFile(assembly, app, sbl, eq, nvh)
			vbf_status := CollectVBFFiles(app, sbl, eq, nvh)
			if vbf_status = 1
			{
				SWDL_Fail := True
				cnt := 0
				while SWDL_Fail
				{
					SWDL_status := ExecSWDL(assembly)
					If (SWDL_status = 1)
					{
						ExecSS(assembly, app, sbl, eq, nvh)
						SWDL_Fail := False
					}
					Else
					{
						cnt := cnt + 1
						If cnt = 10
							SWDL_Fail := False
					}
				}
			}
		}
	}
	Else
	{
		MsgBox, 48, Notification, Missing part numbers or empty lines in Input_File.txt Check the file and try again !
		Exit
	}		
}
Else
{
	MsgBox, 48, Notification, Input_File.txt file does not exist in %A_WorkingDir%. Create the file and try again!
	Exit
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
MsgBox, 48, Notification, Script finished, check results!
Exit

;Log to file function declaration
LogToFile(TextToLog)
{
    global LogFileName  ; This global variable was previously given a value somewhere outside this function.
	FileAppend, 
	(
	%A_YYYY%:%A_MM%:%A_DD% - %A_Hour%:%A_Min%:%A_Sec% - %TextToLog%`n
	)
	, %LogFileName%
}

;Create .sds file function declaration
CreateSDSFile(assembly, app, sbl, eq, nvh)
{
	FileAppend,
			(
			//*****************************************************************
			// SWDLxcl.dll (1.2.2.1) 
			//
			// %assembly%
			//
			// Contact: Georgi Tsirov, gtsirov, 07384 538 450
			//
			// Please consult SWDLxcl_SDSOptions.pdf for a full list of all
			// available node options.
			//*****************************************************************
			 
			// Only compatible with TB013+
			// Global Parameters
			 
			title                               = "%assembly%";
			protocol                            = "Jaguar 11-bit";
			inhibit_tester_present              = TRUE;
			broadcast_keep_alive_net            = TRUE;
			broadcast_start_reset    			= FALSE;
			broadcast_end_reset    				= FALSE;
			broadcast_end_reset_on_fail			= FALSE;
			check_for_updates_only              = FALSE;
			force_all_updates                   = TRUE;
			rig_update_mode                     = TRUE;
			engineering_mode					= TRUE;
			 
			// Node0
			// Vehicle Identification
			//
			node
			{
			name                            	= "AAM";
			ecu_address                     	= 0x7A4;
			 
			eng_skip_vinread					= TRUE;
			eng_skip_vinread_dialog				= TRUE;
			};
			 
			// Node1
			// SWDL EQ File to AAM
			//
			node
			{
			swdl_method                     	= "SWDL004";
			name                            	= "AAM";
			ecu_address                     	= 0x7A4;
			 
			nd_security_interface           	= "AAM_X351_NGI__PROG-01";
			// Bootloader
			nd_sbl_vbf_file                 	= "%sbl%.vbf";
			 
			initial_request_number              = 3;
			receive_timeout                     = 9999;
			 
			broadcast_ignore_invalid_prgses     = TRUE;
			broadcast_delay_prgses              = 15.0;
			 
			data1_vbf_file                  	= "%app%.vbf";
			data1_part_did                  	= 0xF188;
			data1_part_ref                  	= "%app%";
			data1_part_inf                  	= "APP";
			 
			data2_vbf_file                  	= "%eq%.vbf";
			data2_part_did                  	= 0xF124;
			data2_part_ref                  	= "%eq%";
			data2_part_inf                  	= "EQ";
			 
			data3_vbf_file                  	= "%nvh%.vbf";
			data3_part_did                  	= 0xF125;
			data3_part_ref                  	= "%nvh%";
			data3_part_inf                  	= "EQ";
			 
			retry_reset_delay                   = 45.0;
			retry_start_delay                   = 0;
			};

			 
			//*****************************************************************

			quit
			), %A_ScriptDir%\IVS Submission\%assembly%.sds
}

;Create .sds file function declaration
CollectVBFFiles(app, sbl, eq, nvh)
{
	Local error_flag := True, cast_to_text ;local variables to be used inside this function
	
	IfExist, %A_ScriptDir%\VBF_dir\%app%.vbf
		FileCopy, %A_ScriptDir%\VBF_dir\%app%.vbf, %A_ScriptDir%\IVS Submission\, 1
	Else
	{
		cast_to_text = Application software file (%app%.vbf) is missing
		LogToFile(cast_to_text)
		error_flag := False
	}
	IfExist, %A_ScriptDir%\VBF_dir\%sbl%.vbf
		FileCopy, %A_ScriptDir%\VBF_dir\%sbl%.vbf, %A_ScriptDir%\IVS Submission\, 1
	Else
	{
		cast_to_text = SBL file (%sbl%).vbf is missing
		LogToFile(cast_to_text)
		error_flag := False
	}
	IfExist, %A_ScriptDir%\VBF_dir\%eq%.vbf
		FileCopy, %A_ScriptDir%\VBF_dir\%eq%.vbf, %A_ScriptDir%\IVS Submission\, 1
	Else
	{
		cast_to_text = Audio EQ calibration file (%eq%.vbf) is missing
		LogToFile(cast_to_text)
		error_flag := False
	}
	IfExist, %A_ScriptDir%\VBF_dir\%nvh%.vbf
		FileCopy, %A_ScriptDir%\VBF_dir\%nvh%.vbf, %A_ScriptDir%\IVS Submission\, 1
	Else
	{
		cast_to_text = NVH calibration file (%nvh%.vbf) is missing
		LogToFile(cast_to_text)
		error_flag := False
	}
	If (error_flag = False)
	{
		MsgBox, 48, Notification, There is vbf file(s) missing, check the Results_Log.txt for more details!, 3
	}
	Return error_flag
}

;Execude SWDL routine
ExecSWDL(assembly)
{
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
	MsgBox, 48, Notification, Let go of the mouse now!, 3
	Sleep, 2000  ; 2 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Open ASL and maximise window
	Sleep, 2000  ; 2 second
	Run, ecudiag.exe, C:\Program Files (x86)\ASL\ECU Diagnostics, max
	Sleep, 2000  ; 2 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Untick functional box
	ImageSearch, FoundX, FoundY, 1000,100, 1800,300, %A_ScriptDir%\Tick_Box.gif
	if ErrorLevel = 0
		MouseClick, left, 1345, 165
	Sleep, 2000  ; 2 second
	MouseClick, left, 1425,185
	Sleep, 2000  ; 2 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Change address to 7A4 (AAM address on CAN bus)
	Click, 2	;Double Click
	Sleep, 2000  ; 2 second
	Send 7A4  ; Change address to AAM
	Sleep, 2000  ; 2 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Enable logging 
	MouseClick, left, 1900,75
	Sleep, 2000  ; 2 second
	Send, %A_ScriptDir%\IVS Submission\%assembly%_SWDL.txt
	Sleep, 2000  ; 2 second
	Send, {Enter}
	Sleep, 5000  ; 5 seconds to accomodate potential errors popping up
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Check if SWDL log exists and overwrite 
	IfWinExist, Log File Already Exists
		{
			WinActivate, Log File Already Exists  ; Automatically uses the window found above.
			Sleep, 2000  ; 2 second	
			Send, {Right}
			Sleep, 2000  ; 2 second	
			Send, {Enter}
			Sleep, 2000  ; 2 second
		}	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Run SWDL
	MouseClick, left, 450,75
	Sleep, 2000  ; 2 second
	Send, %A_ScriptDir%\IVS Submission\%assembly%
	Sleep, 2000  ; 2 second
	Send, {Enter}
	Sleep, 5000  ; 5 seconds to accomodate potential errors popping up
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Check for Runtime errors when opening the SWDL file
	IfWinExist, Runtime errors
		{
			WinActivate, Runtime errors ; use the window found above
			MouseClick, left, 758,-22
			Sleep, 2000  ; 2 second
			Send, %A_ScriptDir%\IVS Submission\%assembly%.sds{Enter}
			Sleep, 2000  ; 2 second
		}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Check for Windows Error when opening the SWDL file
	IfWinExist, Error
		{
			WinClose, Error ; use the window found above
			MouseClick, left, 450,75
			Sleep, 2000  ; 2 second
			Send, %A_ScriptDir%\IVS Submission\%assembly%.sds{Enter}
			Sleep, 2000  ; 2 second
		}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
	MsgBox, 48, Notification, SWDL is running: continue with your day!, 3
	Sleep, 2000  ; 2 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Set flags
	SWDL_status_flag := False
	wait_for_SWDL := True
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Wait for pop-up following SWDL True/False	
	while wait_for_SWDL
	{
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Wait for Script pop-up SWDL True
		IfWinExist, Script
		{
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
			MsgBox, 48, Notification, Let go of the mouse now!, 3
			Sleep, 2000  ; 2 second
			WinActivate, Script  ; Automatically uses the window found above.
			Sleep, 2000  ; 2 second	
			Send, {Enter}
			Sleep, 2000  ; 2 second
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Stop Logging
			WinActivate, ECU Diagnostics Tool - [X351 PP HS.etw]	;Activate the ASL window before performing any actions
			Sleep, 2000  ; 2 second
			MouseClick, left, 15,15
			Sleep, 2000  ; 2 second	
			MouseClick, left, 15,170
			Sleep, 2000  ; 2 second
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Close ASL		
			MouseClick, left, 1900,-15
			Sleep, 2000  ; 2 second
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Set flags
			SWDL_status_flag := True
			wait_for_SWDL := False
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Update logs
			cast_to_text = %assembly%  _  SWDL Pass
			LogToFile(cast_to_text)
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
			MsgBox, 48, Notification, Functional reset in progress: script will continue in 147 seconds!, 3
			Sleep, 147000  ; 147 seconds	
		}
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Wait for Info pop-up SWDL False
		IfWinExist, Info
		{
			MsgBox, 48, Notification, Let go of the mouse now!, 3
			Sleep, 2000  ; 2 second
			WinActivate, Info  ; Automatically uses the window found above.
			Sleep, 2000  ; 2 second	
			Send, {Right}
			Sleep, 2000  ; 2 second	
			Send, {Enter}
			Sleep, 2000  ; 2 second
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Close the OK box 
			IfWinExist, Script
				{
					WinActivate, Script  ; Automatically uses the window found above.
					Sleep, 2000  ; 2 second	
					Send, {Enter}
					Sleep, 2000  ; 2 second
				}	
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Stop Logging
			WinActivate, ECU Diagnostics Tool - [X351 PP HS.etw]	;Activate the ASL window before performing any actions			
			Sleep, 2000  ; 2 second
			MouseClick, left, 15,15
			Sleep, 2000  ; 2 second	
			MouseClick, left, 15,170
			Sleep, 2000  ; 2 second
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Close ASL				
			MouseClick, left, 1900,-15
			Sleep, 2000  ; 2 second	
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Set flags
			SWDL_status_flag := False
			wait_for_SWDL := False
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Update logs
			cast_to_text = %assembly%  _  SWDL Fail
			LogToFile(cast_to_text)
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
			MsgBox, 48, Notification, Functional reset in progress: script will continue in 147 seconds!, 3
			Sleep, 147000  ; 147 seconds	
		}
	}
	Return SWDL_status_flag
}

;Execude SnapShot routine
ExecSS(assembly, app, sbl, eq, nvh)
{
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
	MsgBox, 48, Notification, Let go of the mouse now!, 3
	Sleep, 2000  ; 2 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Open ASL and maximise window
	Run, SSLaunch.exe, C:\Program Files (x86)\JaguarLandRover\DTC SnapShot 5.0.2.6
	Sleep, 2000  ; 2 second
	IfWinExist, SSLaunch
	{
		WinActivate, SSLaunch  ; Automatically uses the window found above.
		Sleep, 2000  ; 2 second	
	}
	MouseClick, left, 240,240
	Sleep, 2000  ; 2 second	
	MouseClick, left, 240,305
	Sleep, 2000  ; 2 second	
	MouseClick, left, 300,360
	Sleep, 2000  ; 2 second	
	MouseClick, left, 1425,185
	Sleep, 2000  ; 2 second
	Click, 2	;Double Click
	Sleep, 2000  ; 2 second
	Send 7A4  ; Change address to AAM
	MouseClick, left, 450,75
	Sleep, 2000  ; 2 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
	MsgBox, 48, Notification, Snapshot is running: continue with your day!, 3
	Sleep, 2000  ; 2 second
	wait_for_DTC := True
	while wait_for_DTC
	{
		IfWinExist, Question
		{
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
			MsgBox, 48, Notification, Let go of the mouse now!, 3
			Sleep, 2000  ; 2 second
			WinActivate, Question  ; Automatically uses the window found above.
			Sleep, 2000  ; 2 second	
			Send, {Enter}
			wait_for_DTC := False
		}
	}
	Sleep, 2000  ; 2 second
	WinActivate, ECU Diagnostics Tool #10 - [SS5_D7A_HS.etw] ; Activate the ASL window opened by SSLaunch before closing
	Sleep, 2000  ; 2 second
	MouseClick, left, 1900,-15
	Sleep, 2000  ; 2 second
	wait_for_SSLaunch := True
	time_out = 0
	while wait_for_SSLaunch
	{
		IfWinExist, SSLaunch
		{
			WinActivate, SSLaunch ; Automatically uses the window found above.
			Sleep, 2000  ; 2 second	
			MouseClick, left, 410,-25
			wait_for_SSLaunch := False
		}
		Sleep, 2000  ; 2 second
		time_out = time_out + 1
		If (time_out = 30)
		{
			cast_to_text = Warning! - Snapshot recurring window did not appear in 1 minute!
			LogToFile(cast_to_text)
			wait_for_SSLaunch := False
		}
		cast_to_text = time_out
		LogToFile(cast_to_text)
	}
	Snapshot_status_flag := False
	FileList =
	Loop, Files, C:\Users\gtsirov\Documents\SnapShot\Logs\*.txt
			FileList = %FileList%%A_LoopFileName%`n
	Loop, Parse, FileList, `n
	{
		FileRead, file_var, C:\Users\gtsirov\Documents\SnapShot\Logs\%A_LoopField%
		If InStr(file_var, nvh)
			If InStr(file_var, eq)
				If InStr(file_var, app)
				{
					FileMove, C:\Users\gtsirov\Documents\SnapShot\Logs\%A_LoopField%, %A_ScriptDir%\IVS Submission\%assembly%_Snapshot-SS5.txt
					Snapshot_status_flag := True
					cast_to_text = %assembly%  _  Snapshot Pass
					LogToFile(cast_to_text)
					break
				}
				Else
					Snapshot_status_flag := False
			Else
				Snapshot_status_flag := False
		Else
			Snapshot_status_flag := False
	}
	If (Snapshot_status_flag = False)
	{
		cast_to_text = %assembly%  _  Snapshot Fail
		LogToFile(cast_to_text)
	}
}