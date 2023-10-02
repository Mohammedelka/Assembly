
DELAY    MACRO
    move.b  #23,d0          trap task 23
    move.l  #\1,d1          delay amount
    trap    #15
    ENDM


*-------------------------- PROGRAM START ---------------------------
    ORG    $1000

START
    * initialize
    clr.w   last_count
    move.b  #32,d0          trap task to get address of hardware
    move.b  #0,d1
    trap    #15             display hardware window
    move.b  #1,d1
    trap    #15             get address of 7-segment display
    move.l  d1,a4           A4 = Address of 7-segment display
    move.b  #3,d1
    trap    #15             get buttons address
    move.l  d1,a5           A5 = Buttons address
    

loop
    move.l  a4,a2
    repeat
        cmp.b   #00,(a5)
        beq     count_mode00
        cmp.b   #01,(a5)
        beq     count_mode01       
        cmp.b   #02,(a5)
        beq     count_mode10
        cmp.b   #03,(a5)
        beq     count_mode11  
        bra     loop
        
count_mode00:    cmpi.w  #99,last_count
                 bge     count_reset_00
                 addi.w  #0001, last_count
                 move.l  last_count,d7
                 move.l  #16,d0    
                 lsr.l   d0,d7        
                 DELAY   100
                 bsr     print
      
count_mode01:    cmpi.w  #00,last_count
                 ble     count_reset_01
                 subi.w  #0002, last_count
                 move.l  last_count,d7
                 move.l  #16,d0    
                 lsr.l   d0,d7        
                 DELAY   100  
                 bsr     print
                
count_mode10:    cmpi.w  #99,last_count
                 bge     count_reset_10
                 addi.w  #0002, last_count
                 move.l  last_count,d7
                 move.l  #16,d0    
                 lsr.l   d0,d7        
                 DELAY   100 
                 bsr     print
                  
count_mode11:    cmpi.w  #00,last_count
                 ble     count_reset_11
                 subi.w  #0001, last_count
                 move.l  last_count,d7
                 move.l  #16,d0    
                 lsr.l   d0,d7        
                 DELAY   100 
                 bsr     print

*Clear unnecessary display leds
print:
    move.b  #10,d3              
    bsr     segment7             
    move.w  #10,d3
    bsr     segment7           
    move.b  #10,d3               
    bsr     segment7             
    move.b  #10, d3
    bsr     segment7
    move.b  #10,d3
    and.b   #$F,d3              
    bsr     segment7
    move.b  #10,d3              
    bsr     segment7           

* display digits
    move.w  d7,last_count       save last count
    move.w  d7,d0
    bsr     Hex2BCD
    move.b  #0,d3               0 digit code
    if.b d0 <hi> #9 then.s
        move.b  d0,d3
        lsr.b   #4,d3           higher digit
    endi
    bsr     segment7
    move.b  d0,d3
    and.b   #$F,d3              lower digit
    bsr     segment7

    bra     loop                loop forever
    
    SIMHALT
    
count_reset_00:
    move.w  #00, last_count
    bsr     count_mode00
    rts

count_reset_01:
    move.w  #99, last_count
    bsr     count_mode01
    rts
    
count_reset_10:
    move.w  #00, last_count
    bsr     count_mode10
    rts
    
count_reset_11:
    move.w  #99, last_count
    bsr     count_mode11
    rts    


*-----------------------------------------------------------
*         A
*       -----
*     F|     |B
*      |  G  |
*       -----
*     E|     |C
*      |  D  |
*       -----   .H
*
* Bit Number  7 6 5 4 3 2 1 0
* Segment     H G F E D C B A

* bit patterns to form digits on readout
digits:
    dc.b  $3F           digit 0
    dc.b  $06           digit 1
    dc.b  $5B           digit 2
    dc.b  $4F           digit 3
    dc.b  $66           digit 4
    dc.b  $6D           digit 5
    dc.b  $7D           digit 6
    dc.b  $07           digit 7
    dc.b  $7F           digit 8
    dc.b  $6F           digit 9
    dc.b  $00           digit off
    dc.b  $40           dash

    ds.w  0             force word boundary

*----------------------------------------------------------
* Display a digit on the 7-segment display
* Pre:  D3.B contains 1 digit to display
*       A2 points to 7-segment LED to use
* Post: A2 points to next 7-segment LED

segment7:
    movem.l d3/a0,-(a7)     save registers
    lea     digits,a0       bit pattern table
    and.l   #$00ff,d3
    move.b  (a0,d3),(a2)    display digit
    adda.l  #2,a2
    movem.l (a7)+,d3/a0     restore registers
    rts


*-----------------------------------
* Convert 2 digit Hex to 2 digit BCD
* Pre:  D0.B 2 digit Hex
* Post: D0.B 2 digit BCD
Hex2BCD:
    movem.l d1,-(a7)        save registers
    clr     d1
    and.l   #$00FF,d0
    divu    #10,d0
    move.l  d0,d1
    asl.w   #4,d0           shift tens to proper location
    swap    d1              put units in proper location
    or.b    d1,d0           combine units with tens
    movem.l (a7)+,d1        restore registers
    rts

* variables
last_count     ds.w    1

    END     START












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
