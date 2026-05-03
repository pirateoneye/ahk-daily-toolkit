; clipboard-manager.ahk — Clipboard history + formatting
; Hotkeys:
;   Win + V          — Open clipboard history
;   Win + Shift + V  — Paste as plain text
;   Win + Alt + V    — Paste as uppercase
;   Win + Ctrl + V   — Paste as lowercase
;   Win + B          — Paste as base64 (if file copied)
;   Win + Shift + B  — Decode base64 from clipboard

#Requires AutoHotkey v2.0
#SingleInstance Force

 global history := [], historyGui := "", maxHistory := 30

#v:: ShowHistory()
#+v:: PastePlain()
#!v::  PasteTransformed("upper")
#^v::  PasteTransformed("lower")
#b::   PasteBase64()
#+b::  DecodeBase64()

OnClipboardChange((*) => SaveClipboard())

SaveClipboard() {
    if !A_Clipboard || A_Clipboard = ""
        return
    ; Avoid duplicates at top
    if history.Length && history[1] = A_Clipboard
        return
    history.InsertAt(1, A_Clipboard)
    if history.Length > maxHistory
        history.Pop()
}

ShowHistory() {
    global historyGui
    historyGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Clipboard History")
    historyGui.SetFont("s12 cE6EDF3", "Consolas")
    historyGui.BackColor := "0D1117"
    lb := historyGui.AddListBox("w500 h300 vClipItem Background161B22 cE6EDF3")
    for item in history {
        preview := StrLen(item) > 60 ? SubStr(item, 1, 60) . "..." : item
        preview := StrReplace(preview, "`n", " ")  ; flatten multiline
        preview := StrReplace(preview, "`r", " ")
        preview := StrReplace(preview, "`t", " ")
        lb.Add(preview)
    }
    if history.Length
        lb.Value := 1
    lb.OnEvent("DoubleClick", (*) => PasteFromHistory())
    historyGui.OnEvent("Escape", (*) => historyGui.Destroy())
    historyGui.Show("Center w540 h340")
    ; Click paste
    historyGui.AddButton("w500", "Paste Selected (Enter)").OnEvent("Click", (*) => PasteFromHistory())
}

PasteFromHistory() {
    global historyGui
    if !historyGui return
    ctrl := historyGui["ClipItem"]
    idx := ctrl.Value
    if idx > 0 && idx <= history.Length {
        A_Clipboard := history[idx]
        Send("^v")
    }
    historyGui.Destroy()
    historyGui := ""
}

PastePlain() {
    clip := A_Clipboard
    A_Clipboard := clip
    Send("^v")
}

PasteTransform(type) {
    text := A_Clipboard
    Switch type {
        Case "upper": text := StrUpper(text)
        Case "lower": text := StrLower(text)
        Case "cap":   text := StrTitle(text)
    }
    A_Clipboard := text
    Send("^v")
}

PasteBase64() {
    path := A_Clipboard
    if !FileExist(path) {
        ; Try decode text as base64
        TrayTip("Clipboard", "Not a file path", 0x30)
        return
    }
    ; Convert file to base64
    FileObj := FileOpen(path, "r")
    buf := FileObj.RawRead(FileObj.Length)
    FileObj.Close()
    ; Simple base64 encode (AHK2 builtin via ComObj)
    base64 := EncodeBase64(buf)
    A_Clipboard := base64
    TrayTip("Clipboard", "File encoded to base64", 0x10)
}

EncodeBase64(data) {
    ; Use Windows CryptBinaryToString
    static CRYPT_STRING_BASE64 := 0x1
    if Type(data) = "String" {
        size := StrPut(data, "UTF-8")
        buf := Buffer(size)
        StrPut(data, buf, "UTF-8")
        data := buf
        dataSize := size - 1
    } else {
        dataSize := data.Size
    }
    dll := DllCall("Crypt32\CryptBinaryToStringW", "Ptr", data, "UInt", dataSize, "UInt", CRYPT_STRING_BASE64, "Ptr", 0, "UInt*", &outSize:=0)
    outBuf := Buffer(outSize * 2)
    DllCall("Crypt32\CryptBinaryToStringW", "Ptr", data, "UInt", dataSize, "UInt", CRYPT_STRING_BASE64, "Ptr", outBuf, "UInt*", &outSize)
    return StrGet(outBuf)
}

DecodeBase64() {
    text := A_Clipboard
    ; Try file path decode first
    if FileExist(text) {
        ; It's a file, read and decode
        return
    }
    ; Decode base64 string
    static CRYPT_STRING_BASE64 := 0x1
    inSize := StrPut(text, "UTF-16") - 2
    inBuf := Buffer((StrLen(text) + 1) * 2)
    StrPut(text, inBuf, "UTF-16")
    DllCall("Crypt32\CryptStringToBinaryW", "Ptr", inBuf, "UInt", 0, "UInt", CRYPT_STRING_BASE64, "Ptr", 0, "UInt*", &outSize:=0, "Ptr", 0, "Ptr", 0)
    outBuf := Buffer(outSize)
    DllCall("Crypt32\CryptStringToBinaryW", "Ptr", inBuf, "UInt", 0, "UInt", CRYPT_STRING_BASE64, "Ptr", outBuf, "UInt*", &outSize, "Ptr", 0, "Ptr", 0)
    A_Clipboard := outBuf
    TrayTip("Clipboard", "Base64 decoded", 0x10)
}
