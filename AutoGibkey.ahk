#InstallKeybdHook
#KeyHistory 100
SendMode, Input ;Makes Send -> Sendinput
;#=winkey,^=ctrl,+=shift, & ties two keys together
#IfWinNotActive ahk_class ConsoleWindowClass

; MOD 3: Alt scroll wheel to change tabs
Alt & WheelDown:: Send {Ctrl down} {Tab} {Ctrl up}
Return
Alt & WheelUp:: Send {Ctrl down} {Shift down} {Tab} {Shift up} {Ctrl up}
Return
XButton2 & WheelDown:: Send {Ctrl down} {Tab} {Ctrl up}
Return
XButton2 & WheelUp:: Send {Ctrl down} {Shift down} {Tab} {Shift up} {Ctrl up}
Return
XButton1::^w
Return
XButton2:: Send {MButton}
Return


; MOD 4: Unicode on Ctrl+Alt+letter or Ctrl+Alt+Shift+Letter
    ; N.B. Alt Gr = Alt+Ctrl
!^4::   Send {U+20AC}
Return
!^8::   Send {U+2605} ;?
Return
!^+8:: Send {U+2606} ;?
Return
!^o::   Send {U+03C9} ;?
Return
!^+o:: Send {U+03A9} ;O
Return
!^+s:: Send {U+03A3} ;S
Return
^!t:: Send {U+0009} ;Tab
Return
^!d:: Send, %A_YYYY%-%A_MM%-%A_DD%  ;2015-11-15
Return
^!+d:: Send, %A_YYYY%-%A_MMM%-%A_DD%  ;2015-Nov-15
Return
^!b:: Send {U+2022} ;•
Return
^!+b:: Send {U+25E6} ;??
Return
^!-:: Send {U+2013} ;– n dash
Return
^!+-:: Send {U+2014} ;— m dash
Return
:*:there4::{U+2234}
Return


; MOD 5: Hotstrings v1.0
    ;EMAIL/USERNAME
:*:tbb::tbbhoiorg
:*:tbg::tbbhoiorg@gmail.com
:*:gbf::gibfahn
:*:gbg::gibfahn@gmail.com
:*:evt::eventang93
:*:evg::eventang93@gmail.com
:*:mtb::mtibson
:*:mtg::mtibson@gmail.com
:*:stg::stellacaco@gmail.com
:*:ssg::stellasoulioti2012@gmail.com
:*:gfu::gibson.fahnestock.12@alumni.ucl.ac.uk
:*:kag::kangeven@163.com
:*:gbi::gib@uk.ibm.com

    ;ADDRESS
:*:ad1::4 Comley Court
:*:ad2::Bell Street
:*:ad3::Romsey
:*:ad4::SO51 8AL
:*:pst::SO51 8AL
:*:adrs::Flat 49 Shrewsbury House, 42 Cheyne Walk, London, SW35LW
:*:adrc::4 Comley Court, Bell Street, Romsey, SO51 8AL


    ;NUMBERS/WEBSITES
:*:mbg::07753376431
:*:mbe::07725792449
:*:mbm::07786587797
:*:mbt::07766520802
:*:mb3::07480525900
:*:mbh::01794278975
:*:qqg::1840046693
:*:qqe::583840114
:*:qqd::3177964858
:*:qqc::1480189557

:*:lkg::https://uk.linkedin.com/in/gibfahn
:*:gfa::Gibson Fahnestock
Return

    ;Shifts together toggle capslock
Rshift & Lshift::
  SetCapsLockState, % GetKeyState("CapsLock", "T")? "Off":"On"
Return

; ======================
; Paste on middle click
; ======================

~MButton::
  WinGetClass wndw, A
  if (wndw <> "mintty") && (wndw <> "QWidget")
    Send ^v
Return

:*:r3r::random3r
