; window-manager.ahk — Advanced window management for Windows
; Hotkeys:
;   Win + Arrow      — Snap to halves/quarters
;   Win + Shift + Arrow — Move to monitor
;   Win + Numpad     — Snap to grid positions
;   Win + Ctrl + T   — Toggle always on top
;   Win + Ctrl + V   — Toggle transparency
;   Win + Escape     — Minimize all but active
;   Win + `          — Toggle window centering
;   Win + Shift + M  — Maximize/restore toggle
;   Win + Shift + R  — Reset window position
;   Win + WheelUp    — Increase window opacity
;   Win + WheelDown  — Decrease window opacity
;   Win + X          — Close current window
;   Win + Shift + X  — Kill current window process

#Requires AutoHotkey v2.0
#SingleInstance Force

global snapMargin := 8

global monitorCount := MonitorGetCount()

; ─── Snap to halves ──────────────────────────
#Up::    WinMaximize("A")
#Down::  WinMinimize("A")
#Left::  Snap("left")
#Right:: Snap("right")

Snap(side) {
    hwnd := WinGetID("A")
    if !hwnd return
    mon := WinGetMonitor(hwnd)
    mg := MonitorGetWorkArea(mon)
    w := (mg.Right - mg.Left - snapMargin * 3) // 2
    h := mg.Bottom - mg.Top - snapMargin * 2
    x := side = "left" ? mg.Left + snapMargin : mg.Left + w + snapMargin * 2
    WinMove(x, mg.Top + snapMargin, w, h, hwnd)
}

; ─── Quarter snapping ─────────────────────────
#Numpad7:: SnapQuarter("tl")   ; top-left
#Numpad9:: SnapQuarter("tr")   ; top-right
#Numpad1:: SnapQuarter("bl")   ; bottom-left
#Numpad3:: SnapQuarter("br")   ; bottom-right
#Numpad5:: WinMaximize("A")    ; center/maximize
#Numpad4:: Snap("left")         ; left half
#Numpad6:: Snap("right")        ; right half
#Numpad8:: SnapQuarter("top")   ; top half
#Numpad2:: SnapQuarter("bot")   ; bottom half

SnapQuarter(pos) {
    hwnd := WinGetID("A")
    if !hwnd return
    mon := WinGetMonitor(hwnd)
    mg := MonitorGetWorkArea(mon)
    w := (mg.Right - mg.Left - snapMargin * 3) // 2
    h := (mg.Bottom - mg.Top - snapMargin * 3) // 2
    Switch pos {
        Case "tl": x := mg.Left + snapMargin,           y := mg.Top + snapMargin
        Case "tr": x := mg.Left + w + snapMargin * 2,  y := mg.Top + snapMargin
        Case "bl": x := mg.Left + snapMargin,           y := mg.Top + h + snapMargin * 2
        Case "br": x := mg.Left + w + snapMargin * 2,   y := mg.Top + h + snapMargin * 2
        Case "top": w := mg.Right - mg.Left - snapMargin * 2, h := h, x := mg.Left + snapMargin, y := mg.Top + snapMargin
        Case "bot": w := mg.Right - mg.Left - snapMargin * 2, h := h, x := mg.Left + snapMargin, y := mg.Top + h + snapMargin * 2
    }
    WinMove(x, y, w, h, hwnd)
}

; ─── Move window between monitors ─────────────
#+Left::  MoveToMonitor(-1)
#+Right:: MoveToMonitor(+1)

MoveToMonitor(dir) {
    hwnd := WinGetID("A")
    if !hwnd return
    curMon := WinGetMonitor(hwnd) + dir
    if curMon < 1 || curMon > monitorCount {
        SoundBeep(800, 100)
        return
    }
    mg := MonitorGetWorkArea(curMon)
    WinMove(mg.Left + 100, mg.Top + 100, 800, 600, hwnd)
}

WinGetMonitor(hwnd) {
    WinGetPos(&x, &y,,, hwnd)
    cx := x + 400, cy := y + 300
    Loop monitorCount {
        mg := MonitorGetWorkArea(A_Index)
        if (cx >= mg.Left && cx <= mg.Right && cy >= mg.Top && cy <= mg.Bottom)
            return A_Index
    }
    return 1
}

; ─── Always on top ────────────────────────────
#^t:: {
    hwnd := WinGetID("A")
    ex := WinGetExStyle(hwnd)
    if (ex & 0x8) {
        WinSetAlwaysOnTop(0, hwnd)
        TrayTip("Always on Top", "Disabled", 0x10)
    } else {
        WinSetAlwaysOnTop(1, hwnd)
        TrayTip("Always on Top", "Enabled", 0x10)
    }
}

; ─── Transparency ───────────────────────────────
#^v:: {
    static transMap := Map()
    hwnd := WinGetID("A")
    cur := transMap.Has(hwnd) ? transMap[hwnd] : 255
    newTrans := cur = 255 ? 180 : 255
    transMap[hwnd] := newTrans
    WinSetTransparent(newTrans, hwnd)
    TrayTip("Transparency", newTrans = 255 ? "Normal" : "Glass (" . newTrans . ")", 0x10)
}

#WheelUp::   AdjustTransparency(+15)
#WheelDown:: AdjustTransparency(-15)

AdjustTransparency(delta) {
    static transMap := Map()
    hwnd := WinGetID("A")
    cur := transMap.Has(hwnd) ? transMap[hwnd] : 255
    newTrans := Min(255, Max(50, cur + delta))
    transMap[hwnd] := newTrans
    WinSetTransparent(newTrans, hwnd)
}

; ─── Minimize all but active ──────────────────
#Escape:: {
    active := WinGetID("A")
    ids := WinGetList(,, "Program Manager")
    for hwnd in ids {
        if hwnd != active && WinGetMinMax(hwnd) != -1
            WinMinimize(hwnd)
    }
}

; ─── Center window ──────────────────────────────
#`:: {
    hwnd := WinGetID("A")
    mg := MonitorGetWorkArea(WinGetMonitor(hwnd))
    WinGetPos(,, &w, &h, hwnd)
    x := mg.Left + ((mg.Right - mg.Left) - w) // 2
    y := mg.Top + ((mg.Bottom - mg.Top) - h) // 2
    WinMove(x, y,,, hwnd)
}

