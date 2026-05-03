; pomodoro.ahk — Focus timer with break reminders
; Hotkeys:
;   Win + Shift + P  — Start/pause pomodoro
;   Win + Alt + P    — Reset timer
;   Win + Ctrl + P   — Open timer window

#Requires AutoHotkey v2.0
#SingleInstance Force

global gTimer := 25 * 60
global gTotal := 25 * 60
global gRunning := false
global gMode := "work"  ; work | short | long
global gPomodoros := 0
global gGui := ""
global gTimerLabel := ""

gWorkTime := 25 * 60
gShortBreak := 5 * 60
gLongBreak := 15 * 60

#+p:: ToggleTimer()
#!p::  ResetTimer()
#^p::  ShowTimer()

ToggleTimer() {
    global gRunning
    if gRunning {
        gRunning := false
        SetTimer(UpdateTimer, 0)
        if gGui
            UpdateTitle("⏸ Paused")
    } else {
        gRunning := true
        SetTimer(UpdateTimer, 1000)
        ShowTimer()
        if gGui
            UpdateTitle("▶ Running")
    }
}

ResetTimer() {
    global gRunning, gTimer, gTotal, gMode, gPomodoros
    gRunning := false
    SetTimer(UpdateTimer, 0)
    Switch gMode {
        Case "work": gTimer := gWorkTime, gTotal := gWorkTime
        Case "short": gTimer := gShortBreak, gTotal := gShortBreak
        Case "long": gTimer := gLongBreak, gTotal := gLongBreak
    }
    UpdateDisplay()
    UpdateTitle("⏹ Reset")
}

ShowTimer() {
    global gGui, gTimerLabel
    if gGui && WinExist("ahk_id " . gGui.Hwnd) {
        WinActivate()
        return
    }
    gGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Pomodoro")
    gGui.BackColor := "0D1117"
    gGui.SetFont("s48 cE6EDF3", "Inter")
    gTimerLabel := gGui.AddText("w300 Center vTimerText", FormatTime(gTimer))
    gGui.SetFont("s12 c8B949E")
    gGui.AddText("w300 Center", "Mode: " . StrTitle(gMode) . " | Completed: " . gPomodoros)
    gGui.SetFont("s11")
    btnRow := gGui.AddText("w300 Center")
    gGui.AddButton("w90", "▶ Start").OnEvent("Click", (*) => ToggleTimer())
    gGui.AddButton("w90 x+8", "⏹ Reset").OnEvent("Click", (*) => ResetTimer())
    gGui.AddButton("w90 x+8", "✕ Close").OnEvent("Click", (*) => gGui.Destroy())
    gGui.OnEvent("Escape", (*) => gGui.Destroy())
    gGui.Show("Center w340 h200")
    UpdateDisplay()
}

FormatTime(seconds) {
    m := seconds // 60
    s := Mod(seconds, 60)
    return Format("{:02d}:{:02d}", m, s)
}

UpdateTimer() {
    global gTimer, gRunning, gMode, gPomodoros
    if !gRunning return
    gTimer--
    if gTimer <= 0 {
        gRunning := false
        SetTimer(UpdateTimer, 0)
        CompletePomodoro()
        return
    }
    UpdateDisplay()
    ; Progress bar in title
    pct := Round((1 - gTimer / gTotal) * 100)
    UpdateTitle("▶ " . FormatTime(gTimer) . " (" . pct . "%)"   )
}

UpdateDisplay() {
    global gTimerLabel
    if gTimerLabel
        gTimerLabel.Value := FormatTime(gTimer)
}

UpdateTitle(text) {
    global gGui
    if gGui
        gGui.Title := "Pomodoro — " . text
}

CompletePomodoro() {
    global gMode, gPomodoros, gTimer, gTotal
    SoundBeep(800, 500)
    SoundBeep(1000, 500)
    if gMode = "work" {
        gPomodoros++
        if Mod(gPomodoros, 4) = 0 {
            gMode := "long"
            gTimer := gLongBreak
            gTotal := gLongBreak
            MsgBox("Long break time! (15 min)", "Pomodoro Complete", 0x40)
        } else {
            gMode := "short"
            gTimer := gShortBreak
            gTotal := gShortBreak
            MsgBox("Short break time! (5 min)", "Pomodoro Complete", 0x40)
        }
    } else {
        gMode := "work"
        gTimer := gWorkTime
        gTotal := gWorkTime
        MsgBox("Break over. Back to work! (25 min)", "Break Complete", 0x40)
    }
    UpdateDisplay()
    UpdateTitle("⏹ Ready")
    ShowTimer()
}

TrayTip("Pomodoro", "Win+Shift+P to start | Work 25m / Short 5m / Long 15m", 0x10)
