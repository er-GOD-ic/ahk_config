; ====================================================================================================
; F13 + hjkl : ←↓↑→ 
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; F13 + a : HOME
; F13 + e : END
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Select text while holding down the <Shift>
; ====================================================================================================

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

F13 & a::{
    Send GetKeyState("Shift","P") ? "+{Home}" : "{Home}"
}
F13 & e::{
    Send GetKeyState("Shift","P") ? "+{End}" : "{End}"
}
