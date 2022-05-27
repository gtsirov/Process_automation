sds_array := ["AUD4-24p12_LK52-18C808-BHA", "AUD4-24p16_LK52-18C808-CHA", "AUD4-24_LK52-18C808-DHA","AUD4-24p12_LK52-18C808-FHA", "AUD4-24p16_LK52-18C808-GHA", "AUD4-24_LK52-18C808-HHA"]

;--------------------------Set up for running IMC Var Config
CoordMode, Mouse, Client  ; Sets coordinate mode (what to use from Window Spy)
i := 2
Loop % sds_array.Length()
	Run, ecudiag.exe, C:\Program Files (x86)\ASL\ECU Diagnostics, max
	Sleep, 1000  ; 1 second
	MouseClick, left, 1900,75
	Sleep, 1000  ; 1 second
	Send, % sds_array[i]
	Send,_SWDL{Enter}
	Sleep, 1000  ; 1 second
	MouseClick, left, 450,75
	Sleep, 1000  ; 1 second
	Send, % sds_array[i]
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
			return
		}
	}
	MouseClick, left, 15,15
	Sleep, 1000  ; 1 second	
	MouseClick, left, 15,170
	Sleep, 1000  ; 1 second	
	WinClose, ECU Diagnostics Tool - [X351 PP HS.etw]
	Sleep, 1000  ; 1 second	

	Run, SSLaunch.exe, C:\Program Files (x86)\JaguarLandRover\DTC SnapShot 5.0.2.6
	Sleep, 1000  ; 1 second
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
			return
		}
	}
	Sleep, 1000  ; 1 second
	WinClose, ECU Diagnostics Tool #10 - [SS5_D7A_HS.etw]
	Sleep, 1000  ; 1 second
	i := i + 1