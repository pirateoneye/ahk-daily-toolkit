# AHK Daily Toolkit

AutoHotkey v2 scripts for serious Windows power users.

## Scripts

| Script | What it does |
|--------|-------------|
| `window-manager.ahk` | Win+Arrow snap halves, quarter grid, multi-monitor move, transparency, always-on-top, resize with mouse |
| `launcher.ahk` | Alt+Space quick launcher for apps, Pi agent, system actions |
| `clipboard-manager.ahk` | Win+V history (30 items), paste plain text, base64 encode/decode |
| `text-expander.ahk` | ~50 text snippets: emails, git, dev, dates, code blocks, URLs |
| `system-utils.ahk` | Volume hotkeys, Pi launch (Win+F10), AHK reload, quick search, run dialog |
| `pomodoro.ahk` | 25/5/15 focus timer with notifications |

## Install

1. Install [AutoHotkey v2](https://www.autohotkey.com/)
2. Double-click scripts or add to startup:
   ```autohotkey
   ; Add to Windows startup
   shell:startup
   ```
3. Or run all at once:
   ```bash
   # Create master runner
   ahk2.exe window-manager.ahk
   ahk2.exe launcher.ahk
   ahk2.exe clipboard-manager.ahk
   ahk2.exe text-expander.ahk
   ahk2.exe system-utils.ahk
   ahk2.exe pomodoro.ahk
   ```

## Must-have Hotkeys

| Hotkey | Action |
|--------|--------|
| `Win+Arrow` | Snap window halves |
| `Win+Numpad 1/3/7/9` | Quarter snap |
| `Win+Shift+Arrow` | Move to monitor |
| `Win+^T` | Toggle always on top |
| `Alt+Space` | App launcher |
| `Win+V` | Clipboard history |
| `Win+Shift+V` | Paste plain text |
| `Win+F10` | Launch Pi agent |
| `Win+Shift+P` | Start pomodoro |
| `@@` | Expand email |
| `todo` | Expand `// TODO:` |
| `glog` | Expand `git log --oneline --graph` |
