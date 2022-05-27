;--------------------------Start ASL
Run, ecudiag.exe, C:\Program Files (x86)\ASL\ECU Diagnostics, max
Sleep, 1000  ; 1 second

;--------------------------Set up for running IMC Var Config
CoordMode, Mouse, Client  ; Sets coordinate mode (what to use from Window Spy)
Loop, 1 ;Change Functional Address Tickbox
{
    MouseClick, left, 1345, 165
	Sleep, 500  ; 0.5 second
}
Loop, 1 ;Change Functional Address Tickbox
{
    MouseClick, left, 1425,185
	Sleep, 1000  ; 1 second
	Click, 2	;Double Click
	Sleep, 1000  ; 1 second
	Send 7A4  ; Change address to AAM
	Sleep, 1000  ; 1 second
	Click, 2	;Double Click
	Sleep, 1000  ; 1 second
	Send 7B3  ; Change address to IMC
}
	Sleep, 1000  ; 1 second
	MouseClick, left, 380,75
	Sleep, 1000  ; 1 second
	Send, IMC Variant Config v3.c{Enter}
	Sleep, 1000  ; 1 second
	MouseClick, left, 450,75
	

