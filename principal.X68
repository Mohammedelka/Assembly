*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
     lea pile(pc),a7
     lea list(pc),a0
     * Display hardware window 
        MOVE.B  #32,D0 
        MOVE.B  #00,D1 
        TRAP    #15 
switch equ $00E00012
loop     move.b switch,d2    ;il faut cliquer sur le premier switch manuellement avant de commencer 
         cmp.b #01,d2
         bne loop
         bra principal
         move #9,d0
         trap #15
         
principal  move #14,d0
           lea text,a1
          trap #15 
          move #4,d0
          trap #15
          bra recherche
          rts
********************************
recherche clr d0 
boucle    add #1,d0
          cmp (a0)+,d1
          beq aff1
          cmp #4,d0
          bne boucle
          bra aff2
          rts
****************************
aff2       move #14,d0
          lea message2,a1
          trap #15
          move #5,d0
          trap #15
          rts
***************************
aff1      move #14,d0
          lea message1,a1
          trap #15
          move #5,d0
          trap #15

           

     
    SIMHALT             ; halt simulator

* Put variables and constants here
     ds  100
pile ds  1
list dc  7020,8011,1234,8410,0
text dc  'entrer le code :',$0D,$0A,0
message1 dc 'le code existe dans la liste.',0
message2 dc 'le code pas dans la liste.',0    
     END     START       ; last line of source




*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
