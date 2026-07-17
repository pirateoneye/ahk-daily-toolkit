; launcher.ahk — Alt+Space quick launcher (like Alfred/Raycast)
; Hotkeys:
;   Alt + Space      — Open launcher
;   Esc              — Close launcher
;   Enter            — Run selected
;   Up/Down          — Navigate results
;   Type             — Filter programs / commands

#Requires AutoHotkey v2.0
#SingleInstance Force

 global launcherGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
, launcherGui.SetFont("s14 cE6EDF3", "Inter")
, launcherGui.BackColor := "0D1117"
, launcherEdit := launcherGui.AddEdit("w500 h36 cE6EDF3 Background161B22 Border vSearchText")
, launcherList := launcherGui.AddListBox("w500 h300 vResultList Background161B22 cE6EDF3")
, launcherGui.OnEvent("Close", LauncherClose)
, launcherEdit.OnEvent("Change", LauncherFilter)

; Quick commands
 global commands := [
    { name: "Explorer",        path: "explorer.exe",           icon: "📁" },
    { name: "Terminal",        path: "wt.exe",                 icon: "💻" },
    { name: "VS Code",         path: "code.exe",                 icon: "📝" },
    { name: "Chrome",          path: "chrome.exe",               icon: "🌐" },
    { name: "Task Manager",    path: "taskmgr.exe",              icon: "📊" },
    { name: "Settings",        path: "ms-settings:",             icon: "⚙" },
    { name: "Calculator",      path: "calc.exe",                 icon: "🧮" },
    { name: "Notepad",         path: "notepad.exe",              icon: "📄" },
    { name: "Pi Agent",        path: "pi",                       icon: "🤖" },
    { name: "GitHub Desktop",  path: "GitHubDesktop.exe",        icon: "🐙" },
    { name: "Docker Desktop",  path: "Docker Desktop.exe",       icon: "🐳" },
    { name: "Postman",         path: "Postman.exe",              icon: "📨" },
    { name: "Spotify",         path: "Spotify.exe",              icon: "🎵" },
    { name: "Discord",         path: "Discord.exe",              icon: "💬" },
    { name: "Lock PC",         action: "LockWorkStation",         icon: "🔒" },
    { name: "Sleep",           action: "Suspend",                 icon: "😴" },
    { name: "Shutdown",        action: "Shutdown",                icon: "🔴" },
    { name: "Restart",         action: "Restart",                 icon: "🔄" },
    { name: "Empty Recycle Bin", action: "EmptyBin",              icon: "🗑" },
]

!Space:: LauncherShow()

LauncherShow() {
    launcherEdit.Value := ""
    RefreshList(commands)
    launcherGui.Show("Center w540 h360")
    launcherEdit.Focus()
}

LauncherClose(*) {
    launcherGui.Hide()
}

LauncherFilter(*) {
    text := StrLower(launcherEdit.Value)
    if !text {
        RefreshList(commands)
        return
    }
    filtered := []
    for cmd in commands {
        if InStr(StrLower(cmd.name), text)
            filtered.Push(cmd)
    }
    RefreshList(filtered)
}

RefreshList(list) {
    opts := ""
    for cmd in list {
        display := cmd.icon . "  " . cmd.name
        opts .= (opts ? "|" : "") . display
    }
    launcherList.Delete()
    if opts
        launcherList.Add(opts)
    if list.Length
        launcherList.Value := 1

}

#HotIf WinActive("ahk_id " . launcherGui.Hwnd)
    Enter:: LauncherRun()
    Esc:: LauncherClose()
    Up::   launcherList.Value := Max(1, launcherList.Value - 1)
    Down:: launcherList.Value := Min(launcherList.Value + 1, launcherList.GetCount())
#HotIf

LauncherRun() {
    sel := launcherList.Value
    if !sel return
    text := launcherEdit.Value
    ; Map list index back to command
    filtered := []
    for cmd in commands {
        display := cmd.icon . "  " . cmd.name
        if !text || InStr(StrLower(cmd.name), StrLower(text))
            filtered.Push(cmd)
    }
    if sel > filtered.Length return
    cmd := filtered[sel]
    LauncherClose()
    if cmd.HasProp("action") {
        Switch cmd.action {
            Case "LockWorkStation": DllCall("LockWorkStation")
            Case "Suspend":        DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)
            Case "Shutdown":        Shutdown(1)
            Case "Restart":         Shutdown(2)
            Case "EmptyBin":        FileRecycleEmpty()
        }
    } else {
        try Run(cmd.path)
    }
}
