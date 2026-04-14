; ====================================================================================================
; L-Alt : IME OFF
; R-Alt : IME ON
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; If the alt key used as mod, It will path through.
; ====================================================================================================

#include ../lib/IMEv2.ahk

; --------------------------------------------------
; If the alt key used as mod
; --------------------------------------------------

PassThrough(*) {
    return
}

; alphabet, number
for k in StrSplit("abcdefghijklmnopqrstuvwxyz1234567890")
    Hotkey "*~" k, PassThrough

; function key
Loop 12
    Hotkey "*~F" A_Index, PassThrough

; signs
symbols := "` ~ ! @ # $ % ^ & * `( `) - _ = + [ { ] } \ | `; `' `" , < . > / ?"
for k in StrSplit(symbols, " ")
    Hotkey "*~" k, PassThrough

; controll, mods
ctrlKeys := ["Esc","Tab","Space","Left","Right","Up","Down","Enter","PrintScreen","Delete","Home","End","PgUp","PgDn"]
for k in ctrlKeys
    Hotkey "*~" k, PassThrough

; --------------------------------------------------
; Disable alt menu
; --------------------------------------------------
Hotkey "*~LAlt", (*) => Send("{Blind}{vk07}")
Hotkey "*~RAlt", (*) => Send("{Blind}{vk07}")

; --------------------------------------------------
; L-Alt (not mod) → IME OFF
; --------------------------------------------------
LAlt up::{
    if (A_PriorHotkey = "*~LAlt")
        IME_SET(0)
}

; --------------------------------------------------
; R-Alt (not mod) → IME ON
; --------------------------------------------------
RAlt up::{
    if (A_PriorHotkey = "*~RAlt")
        IME_SET(1)
}
