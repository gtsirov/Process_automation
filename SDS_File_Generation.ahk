#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Global variables declaration
LogFileName = %A_ScriptDir%\%A_Now%_Results_Log.txt
InputFileName = %A_ScriptDir%\Input_File.txt
assembly_var := [], sbl_var := [], app_var := [], eq_var := [], nvh_var := []

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
		MsgBox, 48, Notification, "There is vbf file(s) missing, check the Results_Log.txt for more details!"
		Exit
	}
}

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
			CollectVBFFiles(app, sbl, eq, nvh)
			cast_to_text = %A_Index% .sds files created!
		}
		LogToFile("All vbf file(s) gathered in IVS Submission folder!")
		LogToFile(cast_to_text)
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
