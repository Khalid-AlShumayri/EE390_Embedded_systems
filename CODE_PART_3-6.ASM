;This program take three vectors as an input S,G, and L and performs some calculatons based on them

	ORG 00H
	LJMP MAIN	
	
	ORG 20H
	MATRIXS: DB 45, 4 , 0 , 8 , 11, 29, 9 , 5 , 6 ;S
	ORG 30H 
	MATRIXG: DB 30, 95, 25, 50, 15, 20, 5 , 15, 45 
	ORG 40H
 	MATRIXL: DB 40, 80, 25, 15, 30, 20, 9 , 5 , 35 
	
	ORG 0200H
MAIN:	
;======================= Part 3 ============================
LOLE:		
	MOV R7,#09D
	MOV R2,#30H	;GEN. PWR.
	MOV R3,#40H	;DEM. PWR.
	MOV DPH,#00H
	MOV R6,#00H	;Counter to count how many times the demand outstriped generation
	
	BACK1:	
		MOV DPL,R2
		CLR A
		MOVC A,@A+DPTR	;Retrieving data from ROM
		MOV R4,A	;Storing GEN. PWR. to R4
		CLR A		
		MOV DPL,R3
		MOVC A,@A+DPTR	;Retrieving data from ROM
		CJNE A,04H,L1	;Comparing the GEN. PWR. to demanded power
			SJMP EXIT1
			
		L1:	JC EXIT1
			INC R6	
EXIT1:	
	CLR C
	CLR A
	INC R2
	INC R3
	DJNZ R7,BACK1
	MOV 60H,R6
	
;======================= Part 4 ============================	
LOLP:	
	MOV A,60H	;loading the LOLE value to register A
	MOV B,#100D	;Multiplying by 100 to convert to percentage
	MOV R1,#09D	;DEN
	MOV DPTR,#PERCEN
	MOVC A,@A+DPTR	;
	MOV 70H,A
	
;================ Part 5: Energy served (ES) ===============
ESERV:		
	
	MOV R7,#09D
	MOV R2,#30H	;GEN. PWR.
	MOV R3,#40H	;DEM. PWR.
	MOV DPH,#00H
	MOV R0,#00H	;HIGHER BYTE
	MOV R1,#00H	;LOWER BYTE
	
	BACK3:	
		MOV DPL,R2
		CLR A
		MOVC A,@A+DPTR	;Retrieving data from ROM
		MOV R6,A	;Storing GEN. PWR. to R4
		CLR A		
		MOV DPL,R3
		MOVC A,@A+DPTR	;Retrieving data from ROM
		CJNE A,06H,L3	;Comparing the GEN. PWR. to demanded power
		
			MOV R6,A
			SJMP EXIT3
			
		L3:	JC EXIT3
			MOV R6,A
		EXIT3:	
			CLR C
			MOV A,R6
			MOV B,R5
			ADD A,B
			JNC NEXT3
			INC R0
		NEXT3:	
			MOV R1,A	;LOWER BYTE
			CLR A
			INC R2
			INC R3
			DJNZ R7,BACK3
	
	MOV DPTR,#0080H	
	MOV A,R1	
	MOVX @DPTR,A	;LOWER BYTE
	MOV DPTR,#0081H
	MOV A,R0
	MOVX @DPTR,A	;HIGHER BYTE
	
;====================== Part 6 =======================	
ENSERV:	
		
	MOV R7,#09D
	MOV R2,#30H	;GEN. PWR.
	MOV R3,#40H	;DEM. PWR.
	MOV DPH,#00H
	MOV R1,#00H	
	MOV R0,#00H
	
	BACK4:	
		MOV DPL,R2
		CLR A
		MOVC A,@A+DPTR	;Retrieving data from ROM
		MOV R6,A	;Storing GEN. PWR. to R4
		CLR A		
		MOV DPL,R3
		MOVC A,@A+DPTR	;Retrieving data from ROM
		CJNE A,06H,L4	;Comparing the GEN. PWR. to demanded power
			SJMP EXIT4
			
		L4:	JC EXIT4
			CLR C
			SUBB A,R6
		NEXT4:	
			ADD A,R1
			MOV R1,A
			JNC EXIT4
			INC R0		;INCREMENT THE HIGHER BYTE
	
		EXIT4:	
			INC R2
			INC R3
			DJNZ R7,BACK4
	
	MOV DPTR,#0091H
	MOV A,R0
	MOVX @DPTR,A
	MOV DPTR,#0092H
	MOV A,R1
	MOVX @DPTR,A
	
;========================================================================================
;============================= END OF THE PROGRAM =======================================
;========================================================================================


;--------------------- ADD16: 16-BIT ----------------------------
; A&B 8-BIT NUMBERS TO BE ADDED 
; R1 SUMMATION OF THE LOWER BYTE
; R0 HIGHER BYTE OF THE RESULT

ADD16:	
	ADD A,B
	MOV B,R0
	JNC CONT1
		INC B
CONT1:	ADD A,R1
	JNC CONT2
		INC B
CONT2:				
	RET
	
;--------------------- MULTDIV Subroutine -----------------------


;This subroutine takes input A, B, DEN
;mutiply A&B then stores the result in two bytes
;after that it divides this 16-bit number by DEN

MULTDIV:	
	MUL AB		;Multiplication: (A-5)*P_rated
	MOV R2,B	;Higher byte stored in R2
	MOV B,R1	;DEN
	DIV AB		;Dividing the lower byte by DEN
	MOV R4,B	;Remainder 1
	MOV R5,A	;Qut 2
	MOV A,#0FFH	;Higher byte of the multiplication
	MOV B,R1	;DEN
	DIV AB		;Dividing the higher byte by DEN
	MOV B,R2
	MUL AB		
	ADD A,R5	;Add the Qut
	MOV R3,A	;Save the sum of Qut
	MOV A,B		;Remainder 2
	ADD A,R4	;Sum of the remainders
	MOV B,R1	;DEN
	DIV AB		;Divide the sum of remainders by DEN
	ADD A,R3	;
	RET		
	
;---------- Percentage look-up table for part 3 ------------	
	ORG 0080H
PERCEN:		
	DB 0,11,22,33,44,56,67,78,89,100
	
; X ==> 0,1,2,3,4,5,6,7,8,9	

; 100*(X/9) ==> 0,11,22,33,44,56,67,78,89,100		

;-------------------------------------------------------------	
	END