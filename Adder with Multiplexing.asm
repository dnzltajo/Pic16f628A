;****************************************************************************************
; Experiment 2 
; Author: D. Tajo
; Description: Addition with Multiplexing
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
	output
	select
	endc
	ORG     0x000  
	goto    setup  

setup ; init PIC16F628A

	movlw	0x07  
	movwf	CMCON
	banksel TRISA   
	clrf    TRISA
	clrf    TRISB
	movlw	0xFF     
	movwf	TRISA
	movwf   TRISB
	banksel INTCON 
	clrf	PORTA
	clrf	PORTB

goto	main

main
   call input
   call sum
   call selector
   call display
   call default
   goto main
input
   ;FIRST 3-bit INPUT
   BTFSC PORTB,0
   movlw 0x01
   BTFSS PORTB,0
   movlw 0x00
   movwf num11
   
   BTFSC PORTB,1
   movlw 0x02
   BTFSS PORTB,1
   movlw 0x00
   movwf num12
   
   BTFSC PORTB,2
   movlw 0x04
   BTFSS PORTB,2
   movlw 0x00
   movwf num13
      
   ;SECOND 3-bit INPUT
   BTFSC PORTB,3
   movlw 0x01
   BTFSS PORTB,3
   movlw 0x00
   movwf num21
   
   BTFSC PORTB,4
   movlw 0x02
   BTFSS PORTB,4
   movlw 0x00
   movwf num22
   
   BTFSC PORTB,5
   movlw 0x04
   BTFSS PORTB,5
   movlw 0x00
   movwf num23
   
   return
sum
   movf num11,w
   addwf num12,w
   movwf sum11
   movf sum11,w
   addwf num13,w
   movwf sum12

   movf num21,w
   addwf num22,w
   movwf sum21
   movf sum21,w
   addwf num23,w
   movwf sum22
   
   BTFSC PORTA,0
   movlw 0x01
   BTFSS PORTA,0
   movlw 0x00
   movwf select
   
   movf sum12,w
   addwf sum22,w
   movwf tsum
   call check
   movwf output
   btfsc select,0
   return
   goto sum
display
   BTFSC PORTA,0
   movlw 0x01
   BTFSS PORTA,0
   movlw 0x00
   movwf select
   movf output,w
   movwf PORTB
   btfss select,0
   return
   goto display
default
   banksel TRISB  
   clrf    TRISB
   movlw  0xFF      
   movwf   TRISB
   banksel PORTB
   clrf PORTB
   return
selector
   banksel TRISB  
   clrf TRISB
   movlw  0x00      
   movwf   TRISB
   banksel PORTB
   clrf PORTB
   return
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
      movlw d'01000000' ;8
      btfsc tsum,0  ;1001
      movlw d'01000001' ;9
      movwf output
      return
 check5 ;with 1 values 2nd digit 
      btfss tsum,0 ;1010
      movlw b'00001000' ;10
      btfsc tsum,0 ;1011
      movlw b'00001001'  ;11
      movwf output
      return
 check6 ;with 0 values 2nd digit 
      btfss tsum,0 ;1100 ;12
      movlw b'00001010'
      btfsc tsum,0 ;1101
      movlw b'00001011' ;13
      movwf output
      return		
 check7 ;with 1 values 2nd digit
      btfss tsum,0 ;1110
      movlw b'00001100' ;14
      movwf output
      return		
					      
END
					    
;*****************************************************

