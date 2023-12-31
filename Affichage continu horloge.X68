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
        MOVE.B	#8,D0   ; get time
        TRAP    #15
        ****Conversion en heure minutes et seconds******
            if.L D1 <hs> #NOON then  ; if time more than 12:00
                SUB.L   #NOON,D1     ; we want tu use english time
            endi
            
            **total seconds in D1.W
            DIVU    #100,D1
            MOVE.L  D1,D4           ; save fractionnal seconds
            *LSR.L   #8,D4
            *LSR.L   #8,D4 
            ANDI.L  #$0000FFFF,D1   ; delete frationnal part
            **hours in D5
            DIVU    #3600,D1
            MOVE.W  D1,D5           ; save the amount of hours
            LSR.L   #8,D1
            LSR.L   #8,D1          ; come to the rest of minutes
            **minutes in D6
            DIVU    #60,D1
            MOVE.W  D1,D6           ; save the amount of minutes
            LSR.L   #8,D1
            LSR.L   #8,D1          ; come to the rest of seconds
            **seconds in D7
            MOVE.W  D1,D7           ; save the amount of seconds
            
                
        *********Print in 7 segments(and fractional seconds on LEDs**************
        MOVE    #32,D0
        MOVE.B  #01,D1 ; get address of 7 segments 
        TRAP    #15
        MOVE.L  D1,A3  ; A3 = Address of 7 segments
        MOVE.B  #02,D1 ; get address of LEDs
        TRAP    #15
        MOVE.L  D1,A4  ; A4 = Address of LEDs
        
            **hours
        if.W D5 <eq> #0 then.s	;if hours = 0
		    MOVE.W	#12,D5
		endi
		MOVE.B  #10,D3          ; blank digit code
		if.B D5 <hi> #9 then    ; if the number > 9
		    SUB #10,D5
		    MOVE.B  #1,D3       ; Print a 1
		endi
		BSR     segment
        MOVE.W	D5,D3
		BSR     segment
		    
		    **dash
		MOVE.W	#11,D3
		BSR     segment
		    **minutes
		DIVU    #10,D6
		MOVE.W  D6,D3           ; Print 10's minute digit
		BSR     segment
		LSR.L   #8,D6
        LSR.L   #8,D6           ; come to the 1's minute digit
        MOVE.W  D6,D3           ; Print 1's minute digit
		BSR     segment
		    **dash
		MOVE.W	#11,D3
		BSR     segment
		    **seconds
		DIVU    #10,D7
		MOVE.W  D7,D3           ; Print 10's second digit
		BSR     segment
		LSR.L   #8,D7
        LSR.L   #8,D7           ; come to the 1's second digit
        MOVE.W  D7,D3           ; Print 1's second digit
		BSR     segment
        NOP
            **fractionnal seconds
        SWAP    D4
        MOVE.B  D4,(A4)
        WAIT   1           ; wait 1 hundreth seconds
        BRA     LOOP
        
        
***************************************************************************        
*************************INTERRUPTION 1: EMPLOYE bouton poussoir 1****************************
***************************************************************************        

EMPLOYE LEA ACCES_LIST(PC),A0
        LEA BIENVENUE(PC),A1
        BSR AFF_MSG
        **Lecture du code dans (A1)
        BSR INCLAV
        MOVE.L  A1,A5
        **on v�rifie le code
        MOVE.L  #8,D2       ; il y a 8 codes possibles
        MOVE.L  #1,D0       ; booleen de v�rification
        repeat
            MOVE.L  #1,D0       ; booleen de v�rification
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
        
        if.B D0 <eq> #1 then    
            BSR     OPEN
        endi
        RTE


***************************************************************************        
*************************INTERRUPTION 2: AGENT DE SECURITE bouton pousoir 2*****************
*************************************************************************** 
AGENT_S     BSR     OPEN   ; L'employ� a juste � appuyer sur le bouton
            RTE


    SIMHALT             ; halt simulator

*************************Sous programme**********************************

OPEN    ***LEDs***
        MOVE    #32,D0
        MOVE.B  #02,D1 ; get address of LEDs
        TRAP    #15
        MOVE.L  D1,A4  ; A4 = Address of LEDs
        MOVE.B  #03,(A4)    ; allume 2 LEDs de poid faible
        ***Switch ON
        MOVE.B  #02,D1 ; get address of switch
        TRAP    #15
        MOVE.L  D1,A5  ; A5 = Address of switch
        MOVE.B  #01,(A5)    ; positionne le switch 0 � ON


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

        MOVE.L  #0,D3       ; lettre O
        BSR     segment
        MOVE.L  #12,D3       ; lettre P
        BSR     segment
        MOVE.L  #13,D3       ; lettre E
        BSR     segment
        MOVE.L  #14,D3       ; lettre N
        BSR     segment
        WAIT    100
        
        ****5 seconds***
        ADD.L   #4,A3
        MOVE.L  #0,D3       ; chiffre 0
        BSR     segment
        
        for.L D4 = #5 downto #1 do    ;afficher les secondes de 5 � 1
            MOVE.L  D4,D3
            BSR segment
            SUB.L   #2,A3
            WAIT    100
        endf
        
        RTS




AFF_MSG MOVE.B  #13,D0
        TRAP    #15
        RTS
        
INCLAV  MOVE    #02,D0
        TRAP    #15
        RTS


**Affiche l'element contenue dans D3 sur le segment point� par A3
segment 
        LEA    digits(PC),A6
        MOVE.B (A6,D3),(A3)
        ADD.L   #2,A3
        RTS  
       
************Variables*************************************************************************

BIENVENUE   DC.B    'Bienvenue � vous. Entrez votre code PIN pour vous identifier: ', 0




*mod�le des bits pour former les chiffre de 0 � 9, vide, tiret, P, E, N
digits  DC.B     $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$7F,$6F,$00,$40,$73,$79,$54
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
                SUB.L   #NOON,D1     ; we want tu use english time
            endi
            
            **total seconds in D1.W
            DIVU    #100,D1
            MOVE.L  D1,D4           ; save fractionnal seconds
            *LSR.L   #8,D4
            *LSR.L   #8,D4 
            ANDI.L  #$0000FFFF,D1   ; delete frationnal part
            **hours in D5
            DIVU    #3600,D1
            MOVE.W  D1,D5           ; save the amount of hours
            LSR.L   #8,D1
            LSR.L   #8,D1          ; come to the rest of minutes
            **minutes in D6
            DIVU    #60,D1
            MOVE.W  D1,D6           ; save the amount of minutes
            LSR.L   #8,D1
            LSR.L   #8,D1          ; come to the rest of seconds
            **seconds in D7
            MOVE.W  D1,D7           ; save the amount of seconds
            
                
        *********Print in 7 segments(and fractional seconds on LEDs**************
        MOVE    #32,D0
        MOVE.B  #01,D1 ; get address of 7 segments 
        TRAP    #15
        MOVE.L  D1,A3  ; A3 = Address of 7 segments
        MOVE.B  #02,D1 ; get address of LEDs
        TRAP    #15
        MOVE.L  D1,A4  ; A4 = Address of LEDs
        
            **hours
        if.W D5 <eq> #0 then.s	;if hours = 0
		    MOVE.W	#12,D5
		endi
		MOVE.B  #10,D3          ; blank digit code
		if.B D5 <hi> #9 then    ; if the number > 9
		    SUB #10,D5
		    MOVE.B  #1,D3       ; Print a 1
		endi
		BSR     segment
        MOVE.W	D5,D3
		BSR     segment
		    
		    **dash
		MOVE.W	#11,D3
		BSR     segment
		    **minutes
		DIVU    #10,D6
		MOVE.W  D6,D3           ; Print 10's minute digit
		BSR     segment
		LSR.L   #8,D6
        LSR.L   #8,D6           ; come to the 1's minute digit
        MOVE.W  D6,D3           ; Print 1's minute digit
		BSR     segment
		    **dash
		MOVE.W	#11,D3
		BSR     segment
		    **seconds
		DIVU    #10,D7
		MOVE.W  D7,D3           ; Print 10's second digit
		BSR     segment
		LSR.L   #8,D7
        LSR.L   #8,D7           ; come to the 1's second digit
        MOVE.W  D7,D3           ; Print 1's second digit
		BSR     segment
        NOP
            **fractionnal seconds
        SWAP    D4
        MOVE.B  D4,(A4)
        WAIT   1           ; wait 1 hundreth seconds
        BRA     LOOP
        
        
***************************************************************************        
*************************INTERRUPTION 1: EMPLOYE****************************
***************************************************************************        

EMPLOYE LEA ACCES_LIST(PC),A0
        LEA BIENVENUE(PC),A1
        BSR AFF_MSG
        **Lecture du code dans (A1)
        BSR INCLAV
        MOVE.L  A1,A5
        **on v�rifie le code
        MOVE.L  #8,D2       ; il y a 8 codes possibles
        MOVE.L  #1,D0       ; booleen de v�rification
        repeat
            MOVE.L  #1,D0       ; booleen de v�rification
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
        
        if.B D0 <eq> #1 then    
            BSR     OPEN
        endi
        RTE         


    SIMHALT             ; halt simulator

*************************Sous programme**********************************

OPEN    ***LEDs***

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

        MOVE.L  #0,D3       ; lettre O
        BSR     segment
        MOVE.L  #12,D3       ; lettre P
        BSR     segment
        MOVE.L  #13,D3       ; lettre E
        BSR     segment
        MOVE.L  #14,D3       ; lettre N
        BSR     segment
        WAIT    100
        
        ****5 seconds***
        ADD.L   #4,A3
        MOVE.L  #0,D3       ; chiffre 0
        BSR     segment
        
        for.L D4 = #5 downto #1 do    ;afficher les secondes de 5 � 1
            MOVE.L  D4,D3
            BSR segment
            SUB.L   #2,A3
            WAIT    100
        endf
        
        RTS




AFF_MSG MOVE.B  #13,D0
        TRAP    #15
        RTS
        
INCLAV  MOVE    #02,D0
        TRAP    #15
        RTS


**Affiche l'element contenue dans D3 sur le segment point� par A3
segment 
        LEA    digits(PC),A6
        MOVE.B (A6,D3),(A3)
        ADD.L   #2,A3
        RTS  
       
************Variables*************************************************************************

BIENVENUE   DC.B    'Bienvenue � vous. Entrez votre code PIN pour vous identifier: ', 0




*mod�le des bits pour former les chiffre de 0 � 9, vide, tiret, P, E, N
digits  DC.B     $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$7F,$6F,$00,$40,$73,$79,$54
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
