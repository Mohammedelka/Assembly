 *-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    lea sound(pc),a1
    move #0,d1
    move #71,d0
    trap #15
    move #0,d1
    move #72,d0
    trap #15
sound dc.b 'SCHOOL_BELL_SGo.wav',0
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