; ─── Maximize toggle ────────────────────────────
#+m:: {
    if WinGetMinMax("A") = 1
        WinRestore("A")
    else
        WinMaximize("A")
}

; ─── Reset position ─────────────────────────────
#+r:: {
    hwnd := WinGetID("A")
    mg := MonitorGetWorkArea(WinGetMonitor(hwnd))
    WinMove(mg.Left + 100, mg.Top + 100, 1000, 700, hwnd)
}

; ─── Close / Kill window ────────────────────────
#x:: WinClose("A")
#+x:: {
    pid := WinGetPID("A")
    ProcessClose(pid)
    TrayTip("Process Killed", "PID: " . pid, 0x10)
}

; ─── Resize with mouse (hold Win + RMB drag) ──
#RButton:: {
    hwnd := WinGetID("A")
    SetWinDelay(-1)
    MouseGetPos(&mx, &my)
    WinGetPos(&wx, &wy, &ww, &wh, hwnd)
    Loop {
        if !GetKeyState("RButton", "P") break
        MouseGetPos(&cx, &cy)
        nw := Max(200, ww + (cx - mx))
        nh := Max(150, wh + (cy - my))
        WinMove(wx, wy, nw, nh, hwnd)
        Sleep(16)
    }
}

; ─── Move with mouse (hold Win + MMB drag) ──────
#MButton:: {
    hwnd := WinGetID("A")
    SetWinDelay(-1)
    MouseGetPos(&mx, &my)
    WinGetPos(&wx, &wy,,, hwnd)
    Loop {
        if !GetKeyState("MButton", "P") break
        MouseGetPos(&cx, &cy)
        WinMove(wx + (cx - mx), wy + (cy - my),,, hwnd)
        Sleep(16)
    }
}

; ─── Startup ────────────────────────────────────
TrayTip("Window Manager", "Loaded | Hotkeys active", 0x10)
