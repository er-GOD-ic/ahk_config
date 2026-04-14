#Requires AutoHotkey v2.0

#Include .\IMEv2.ahk

; ============================================
; 基本設定
; ============================================

; CapsLock → F13 にしている前提
; CapsLock::F13
; SetCapsLockState "AlwaysOff"

; ============================================
; VirtualDesktopAccessor.dll 初期化
; ============================================

dllPath := A_Temp "\VirtualDesktopAccessor.dll"
FileInstall "VirtualDesktopAccessor.dll", dllPath, 1

hvda := DllCall("LoadLibrary", "Str", dllPath, "Ptr")
if !hvda {
	MsgBox "Failed to load VirtualDesktopAccessor.dll"
	ExitApp
}

activateLastActiveWindow() {
  oid := WinGetlist(, , "Find",)

  Loop oid.Length
  {
    this_ID := oid[A_Index]
    if WinActive("ahk_id " this_ID) || !isWindow(this_ID)
      continue
    WinActivate("ahk_id " . this_ID)
    DllCall("SetForegroundWindow", "UInt", this_ID)
    break
  }
}

isWindow(hWnd) {
  dwStyle := WinGetStyle("ahk_id " . hWnd)
  if ((dwStyle & 0x08000000) || !(dwStyle & 0x10000000))
    return false

  dwExStyle := WinGetExStyle("ahk_id " . hWnd)
  if ((dwExStyle & 0x00000080) || (dwExStyle & 0x00040000) || (dwExStyle & 0x00000008))
    return false

  if isWindowCloaked(hWnd)
    return false

  return true
}

isWindowCloaked(hwnd) {
  cloaked := 0
  return DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "int", 14, "ptr", cloaked, "int", 4) >= 0 && cloaked
}

; ============================================
; 仮想デスクトップ操作関数
; （番号は 0 始まり）
; ============================================

GoToDesktop(n) {
    DllCall("VirtualDesktopAccessor.dll\GoToDesktopNumber", "Int", n)
    activateLastActiveWindow()
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

F13 & h::{
    Send GetKeyState("Shift","P") ? "+{Left}"  : "{Left}"
}
F13 & j::{
    global tryed_hiragana
    Send GetKeyState("Shift","P") ? "+{Down}"  : "{Down}"
}
F13 & k::{
    global tryed_katakana
    Send GetKeyState("Shift","P") ? "+{Up}"    : "{Up}"
}
F13 & l::{
    Send GetKeyState("Shift","P") ? "+{Right}" : "{Right}"
}

F13 & `;::{
    Send "{BackSpace}"
}
F13 & '::{
    Send "{Delete}"
}

F13 & a::{
    Send GetKeyState("Shift","P") ? "+{Home}" : "{Home}"
}
F13 & e::{
    Send GetKeyState("Shift","P") ? "+{End}" : "{End}"
}

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

; ------------------------------
; パススルー用ホットキーまとめ
; ------------------------------
PassThrough(*) {
    return
}

; 英数・数字
for k in StrSplit("abcdefghijklmnopqrstuvwxyz1234567890")
    Hotkey "*~" k, PassThrough

; ファンクションキー
Loop 12
    Hotkey "*~F" A_Index, PassThrough

; 記号類
symbols := "` ~ ! @ # $ % ^ & * `( `) - _ = + [ { ] } \ | `; `' `" , < . > / ?"
for k in StrSplit(symbols, " ")
    Hotkey "*~" k, PassThrough

; 制御キー
ctrlKeys := ["Esc","Tab","Space","Left","Right","Up","Down","Enter","PrintScreen","Delete","Home","End","PgUp","PgDn"]
for k in ctrlKeys
    Hotkey "*~" k, PassThrough

; ------------------------------
; Altキーのメニュー発動抑制
; ------------------------------
Hotkey "*~LAlt", (*) => Send("{Blind}{vk07}")
Hotkey "*~RAlt", (*) => Send("{Blind}{vk07}")

; ------------------------------
; 左Alt 空打ち → IME OFF
; ------------------------------
LAlt up::{
    if (A_PriorHotkey = "*~LAlt")
        IME_SET(0)
}

; ------------------------------
; 右Alt 空打ち → IME ON
; ------------------------------
RAlt up::{
    if (A_PriorHotkey = "*~RAlt")
        IME_SET(1)
}
