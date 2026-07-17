#Requires AutoHotkey v2.0
#SingleInstance Force

startupDir := A_AppData . "\Microsoft\Windows\Start Menu\Programs\Startup"
linkPath := startupDir . "\Daily-AHK-Toolkit.lnk"
try {
    shell := ComObject("WScript.Shell")
    shortcut := shell.CreateShortcut(linkPath)
    shortcut.TargetPath := A_ScriptDir . "\run-all.ahk"
    shortcut.WorkingDirectory := A_ScriptDir
    shortcut.Description := "Daily AHK Toolkit"
    shortcut.Save()
    TrayTip("Daily AHK Toolkit", "Added to startup.", 0x10)
} catch as e {
    MsgBox("Failed to create startup shortcut:`n" . e.Message, "Setup Error", "Icon!")
}
