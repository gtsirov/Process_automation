; This script was created using Pulover's Macro Creator
; www.macrocreator.com

#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1

WinActivate,  ahk_class tooltips_class32
Sleep, 1000
WinActivate,  ahk_class Shell_TrayWnd
Sleep, 1000
WinActivate, ECU Diagnostics Tool - [X351 PP HS.etw] ahk_class TfrmMain
Sleep, 1000
ControlSend, TEdit1, {Numpad7 Down}, ECU Diagnostics Tool - [X351 PP HS.etw] ahk_class TfrmMain
Sleep, 1000
ControlSend, TEdit1, {Numpad7 Up}, ECU Diagnostics Tool - [X351 PP HS.etw] ahk_class TfrmMain
Sleep, 1000
ControlSend, TEdit1, {a Down}, ECU Diagnostics Tool - [X351 PP HS.etw] ahk_class TfrmMain
Sleep, 1000
ControlSend, TEdit1, {a Up}, ECU Diagnostics Tool - [X351 PP HS.etw] ahk_class TfrmMain
Sleep, 1000
ControlSend, TEdit1, {Numpad4 Down}, ECU Diagnostics Tool - [X351 PP HS.etw] ahk_class TfrmMain
Sleep, 1000
ControlSend, TEdit1, {Numpad4 Up}, ECU Diagnostics Tool - [X351 PP HS.etw] ahk_class TfrmMain