*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                              ; first instruction of program

        LEA     PILE(PC),A7
        MOVE.L  #SIM_IT,$070

* Display hardware window 
        MOVE.B  #32,D0 ; task 32 of Trap #15 , Display hardware window (in Simulator page on Help)
        MOVE.B  #00,D1 ; Display hardware window (in Simulator page on Help)
        TRAP    #15 
    
BCL     NOP
        BRA     BCL



    SIMHALT                         ; halt simulator
SIM_IT  LEA     CHAINE(PC),A1       ; message pointer
        MOVE.B  #14,D0              ; OK , Mettre 14 dans le registre D0 (14 est le numéro identifiant la tâche d’affichage). 
                                       ; Cette ligne est référencier par l’étiquette SIM_IT.
        TRAP    #15                 ; OK display message
        RTE



CHAINE  DC.B    'CECI EST UNE INTERRUPTION',$0D,$0A,0
        DS      100  
PILE    DS      1

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
