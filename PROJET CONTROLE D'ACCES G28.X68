*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------


*

WAIT	MACRO
	move.b	#23,d0			;trap task 23
	move.l	#\1,d1			;Delai de l'attente amount
	trap	#15
	ENDM

        ORG    $1000
START:
        LEA     PILE(PC),A7
        MOVE.L  #EMPLOYE,$064        ; adresse interruption bouton 1
        MOVE.L  #AGENT_S,$07C        ; adresse interruption bouton 7


**************************************************************************************************
**********************************AFFICHAGE DE L'HEURE STANDARD ***********************************  
*************************************************************************************************     
        MOVE    #32,D0
        MOVE.B  #0,D1 ;  Afficher le hardware
        TRAP    #15

LOOP    CLR.L   D0
        CLR.L   D1
        CLR.L   D2
        CLR.L   D4
        CLR.L   D5
        CLR.L   D6
        CLR.L   D7
        MOVE.B	#8,D0               ; obtention de l'heure du système
        TRAP    #15
        ****Conversion en heure minutes et seconds******
            if.L D1 <hs> #NOON then  ; si l'heure est supérieur à 12:00
                SUB.L   #NOON,D1     ; on veut utiliser l'horaire anglais
            endi
            
            **total seconds in D1.W
            DIVU    #100,D1
            MOVE.L  D1,D4           ; sauvegarder la partie fractionnaire de secondes
            *LSR.L   #8,D4
            *LSR.L   #8,D4 
            ANDI.L  #$0000FFFF,D1   ; supprimer la partie frationnaire de secondes
            **heures dans D5
            DIVU    #3600,D1
            MOVE.W  D1,D5           ; saugarder le nombre d'heures
            LSR.L   #8,D1
            LSR.L   #8,D1          ; on traite maintenant le reste des minutes
            **minutes dans D6
            DIVU    #60,D1
            MOVE.W  D1,D6           ; saugarder le nombre de minutes
            LSR.L   #8,D1
            LSR.L   #8,D1          ; on traite maintenant le reste des secondes
            **secondes dans D7
            MOVE.W  D1,D7           ; saugarder le nombre de secondes
            
                
        *********Affichage sur le 7 segments(les secondes fractionaires sur les LEDs)**************
        MOVE    #32,D0
        MOVE.B  #01,D1 ; obtenir l'addresse du 7 segments 
        TRAP    #15
        MOVE.L  D1,A3  ; A3 = Addresse du 7 segments
        MOVE.B  #02,D1 ; obtenir addresse des LEDs
        TRAP    #15
        MOVE.L  D1,A4  ; A4 = Addresse des LEDs
        
            **heures
        if.W D5 <eq> #0 then.s	;si heure = 0
		    MOVE.W	#12,D5
		endi
		MOVE.B  #10,D3          ; code du digit vide
		if.B D5 <hi> #9 then    ; si l'heure > 9
		    SUB #10,D5
		    MOVE.B  #1,D3       ; Afficher d'abord 1
		endi
		BSR     segment
        MOVE.W	D5,D3
		BSR     segment         ; Afficher ensuite le chiffre des unités de l'heure
		    **tirêt
		MOVE.W	#11,D3
		BSR     segment
		    **minutes
		DIVU    #10,D6
		MOVE.W  D6,D3           ; chiffre des dizaines
		BSR     segment
		LSR.L   #8,D6
        LSR.L   #8,D6           ; chiffre des unités
        MOVE.W  D6,D3
		BSR     segment
		    **tirêt
		MOVE.W	#11,D3
		BSR     segment
		    **secondes
		DIVU    #10,D7
		MOVE.W  D7,D3           ; chiffre des dizaines

		BSR     segment
		LSR.L   #8,D7
        LSR.L   #8,D7           ; chiffre des unités
        MOVE.W  D7,D3
		BSR     segment
        NOP
            **secondes fractionnaires
        SWAP    D4
        MOVE.B  D4,(A4)
        WAIT   1           ; attendre 1 centième de secondes
        BRA     LOOP
        
        
*************************************************************************************************************        
*************************INTERRUPTION 1: EMPLOYE bouton poussoir d'interruption 1****************************
*************************************************************************************************************        

