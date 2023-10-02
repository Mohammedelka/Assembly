*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  
switch equ $00E00012
leds   equ $00E00010
 *display hardware window 
    MOVE.B #32,D0
    MOVE.B  #00,D1
    TRAP #15
    
    
    
ETIQ MOVE.b switch,d1
     move.b d1,leds
     bra ETIQ
     
     
    MOVE #9,D0
    TRAP #15
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
