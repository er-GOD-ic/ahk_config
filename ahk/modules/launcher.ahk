; ====================================================================================================
; Win + Space : Powershell
; Win + B : Browser
; ====================================================================================================

#Space::{
    ; run PowerShell as user $home
    Run "schtasks /Run /TN `"RunPowerShellAsUser`"", , "Hide"
}

#b::{
    ; get ProgId 
    progId := RegRead(
        "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice",
        "ProgId"
    )

    ; get cmd
    cmd := RegRead(
        "HKEY_CLASSES_ROOT\" progId "\shell\open\command",
        ""
    )

    ; execute
    if RegExMatch(cmd, '"([^"]+)"', &m) {
        exe := m[1]
        Run exe
    } else {
        Run cmd
    }
}
