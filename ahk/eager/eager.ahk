#Requires AutoHotkey v2.0

#Include .\IMEv2.ahk

; ============================================
; 基本設定
; ============================================

SetWorkingDir A_ScriptDir
SetCapsLockState "AlwaysOff"

; ============================================
; VirtualDesktopAccessor.dll 初期化
; ============================================

GetDllBitness(path) {
    f := FileOpen(path, "r")
    if !f
        return "file open failed"

    ; DOS header
    f.Pos := 0x3C
    peOffset := f.ReadUInt()

    ; PE signature + Machine
    f.Pos := peOffset + 4
    machine := f.ReadUShort()
    f.Close()

    return machine = 0x8664 ? "64-bit"
         : machine = 0x014C ? "32-bit"
         : Format("unknown (0x{:04X})", machine)
}

dllPath := A_TEMP "\VirtualDesktopAccessor.dll"
FileInstall "VirtualDesktopAccessor.dll", dllPath, 1

hvda := DllCall("LoadLibrary", "Str", dllPath, "Ptr")
if !hvda {
    errorCode := DllCall("GetLastError", "UInt")
    diagInfo := "=== 診断情報 ==="
    . "`n`nAutoHotkey Version: " A_AhkVersion
    . "`nProgramArchitecture: " (A_PtrSize = 8 ? "64-bit" : "32-bit")
    . "`nDLLArchitecture: " GetDllBitness(dllPath)
    . "`n`nDLL Path: " dllPath
    . "`nFile Exists: " (FileExist(dllPath) ? "Yes" : "No")
    . "`nErrorCode: " errorCode
    
    MsgBox diagInfo
    ExitApp
}

; ============================================
; 仮想デスクトップ操作関数
; （番号は 0 始まり）
; ============================================

GetTopVisibleWindow() {
    for hwnd in WinGetList() {
        if !WinExist("ahk_id " hwnd)
            continue
        if !WinGetMinMax("ahk_id " hwnd) != -1  ; 最小化除外
            continue
        if !WinGetStyle("ahk_id " hwnd) & 0x10000000 ; WS_VISIBLE
            continue
        return hwnd
    }
    return 0
}

GoToDesktop(n) {
    DllCall("VirtualDesktopAccessor.dll\GoToDesktopNumber", "Int", n)
    topwin := GetTopVisibleWindow()
    if topwin
        WinActivate "ahk_id " topwin
}

MoveWindowToDesktop(n) {
    hwnd := WinExist("A")
    if !hwnd
        return
    DllCall(
        "VirtualDesktopAccessor.dll\MoveWindowToDesktopNumber"
        , "Ptr", hwnd
        , "Int", n
    )
}

MoveAndGo(n) {
    MoveWindowToDesktop(n)
    GoToDesktop(n)
}

GetCurrentDesktop() {
    return DllCall(
        "VirtualDesktopAccessor.dll\GetCurrentDesktopNumber"
        , "Int"
    )
}

GetDesktopCount() {
    return DllCall(
        "VirtualDesktopAccessor.dll\GetDesktopCount"
        , "Int"
    )
}

; ============================================
; F13（Caps）モード：カーソル操作
; Shift 押下時は選択
; 変換中上下キーでカタカナ・ひらがな
; ============================================

global tryed_katakana := false
global tryed_hiragana := false

reset_tryed_vals() {
    global tryed_hiragana, tryed_katakana
    if (!IME_GetConverting()) {
        tryed_hiragana := false
        tryed_katakana := false
    }
}

F13 & h::{
    reset_tryed_vals()
    Send GetKeyState("Shift","P") ? "+{Left}"  : "{Left}"
}
F13 & j::{
    global tryed_hiragana
    reset_tryed_vals()
    if (IME_GetConverting() && !tryed_hiragana && !tryed_katakana) {
        Send "{F6}"
        tryed_hiragana := true
    } else {
        Send GetKeyState("Shift","P") ? "+{Down}"  : "{Down}"
    }
}
F13 & k::{
    global tryed_katakana
    reset_tryed_vals()
    if (IME_GetConverting() && !tryed_hiragana && !tryed_katakana) {
        Send "{F7}"
	tryed_katakana := true 
    } else {
        Send GetKeyState("Shift","P") ? "+{Up}"    : "{Up}"
    }
}
F13 & l::{
    reset_tryed_vals()
    Send GetKeyState("Shift","P") ? "+{Right}" : "{Right}"
}

F13 & `;::{
    reset_tryed_vals()
    Send "{BackSpace}"
}
F13 & sc028::{
    reset_tryed_vals()
    Send "{Delete}"
}

F13 & a::{
    reset_tryed_vals()
    Send GetKeyState("Shift","P") ? "+{Home}" : "{Home}"
}
F13 & e::{
    reset_tryed_vals()
    Send GetKeyState("Shift","P") ? "+{End}" : "{End}"
}
F13::{
    reset_tryed_vals()
    if KeyWait("F13", "T0.1") {
        Send "{Esc}"
    }
}

~Enter::reset_tryed_vals()
~Delete::reset_tryed_vals()
~Backspace::reset_tryed_vals()
~LButton::reset_tryed_vals()
~RButton::reset_tryed_vals()

; ============================================
; アプリ起動
; ============================================

#Space::{
    ; PowerShell をユーザー HOME で起動
    Run "schtasks /Run /TN `"RunPowerShellAsUser`"", , "Hide"
}

#b::{
    Run "firefox"
}

; ============================================
; ウィンドウ操作
; ============================================

#q::{
    ; アクティブウィンドウを閉じる
    WinClose "A"
}

; ============================================
; 仮想デスクトップ：番号ジャンプ
; Win + 数字（左から 1 → 0）
; ============================================

#1::GoToDesktop(0)
#2::GoToDesktop(1)
#3::GoToDesktop(2)
#4::GoToDesktop(3)
#5::GoToDesktop(4)
#6::GoToDesktop(5)
#7::GoToDesktop(6)
#8::GoToDesktop(7)
#9::GoToDesktop(8)
#0::GoToDesktop(9)

; ============================================
; 仮想デスクトップ：ウィンドウ移動＋切替
; Win + Shift + 数字
; ============================================

#+1::MoveAndGo(0)
#+2::MoveAndGo(1)
#+3::MoveAndGo(2)
#+4::MoveAndGo(3)
#+5::MoveAndGo(4)
#+6::MoveAndGo(5)
#+7::MoveAndGo(6)
#+8::MoveAndGo(7)
#+9::MoveAndGo(8)
#+0::MoveAndGo(9)

; ============================================
; 仮想デスクトップ：左右移動
; Win + Tab / Win + Shift + Tab
; ============================================

#Tab::{
    cur := GetCurrentDesktop()
    max := GetDesktopCount() - 1
    if cur < max
        GoToDesktop(cur + 1)
}

#+Tab::{
    cur := GetCurrentDesktop()
    if cur > 0
        GoToDesktop(cur - 1)
}

; Razer Synapse 等対策
A_MaxHotkeysPerInterval := 350

; ============================================
; Win + v で全画面
; ============================================

#v::
{
    hwnd := WinExist("A")  ; アクティブウィンドウ
    if hwnd
        WinMaximize hwnd
}
