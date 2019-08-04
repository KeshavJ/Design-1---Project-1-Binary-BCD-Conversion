;*******************************************************************************
;									       *
;    Student Name	    : Keshav Jeewanlall			               *
;    Student Number	    : 213508238                                        *                             *
;    Description	    : Convert Binary to BCD Code and reverse           *
;                                                                              *
;    The following code contains two modules. Module 1 converts Binary         *
;    numbers to BCD code. Module 2 converts BCD code to a  Binary number       *
;                                                                              *
;*******************************************************************************
List p = 16f690
#include <p16F690.inc>

;Variable Declaration

GPR_Variables     UDATA
binary		  RES 1
bcd	          RES 1
counter	          RES 1
temp	          RES 1

 
;RES instruction is used to reserve memory since memory addresses cannot be 
;specified in relocatable code.
		  
CODE
;*******************************************************************************
;
;		     Module 1 - Binary number to BCD code
;
;  This code uses the Shift and add 3 algorithm to convert binary numbers to 
;  BCD
;
;  The general algorithm works as follows:		  
;  1. Shift the binary number left one bit at a time.
;  2. Depending on the number of shifts that have taken place, the BCD number will 
;     be in the respective Tens and Units columns.
;  3. If the binary value in any of the BCD columns is greater than 4, add 3 to 
;     that value in that BCD column.	
		  
;  In this code, the binary number is shifted one bit at a time into a new
;  register. This register consists of the Tens (upper nibble) and Units (lower 
;  nibble). After the first 2 shifts, the two nibbles are inspected and if their 
;  value is greater than 4, 3 is added to that nibble. 
   
Binary_To_BCD

    GLOBAL Binary_To_BCD   ;Made global in order to be accessed externally
    MOVWF binary           ;Move number from W register to file register
    MOVLW 0x05             ;loop counter needs to run 5 times
    MOVWF counter          ;move the value of 5 into the counter register

    CLRF bcd		   ;clear bcd registeer
    CLRF temp		   ;clear temp register
   
    RLF binary,1
    RLF bcd,1	
    RLF binary,1
    RLF bcd,1
 ;only after the 3rd shift nibbles need to be evaluated because the first two
 ;shifts will not result in a value greater than 4 eg. 0011 in binary is 3
    RLF binary,1	
    RLF bcd,1

BCD_loop

;To check if the value in the nibble is greater than 4, 3 is added to the nibble
;and stored in a temp register. If the value in temp is greater than 7, 
;it means the value in the nibble was greater than 4. Due to this, bit 3 or 7 
;in temp will be set because the value in temp will be 8 or larger and we can 
;test for this.
 
    ;Evaluating the lower nibble
	MOVFW bcd
	ADDLW 0x03
	MOVWF temp 
	BTFSC temp,3	
    ;if bit 3 in temp is set, call function to add 3 to lower nibble
	CALL Lower_nibble_Add3

    ;Evaluating the upper nibble
	MOVFW bcd
	ADDLW 0x30
	MOVWF temp 
	BTFSC temp,7       
    ;if bit 7 is set, call function to add 3 to upper nibble
	CALL Upper_nibble_Add3

	RLF binary,1
	RLF bcd,1
	
    ;loop must run 5 times to ensure all remaining bits are shifted after first 
    ;3 shifts
	DECFSZ counter  
	goto BCD_loop

	MOVFW bcd
    RETURN 
    
;function to add 3 to lower nibble and store result in bcd register
Lower_nibble_Add3
	MOVLW 0x03
	ADDWF bcd,1    
    RETURN
    
;function to add 3 to upper nibble and store result in bcd register
Upper_nibble_Add3
	MOVLW 0x30
	ADDWF bcd,1
    RETURN   
    
;*****************************End of Module 1***********************************
    
    
;*******************************************************************************
;		    Module 2 -  BCD Code To Binary number
;
; To convert from BCD to binary, firstly we must know that packed BCD is in
; the style [(16 * tens + units) - (6 * tens)] for example the number 29 in
; in packed BCD is 0010 1001 so taking the tens and units which in this case 
; is 2 and 9 respectively, using the formula (16 * 2 + 9) - (6 * 2) = 29
; which is 0001 1101 in binary.
;    
; Therefore in order to convert BCD to binary we need to convert the BCD 
; number into tens and units. This is done as follows:
;
; 1. Swap the nibbles of the BCD number and multiply by 0000 1111 to obtain
;    the tens, move this value into a file resgister (temp).
; 2. Implement the code to obtain a value of 6*tens
; 3. subtract this value of 6*tens from your BCD number in order to obtain
;    the binary eqivalent
    
BCD_To_Binary
    
    GLOBAL BCD_To_Binary
	MOVWF bcd	     ;move bcd value to bcd register
	SWAPF   bcd, W	     ;swap nibles of bcd register
	ANDLW   0x0F         ;ANDLW with 0x0F, W register will contain the tens
	MOVWF   temp         ;move tens to temp register
        ADDWF   temp, W      ;this instruction results in w = 2*tens
        ADDWF   temp, F      ;temp = 3*tens (note carry is cleared)
        RLF     temp, W      ;by rotating f left through carry once W = 6*tens
        SUBWF   bcd, W       ;W = 16*tens+ones - 6*tens. Binary number obtained 
        MOVWF   binary
	
;**********************************REFERENCES***********************************
; Dattalo, S. (n.d.). BCD packed to binary 2 digit to 8 bit. piclist.com.
	
;*****************************End of Module 2***********************************
END



