; ====================================================================================================
; Win + <num> : move to vd (starts from 0)
; Win + Shift + <num> : move and go
; Win + Tab : move to next
; Win + Shift + Tab : move to prev
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; In this file, virtual desktop are referred to as vd
; ====================================================================================================

; --------------------------------------------------
; Initialize VirtualDesktopAccessor.dll
; --------------------------------------------------

dllPath := A_Temp "\VirtualDesktopAccessor.dll"
FileInstall "../lib/VirtualDesktopAccessor.dll", dllPath, 1

hvda := DllCall("LoadLibrary", "Str", dllPath, "Ptr")
if !hvda {
	MsgBox "Failed to load VirtualDesktopAccessor.dll"
	ExitApp
}

; --------------------------------------------------
; Utilitiy functions
; --------------------------------------------------

; --------------------------------------------------
; Activate latest focus window in vd
; --------------------------------------------------

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

; --------------------------------------------------
; move between vd
; vd is zero base
; --------------------------------------------------

GoToDesktop(n) {
    DllCall("VirtualDesktopAccessor.dll\GoToDesktopNumber", "Int", n)
}

GoAndActivateWindow(n) {
    GoToDesktop(n)
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

; --------------------------------------------------
; Mappings
; --------------------------------------------------

#1::GoAndActivateWindow(0)
#2::GoAndActivateWindow(1)
#3::GoAndActivateWindow(2)
#4::GoAndActivateWindow(3)
#5::GoAndActivateWindow(4)
#6::GoAndActivateWindow(5)
#7::GoAndActivateWindow(6)
#8::GoAndActivateWindow(7)
#9::GoAndActivateWindow(8)
#0::GoAndActivateWindow(9)

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

; for Razer Synapse
A_MaxHotkeysPerInterval := 350
