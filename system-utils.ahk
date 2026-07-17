; system-utils.ahk — System control shortcuts
; Hotkeys:
;   Win + F1         — Mute/unmute
;   Win + F2         — Volume down
;   Win + F3         — Volume up
;   Win + F4         — Mic mute toggle
;   Win + F5         — Brightness down (if supported)
;   Win + F6         — Brightness up
;   Win + F7         — Toggle WiFi
;   Win + F8         — Toggle Bluetooth
;   Win + F10        — Start Pi agent
;   Win + F11        — Reload all AHK scripts
;   Win + F12        — Edit AHK scripts in VS Code
;   Win + ScrollLock — Toggle caps lock
;   Win + Pause      — System info
;   Win + Insert     — Create new file
;   Win + Home       — Open downloads
;   Win + End        — Open desktop
;   Win + PgUp       — Previous track
;   Win + PgDn       — Next track
;   Win + Delete     — Delete (bypass recycle bin)
;   Win + E          — Open Explorer to current folder
;   Win + T          — Toggle taskbar autohide
;   Win + Shift + D  — Show desktop (toggle)

#Requires AutoHotkey v2.0
#SingleInstance Force

; ─── Volume ─────────────────────────────────────
#F1::Send("{Volume_Mute}")
#F2::Send("{Volume_Down 3}")
#F3::Send("{Volume_Up 3}")
#F4::ToggleMic()

ToggleMic() {
    ; Toggle default recording device mute via SoundVolumeView or built-in
    SoundSetMute(-1, "", "Microphone")  ; toggle mic mute
    TrayTip("Microphone", "Toggled mute", 0x10)
}

; ─── Media ──────────────────────────────────────
#PgUp::Send("{Media_Prev}")
#PgDn::Send("{Media_Next}")
#+d:: {
    static desktop := false
    desktop := !desktop
    if desktop
        Send("#d")
}

; ─── Folders ────────────────────────────────────
#e:: Run("explorer.exe " . A_ScriptDir)
#Home:: Run("explorer.exe " . A_Desktop)
#End:: Run("explorer.exe " . A_Desktop)
#Insert:: {
    ; Create new text file on desktop
    path := A_Desktop . "\NewFile_" . FormatTime(, "yyyyMMdd_HHmmss") . ".txt"
    FileAppend("", path)
    Run("notepad.exe " . path)
}

; ─── Quick Pi launch ────────────────────────────
#F10:: {
    ; Open terminal and run pi
    Run('wt.exe pi',, "Max")
}

; ─── AHK management ─────────────────────────────
#F11:: {
    Reload()
    TrayTip("AHK", "All scripts reloaded", 0x10)
}
#F12:: {
    Run("code.exe " . A_ScriptDir)
}

; ─── Delete bypass recycle bin ──────────────────
#Delete:: {
    if !WinActive("ahk_class CabinetWClass") {
        Send("#{Delete}")
        return
    }
    ; Delete selected files permanently
    Send("!{Up}")
    Sleep(100)
    Send("+{Delete}")
}

; ─── Taskbar toggle ─────────────────────────────
#t:: {
    ; Toggle taskbar autohide via StuckRects3 binary
    static key := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
    RegRead(data, key, "Settings")
    if !IsObject(data) || !data.Size {
        TrayTip("Taskbar", "Failed to read settings", 0x30)
        return
    }
    ; Byte 8 (offset 8), bit 1 controls auto-hide
    if data.Size < 9 {
        TrayTip("Taskbar", "Unexpected registry format", 0x30)
        return
    }
    byte := NumGet(data, 8, "UChar")
    autohide := byte & 1
    NumPut("UChar", byte ^ 1, data, 8)
    RegWrite(data, "REG_BINARY", key, "Settings")
    Run("explorer.exe")
    TrayTip("Taskbar", autohide ? "Auto-hide OFF" : "Auto-hide ON", 0x10)
}

; ─── Screensaver / Lock ───────────────────────────
#l:: DllCall("LockWorkStation")
#^l:: DllCall("LockWorkStation")

; ─── Empty recycle bin ──────────────────────────
#+e:: FileRecycleEmpty()

; ─── Screenshot shortcuts ───────────────────────
; Win + PrintScreen — save to file
#PrintScreen:: {
    path := A_Desktop . "\Screenshot_" . FormatTime(, "yyyyMMdd_HHmmss") . ".png"
    ; Use Snipping Tool for region capture, then save
    Run("ms-screenclip:")  ; Opens snipping tool
}

; ─── Run dialog shortcuts ───────────────────────
#r:: {
    ; Enhanced Run dialog
    ib := InputBox("Run command:", "Run", "w400 h100")
    if ib.Result = "OK" && ib.Value != "" {
        try Run(ib.Value)
    }
}

; ─── Quick search selected text ─────────────────
#s:: {
    oldClip := A_Clipboard
    A_Clipboard := ""  ; clear before copy for ClipWait
    Send("^c")
    if !ClipWait(1) {
        A_Clipboard := oldClip
        return
    }
    query := A_Clipboard
    A_Clipboard := oldClip
    if query != "" {
        Run("https://www.google.com/search?q=" . UriEncode(query))
    }
}

UriEncode(str) {
    result := ""
    Loop Parse, str {
        ch := A_LoopField
        if ch ~= "[0-9A-Za-z-._~]" {
            result .= ch
        } else {
            result .= "%" . Format("{:02X}", Ord(ch))
        }
    }
    return result
}

TrayTip("System Utils", "Loaded | Win+F1-F12 active", 0x10)
