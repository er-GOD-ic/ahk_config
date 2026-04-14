; ====================================================================================================
; Win + q : Close window
; Win + v : Maximize window
; Win + m : Shutdown menu
; ====================================================================================================

#q::{
    hwnd := WinExist("A")
    if hwnd
        WinClose hwnd
}

#v::
{
    hwnd := WinExist("A")
    if hwnd
        WinMaximize hwnd
}

#m:: {
    Send("#q")
}
