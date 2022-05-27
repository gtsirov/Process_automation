#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

sds_array := ["AUD4-24_JK52-18C808-DAK.sds",	"AUD4-24_JK52-18C808-DBL.sds",	"AUD4-24_JK52-18C808-DFJ.sds",	"AUD4-24_JK52-18C808-DGB.sds",	"AUD4-24_JK52-18C808-HAH.sds",	"AUD4-24_JK52-18C808-HBJ.sds",	"AUD4-24_JK52-18C808-HFH.sds",	"AUD4-24_JK62-18C808-DCJ.sds",	"AUD4-24_JK62-18C808-DDL.sds",	"AUD4-24_JK62-18C808-DEJ.sds",	"AUD4-24_JK62-18C808-DGJ.sds",	"AUD4-24_JK62-18C808-DHJ.sds",	"AUD4-24_JK62-18C808-DJK.sds",	"AUD4-24_KK52-18C808-HGB.sds",	"AUD4-24_KK5M-18C808-DAC.sds",	"AUD4-24_KK5M-18C808-DBB.sds",	"AUD4-24_KK62-18C808-DLB.sds",	"AUD4-24_P8_JK62-18C808-AAL.sds"]


;--------------------------Set up for running IMC Var Config
CoordMode, Mouse, Client  ; Sets coordinate mode (what to use from Window Spy)

Loop % sds_array.Length()
{
	Sleep, 1000  ; 1 second
	Run, ecudiag.exe, C:\Program Files (x86)\ASL\ECU Diagnostics, max
	Sleep, 2000  ; 2 second
	ImageSearch, FoundX, FoundY, 1000,100, 1800,300, C:\Users\gtsirov\Documents\04_Rig_Automation\AHK\Tick_Box.gif
	if ErrorLevel = 0
	{
		MouseClick, left, 1345, 165
	}	
	Sleep, 1000  ; 1 second
	MouseClick, left, 1425,185
	Sleep, 1000  ; 1 second
	Click, 2	;Double Click
	Sleep, 1000  ; 1 second
	Send 7A4  ; Change address to AAM
	Sleep, 1000  ; 1 second
	MouseClick, left, 1900,75
	Sleep, 1000  ; 1 second
	Send, % sds_array[A_Index]
	Send,_SWDL.txt{Enter}
	Sleep, 1000  ; 1 second
	MouseClick, left, 450,75
	Sleep, 1000  ; 1 second
	Send, % sds_array[A_Index]
	Send,{Enter}
	Sleep, 1000  ; 1 second
	SWDL_status_flag := True
	wait_for_SWDL := True
	while wait_for_SWDL
	{
		IfWinExist, Info
			{
				WinActivate  ; Automatically uses the window found above.
				Send, {Right}
				Sleep, 1000  ; 1 second	
				Send, {Enter}
				wait_for_SWDL := FALSE
				Sleep, 1000  ; 1 second	
				MouseClick, left, 15,15
				Sleep, 1000  ; 1 second	
				MouseClick, left, 15,170
				Sleep, 1000  ; 1 second	
				MouseClick, left, 1900,-15
				Sleep, 1000  ; 1 second	
				SWDL_status_flag := False
				Sleep, 120000  ; 120 second	
			}
		IfWinExist, Script
		{
			WinActivate  ; Automatically uses the window found above.
			Send, {Enter}
			wait_for_SWDL := FALSE
			Sleep, 1000  ; 1 second	
			MouseClick, left, 15,15
			Sleep, 1000  ; 1 second	
			MouseClick, left, 15,170
			Sleep, 1000  ; 1 second	
			MouseClick, left, 1900,-15
			Sleep, 1000  ; 1 second	
			SWDL_status_flag := True
			Sleep, 120000  ; 120 second	
		}
	}

	if SWDL_status_flag = True
	{
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
		while wait_for_DTC
		{
			IfWinExist, Question
			{
				WinActivate  ; Automatically uses the window found above.
				Send, {Enter}
				wait_for_DTC := FALSE
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
				wait_for_SSLaunch := FALSE
			}
		}
	}	
}