sds_array := ["AUD4-24_JK52-18C808-DAK","AUD4-24_JK52-18C808-DBL","AUD4-24_JK52-18C808-DFJ","AUD4-24_JK52-18C808-DGB","AUD4-24_JK52-18C808-HAH"]

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
	wait_for_SWDL := True
	while wait_for_SWDL
	{
		IfWinExist, Script
		{
			WinActivate  ; Automatically uses the window found above.
			Send, {Enter}
			wait_for_SWDL := FALSE
		}
	}
	MouseClick, left, 15,15
	Sleep, 1000  ; 1 second	
	MouseClick, left, 15,170
	Sleep, 1000  ; 1 second	
	MouseClick, left, 1900,-15
	Sleep, 1000  ; 1 second	
	
	Sleep, 120000  ; 120 second	
	
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