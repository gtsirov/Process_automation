#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

sds_array := ["AUD4-24_JK52-18C808-DAK",	"AUD4-24_JK52-18C808-DBL",	"AUD4-24_JK52-18C808-DFJ",	"AUD4-24_JK52-18C808-DGB",	"AUD4-24_JK52-18C808-HAH",	"AUD4-24_JK52-18C808-HBJ", "AUD4-24_JK52-18C808-HFH",	"AUD4-24_JK62-18C808-DCJ",	"AUD4-24_JK62-18C808-DDL",	"AUD4-24_JK62-18C808-DEJ",	"AUD4-24_JK62-18C808-DGJ",	"AUD4-24_JK62-18C808-DHJ",	"AUD4-24_JK62-18C808-DJK",	"AUD4-24_KK52-18C808-HGB",	"AUD4-24_KK5M-18C808-DAC",	"AUD4-24_KK5M-18C808-DBB",	"AUD4-24_KK62-18C808-DLB",	"AUD4-24_P8_JK62-18C808-AAL"]

;--------------------------Set up for running IMC Var Config
CoordMode, Mouse, Client  ; Sets coordinate mode (what to use from Window Spy)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
MsgBox, 48, Notification, Let go of the mouse now!, 3
Sleep, 3000  ; 3 second

Loop % sds_array.Length()
{
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Open ASL and maximise window
	Sleep, 1000  ; 1 second
	Run, ecudiag.exe, C:\Program Files (x86)\ASL\ECU Diagnostics, max
	Sleep, 2000  ; 2 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Untick functional box
	ImageSearch, FoundX, FoundY, 1000,100, 1800,300, C:\Users\gtsirov\Documents\04_Rig_Automation\AHK\Tick_Box.gif
	if ErrorLevel = 0
	{
		MouseClick, left, 1345, 165
	}	
	Sleep, 1000  ; 1 second
	MouseClick, left, 1425,185
	Sleep, 1000  ; 1 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Change address to 7A4 (AAM address on CAN bus)
	Click, 2	;Double Click
	Sleep, 1000  ; 1 second
	Send 7A4  ; Change address to AAM
	Sleep, 1000  ; 1 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Enable logging 
	MouseClick, left, 1900,75
	Sleep, 1000  ; 1 second
	Send, % sds_array[A_Index]
	Send,_SWDL.txt{Enter}
	Sleep, 1000  ; 1 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Check if SWDL log exists and overwrite 
	IfWinExist, Log File Already Exists
		{
			WinActivate  ; Automatically uses the window found above.
			Send, {Right}
			Sleep, 1000  ; 1 second	
			Send, {Enter}
			Sleep, 1000  ; 1 second
		}	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Run SWDL
	MouseClick, left, 450,75
	Sleep, 1000  ; 1 second
	Send, % sds_array[A_Index]
	Send,{Enter}
	Sleep, 1000  ; 1 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Check for Runtime errors when opening the SWDL file
	IfWinExist, Runtime errors
		{
			WinClose ; use the window found above
			MouseClick, left, 450,75
			Sleep, 1000  ; 1 second
			Send, % sds_array[A_Index]
			Send,{Enter}
			Sleep, 1000  ; 1 second
		}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
	MsgBox, 48, Notification, SWDL is running: continue with your day!, 3
	Sleep, 1000  ; 1 second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Set flags
	SWDL_status_flag := True
	wait_for_SWDL := True
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Wait for pop-up following SWDL pass/fail	
	while wait_for_SWDL
	{
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Wait for Script pop-up SWDL pass
		IfWinExist, Script
		{
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
			MsgBox, 48, Notification, Let go of the mouse now!, 3
			Sleep, 3000  ; 3 second
			WinActivate, Script  ; Automatically uses the window found above.
			Send, {Enter}
			Sleep, 1000  ; 1 second
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Stop Logging
			MouseClick, left, 15,15
			Sleep, 1000  ; 1 second	
			MouseClick, left, 15,170
			Sleep, 1000  ; 1 second
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Close ASL		
			MouseClick, left, 1900,-15
			Sleep, 1000  ; 1 second
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Set flags
			SWDL_status_flag := True
			wait_for_SWDL := False
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
			MsgBox, 48, Notification, Functional reset in progress: script will continue in 2 minutes!, 3
			Sleep, 120000  ; 120 second	
		}
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Wait for Info pop-up SWDL fail
		IfWinExist, Info
		{
			MsgBox, 48, Notification, Let go of the mouse now!, 3
			Sleep, 3000  ; 3 second
			WinActivate, Info  ; Automatically uses the window found above.
			Send, {Right}
			Sleep, 1000  ; 1 second	
			Send, {Enter}
			Sleep, 1000  ; 1 second
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Close the OK box 
			IfWinExist, Script
				{
					WinActivate  ; Automatically uses the window found above.
					Send, {Enter}
					Sleep, 1000  ; 1 second
				}	
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Stop Logging			
			MouseClick, left, 15,15
			Sleep, 1000  ; 1 second	
			MouseClick, left, 15,170
			Sleep, 1000  ; 1 second
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Close ASL				
			MouseClick, left, 1900,-15
			Sleep, 1000  ; 1 second	
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Set flags
			SWDL_status_flag := False
			wait_for_SWDL := False
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
			MsgBox, 48, Notification, Functional reset in progress: script will continue in 2 minutes!, 3
			Sleep, 120000  ; 120 second	
		}
		FileAppend, % sds_array[A_Index] " _ " SWDL_status_flag `n, C:\Users\gtsirov\Documents\03_SW_Validation\SWDL\IVS Submission\reprot.txt
		
	}

	if (SWDL_status_flag = True)
	{
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
		MsgBox, 48, Notification, Let go of the mouse now!, 3
		Sleep, 3000  ; 3 second
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Open ASL and maximise window
		Run, SSLaunch.exe, C:\Program Files (x86)\JaguarLandRover\DTC SnapShot 5.0.2.6
		Sleep, 2000  ; 2 second
		IfWinExist, SSLaunch
			{
				WinActivate  ; Automatically uses the window found above.
			}
		MouseClick, left, 240,240
		Sleep, 1000  ; 1 second	
		MouseClick, left, 240,305
		Sleep, 1000  ; 1 second	
		MouseClick, left, 300,360
		Sleep, 1000  ; 1 second	
		MouseClick, left, 1425,185
		Sleep, 1000  ; 1 second
		Click, 2	;Double Click
		Sleep, 1000  ; 1 second
		Send 7A4  ; Change address to AAM
		MouseClick, left, 450,75
		Sleep, 1000  ; 1 second
		wait_for_DTC := True
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
		MsgBox, 48, Notification, Snapshot is running: continue with your day!, 3
		Sleep, 1000  ; 1 second
		while wait_for_DTC
		{
			IfWinExist, Question
			{
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
				MsgBox, 48, Notification, Let go of the mouse now!, 3
				Sleep, 3000  ; 3 second
				WinActivate  ; Automatically uses the window found above.
				Send, {Enter}
				wait_for_DTC := False
			}
		}
		Sleep, 1000  ; 1 second
		MouseClick, left, 1900,-15
		Sleep, 1000  ; 1 second
		wait_for_SSLaunch := True
		while wait_for_SSLaunch
		{
			IfWinExist, SSLaunch
			{
				WinActivate  ; Automatically uses the window found above.
				MouseClick, left, 410,-25
				wait_for_SSLaunch := False
			}
		}
	}
	else
	{
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;User notification 	
		MsgBox, 48, Notification, Let go of the mouse now!, 3
		Sleep, 3000  ; 3 second
	}
}