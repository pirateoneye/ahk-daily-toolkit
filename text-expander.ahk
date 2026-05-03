; text-expander.ahk — Snippet / text expansion
; Type the trigger followed by Space or Tab to expand

#Requires AutoHotkey v2.0
#SingleInstance Force

; ─── Email / Contact ────────────────────────────
:O:@@::someone@example.com
:O:@@p::personal@email.com
:O:@@w::work@company.com
:O:@@g::gmail@gmail.com

; ─── Common phrases ─────────────────────────────
:O:brb::be right back
:O:btw::by the way
:O:idk::I don't know
:O:imo::in my opinion
:O:imho::in my humble opinion
:O:fyi::for your information
:O:asap::as soon as possible
:O:tba::to be announced
:O:tbd::to be determined
:O:lg::let me know
:O:thx::thanks
:O:np::no problem
:O:omw::on my way

; ─── Dev phrases ────────────────────────────────
:O:todo::// TODO:
:O:fixme::// FIXME:
:O:hack::// HACK:
:O:bug::// BUG:
:O:note::// NOTE:
:O:review::// REVIEW:
:O:deprecated::// DEPRECATED:
:O:console::console.log();
:O:debugger::debugger;  {
:O:logerr::console.error(`Error: ${error.message}`);
:O:tryblock::
try {
    
} catch (error) {
    console.error(error);
}

; ─── Git commands ─────────────────────────────────
:O:gstatus::git status
:O:glog::git log --oneline --graph --decorate -20
:O:gdiff::git diff --stat
:O:gadd::git add .
:O:gcom::git commit -m ""
:O:gpush::git push origin main
:O:gpull::git pull origin main
:O:gstash::git stash -u
:O:gpop::git stash pop
:O:greset::git reset --soft HEAD~1
:O:gamend::git commit --amend --no-edit

; ─── Terminal / Shell ────────────────────────────
:O:lls::ls -la
:O:llsh::ls -lah
:O:grep::grep -rni "" .
:O:findf::find . -type f -name ""
:O:chmodx::chmod +x
:O:tailf::tail -f
:O:mkdirp::mkdir -p
:O:rmrf::rm -rf
:O:npmin::npm install
:O:npmr::npm run
:O:npmb::npm run build

; ─── Signatures ──────────────────────────────────
:O:sig::
Best regards,
Sugma

:O:sigc::
Cheers,
Sugma

:O:sigt::
Thanks,
Sugma

; ─── Date / Time ─────────────────────────────────
:O:date::
{
    Send(FormatTime(, "yyyy-MM-dd"))
}
:O:datetime::
{
    Send(FormatTime(, "yyyy-MM-dd HH:mm:ss"))
}
:O:time::
{
    Send(FormatTime(, "HH:mm"))
}
:O:timestamp::
{
    Send(FormatTime(, "yyyyMMddHHmmss"))
}
:O:isodate::
{
    Send(FormatTime(, "yyyy-MM-ddTHH:mm:ssZ"))
}

; ─── Lorem Ipsum ─────────────────────────────────
:O:lorem::Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

; ─── Code blocks ─────────────────────────────────
:O:jsblock::
```javascript

```

:O:tsblock::
```typescript

```

:O:pyblock::
```python

```

:O:bashblock::
```bash

```

:O:jsonblock::
```json

```

; ─── Pi shortcuts ────────────────────────────────
:O:pi::pi
:O:pir::pi --model qwen3.5:cloud
:O:pic::pi --continue
:O:pin::pi --no-session
:O:pip::pi -p

; ─── URL shortcuts ───────────────────────────────
:O:gh::https://github.com/
:O:ghn::https://github.com/notifications
:O:gist::https://gist.github.com/
:O:docs::https://docs.github.com/
:O:so::https://stackoverflow.com/search?q=
:O:mdn::https://developer.mozilla.org/search?q=
:O:npmjs::https://www.npmjs.com/package/
:O:pipy::https://pypi.org/project/

TrayTip("Text Expander", "Loaded " . GetHotkeyCount() . " snippets", 0x10)

GetHotkeyCount() {
    ; Approximate — AHK doesn't expose this easily
    return "~50"
}
