*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
* Display hardware window 
        MOVE.B  #32,D0 
        MOVE.B  #00,D1 
        TRAP    #15 
leds equ $00E00010
segment1 equ $00E00000
segment2 equ $00E00002
segment3 equ $00E00004
segment4 equ $00E00006
segment5 equ $00E00008
    move.b #$39,d0
    move.b d0,segment1
    move.b #$38,d0
    move.b d0,segment2
    move.b #$3f,d0
    move.b d0,segment3
    move.b #$6d,segment4
    move.b #$79,segment5
    move.b #$f0,leds
    
    
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