EMPLOYE MOVE.L   #0,A1
        LEA BIENVENUE(PC),A1
        BSR AFF_MSG
        MOVE.L   #0,A1
        MOVE.L  #1,D6   ; nombres de tentatives
        **Lecture du code dans (A1)
TENT    BSR INCLAV
        MOVE.L  A1,A5
        **on vérifie le code
        LEA ACCES_LIST(PC),A0
        MOVE.L  #8,D2       ; il y a 8 codes possibles
        MOVE.L  #1,D0       ; booleen de vérification
        repeat
            MOVE.L  #1,D0       ; booleen de vérification
            CLR.L   D4
            for.L D4 = #1 to #4 do     ; chaque code a 4 chiffres
                if.B   (A1)+ <ne> (A0)+ then
                    MOVE.L  #0,D0
                endi
            endf
            MOVE.L  A5,A1
            ADD.L   #1,A0   ; on saute le 0
            SUB.L   #1,D2
        until.B D0 <eq> #1 or.L D2 <eq> #0 do
        ADDQ.L   #1,D6
        
        if.B D0 <eq> #1 then    
            BSR     OPEN
        else
            if.B D6 <eq> #2 then
                LEA TENT2(PC),A1
                BSR AFF_MSG
                MOVE.L   #0,A1
                BRA     TENT
            endi
            if.B D6 <eq> #3 then
                LEA TENT3(PC),A1
                BSR AFF_MSG
                MOVE.L   #0,A1
                BRA     TENT
            else
                BSR     CLOSE
            endi
        endi
        RTE


***************************************************************************************************************        
*************************INTERRUPTION 2: AGENT DE SECURITE bouton pousoir d'interruption 7**********************
****************************************************************************************************************** 
AGENT_S     BSR     OPEN   ; L'employé a juste à appuyer sur le bouton
            RTE


    SIMHALT             ; halt simulator

*************************Sous programme**********************************

OPEN    ***LEDs***
        MOVE    #32,D0
        MOVE.B  #02,D1  ; obtenir addresse des LEDs
        TRAP    #15
        MOVE.L  D1,A4   ; A4 = Addresse des LEDs
        MOVE.B  #03,(A4)    ; allume 2 LEDs de poid faible


        ***7 segment***
        MOVE    #32,D0
        MOVE.B  #01,D1 ; obtenir l'addresse des 7 segments 
        TRAP    #15
        MOVE.L  D1,A3  ; A3 = Addresse des 7 segments
        MOVE.L  #10,D3
        for D4 = #0 to #7 do    ;effacer l'afficheur
            BSR segment
        endf
        
        MOVE.B  #01,D1 ; get address of 7 segments 
        TRAP    #15
        MOVE.L  D1,A3
        move.b  #63,(a3)+   ; lettre O
        move.b  #0,(a3)+
        move.b  #115,(a3)+  ; lettre P
        move.b  #0,(a3)+
        move.b  #121,(a3)+  ; lettre E
        move.b  #0,(a3)+
        move.b  #84,(a3)+   ; lettre N
        WAIT    100
        
        ****5 seconds***
        ADD.L   #5,A3
        MOVE.L  #0,D3       ; chiffre 0
        BSR     segment
        
        for.L D4 = #5 downto #1 do    ;afficher les secondes de 5 à 1
            MOVE.L  D4,D3
            BSR segment
            SUB.L   #2,A3
            WAIT    100     ; attendre 100 centièmes de secondes = 1 seconde
        endf
        
        ***Alarme si la porte n'est pas fermée après 5s c'est à dire si  le switch 0 est à ON
switch equ $00E00012
         move.b switch,d2   ;si l'utilisateur bloque la porte en appuyant sur le switch 0 
         cmp.b #01,d2
         beq ALARM
         bra FIN_S
 
