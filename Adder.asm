;****************************************************************************************
; Author: D. Tajo
; Description: Addition
;****************************************************************************************
           
list      p=16f628A           	  
#include <p16F628A.inc>       	    
errorlevel  -302                 
__CONFIG   _CP_OFF & _LVP_OFF & _BOREN_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _INTOSC_OSC_NOCLKOUT 
	cblock 0x20	
	COUNT1
	COUNT2
	delay_2
	delay_1
	TEMP
	num11
	num12
	num13
	num21
	num22
	num23
	sum11
	sum12
	sum21
	sum22
	tsum
	endc


	ORG     0x000   ; processor reset vector
	goto    setup   ; go to beginning of program

setup ; init PIC16F628A

	movlw	0x07  ; Turn comparators off
	movwf	CMCON
	banksel TRISA    ; BSF	STATUS,RP0 Jump to bank 1 use BANKSEL instead
	clrf    TRISA
	clrf    TRISB
	movlw	0xFF      ; 7-4 out, 3-0 in 
	movwf	TRISA
	movlw 	0x00
	movwf   TRISB
	banksel INTCON ; back to bank 0
	clrf	PORTA
	clrf	PORTB

	; setp TMR0 interrupts
	banksel OPTION_REG 
	movlw b'10000111' 
	; internal clock, pos edge, prescale 256
	movwf OPTION_REG
	banksel INTCON ; bank 0
	

goto main

main
 
   ;FIRST 3-bit INPUT
   BTFSC PORTA,0
   movlw 0x01
   BTFSS PORTA,0
   movlw 0x00
   movwf num11
   
   BTFSC PORTA,1
   movlw 0x02
   BTFSS PORTA,1
   movlw 0x00
   movwf num12
   
   BTFSC PORTA,2
   movlw 0x04
   BTFSS PORTA,2
   movlw 0x00
   movwf num13
   
   movf num11,w
   addwf num12,w
   movwf sum11
   movf sum11,w
   addwf num13,w
   movwf sum12
   
   ;SECOND 3-bit INPUT
   BTFSC PORTA,3
   movlw 0x01
   BTFSS PORTA,3
   movlw 0x00
   movwf num21
   
   BTFSC PORTA,4
   movlw 0x02
   BTFSS PORTA,4
   movlw 0x00
   movwf num22
   
   BTFSC PORTA,5
   movlw 0x04
   BTFSS PORTA,5
   movlw 0x00
   movwf num23
   
   movf num21,w
   addwf num22,w
   movwf sum21
   movf sum21,w
   addwf num23,w
   movwf sum22
   
   
   movf sum12,w
   addwf sum22,w
   movwf tsum
   
   call check
   
   movwf PORTB
   

   goto main
   
 check
      btfsc tsum,3	;Return if 0
      call check1	;1xxx
      return
 check1
      btfss tsum,2 ;0	10xx
      call check2
      btfsc tsum,2 ;1	11xx
      call check3
      return
 check2 ;with 0 values 3rd digit
      btfss tsum,1 ;0	100x
      call check4
      btfsc tsum,1 ;1	101x
      call check5
      return
 check3 ;with 1 values 3rd digit
      btfss tsum,1 ;0	110x
      call check6
      btfsc tsum,1 ;1	111x
      call check7
      return
 check4 ;with 0 values 2nd digit
      btfss tsum,0  ;1000
      movlw d'8'
      btfsc tsum,0  ;1001
      movlw d'9'
      return
 check5 ;with 1 values 2nd digit 
      btfss tsum,0 ;1010
      movlw b'00010000'
      btfsc tsum,0 ;1011
      movlw b'00010001'
      return
 check6 ;with 0 values 2nd digit 
      btfss tsum,0 ;1100
      movlw b'00010010'
      btfsc tsum,0 ;1101
      movlw b'00010011'
      return		
 check7 ;with 0 values 2nd digit
      btfss tsum,0 ;1110
      movlw b'00010100'
      return		
					      

					    
;====================================================================
      END