ALARM   
        **leds
        MOVE    #32,D0
        MOVE.B  #02,D1 ; get address of LEDs
        TRAP    #15
        MOVE.L  D1,A4  ; A4 = Address of LEDs
        MOVE.B  #$18,(A4)    ; allume 2 LEDs du milieu
        **7 segments
        MOVE.B  #01,D1 ; get address of 7 segments 
        TRAP    #15
        MOVE.L  D1,A3  ; A3 = Address of 7 segments  
        MOVE.L  #10,D3
        for D4 = #0 to #7 do    ;effacer l'afficheur
            BSR segment
        endf
        MOVE.B  #01,D1 ; get address of 7 segments 
        TRAP    #15
        MOVE.L  D1,A3  ; A3 = Address of 7 segments
        move.b  #119,(a3)+   ; lettre A
        move.b  #0,(a3)+
        move.b  #56,(a3)+  ; lettre L
        move.b  #0,(a3)+
        move.b  #119,(a3)+  ; lettre A
        move.b  #0,(a3)+
        move.b  #80,(a3)+   ; lettre R
        move.b  #0,(a3)+
        move.b  #84,(a3)+  ; lettre M
        move.b  #0,(a3)+
        move.b  #84,(a3)+
        **Sound
        lea sound(pc),a1
        move #0,d1
        move #71,d0
        trap #15
        move #0,d1
        move #72,d0
        trap #15
        WAIT    300
        *move.b #00,switch       
FIN_S   RTS


       
CLOSE   ***LEDs***
        MOVE    #32,D0
        MOVE.B  #02,D1 ; get address of LEDs
        TRAP    #15
        MOVE.L  D1,A4  ; A4 = Address of LEDs
        MOVE.B  #$C0,(A4)    ; allume 2 LEDs de poid fort
        ***Switch ON
        MOVE.B  #03,D1 ; get address of switch
        TRAP    #15
        MOVE.L  D1,A5  ; A5 = Address of switch
        MOVE.B  #01,(A5)    ; positionne le switch 0 à ON


        ***7 segment***
        MOVE    #32,D0
        MOVE.B  #01,D1 ; get address of 7 segments 
        TRAP    #15
        MOVE.L  D1,A3  ; A3 = Address of 7 segments
        MOVE.L  #10,D3
        for D4 = #0 to #7 do    ;effacer l'afficheur
            BSR segment
        endf
        
        MOVE.B  #01,D1 ; get address of 7 segments 
        TRAP    #15
        MOVE.L  D1,A3  ; A3 = Address of 7 segments

        move.b  #57,(a3)+   ; lettre C
        move.b  #00,(a3)+
        move.b  #56,(a3)+   ; lettre L
        move.b  #00,(a3)+
        move.b  #63,(a3)+   ; lettre O
        move.b  #00,(a3)+
        move.b  #109,(a3)+  ; lettre S
        move.b  #00,(a3)+
        move.b  #121,(a3)+  ; lettre E

        WAIT    100
        
        ****3 seconds***
        ADD.L   #3,A3
        MOVE.L  #0,D3       ; chiffre 0
        BSR     segment
        
        for.L D4 = #3 downto #1 do    ;afficher les secondes de 5 à 1
            MOVE.L  D4,D3
            BSR segment
            SUB.L   #2,A3
            WAIT    100     ; attendre 100 centièmes de secondes = 1 seconde
        endf
        
        RTS
 




AFF_MSG MOVE.B  #13,D0
        TRAP    #15
        RTS
        
INCLAV  MOVE    #02,D0
        TRAP    #15
        RTS

**Affiche l'element contenue dans D3 sur le segment pointé par A3
segment 
        LEA    digits(PC),A6
        MOVE.B (A6,D3),(A3)
        ADD.L   #2,A3
        RTS  


*****************************************************************************************************************      
**************************** CONSTANTES *************************************************************************
****************************************************************************************************************

BIENVENUE   DC.B    'Bienvenue à vous. Entrez votre code PIN pour vous identifier: ', 0
TENT2       DC.B    'CODE INCORRECTE! Il vous reste 2 tentatives:', 0
TENT3       DC.B    'CODE INCORRECTE! Il vous reste 1 tentative:',0


sound dc.b 'SCHOOL_BELL_SGo.wav',0


*modèle des bits pour former les chiffre de 0 à 9, vide, tiret
digits  DC.B     $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$7F,$6F,$00,$40
	ds.w  0				force word boundary

ACCES_LIST  DC.B    'ABCD',0
            DC.B    'AB12',0
            DC.B    '1234',0
            DC.B    'ADMI',0
            DC.B    'EMP1',0
            DC.B    'EMP2',0
            DC.B    'EMP3',0
            DC.B    'EMP4',0


        DS      100
PILE    DS      1

NOON	EQU	12*60*60*100

        END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
