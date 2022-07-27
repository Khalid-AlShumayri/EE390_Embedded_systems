	ORG 00H
	LJMP MAIN	
		
	ORG 20H
	MATRIXS: DB 45, 4, 0, 8, 11, 29, 9, 5, 6
	ORG 30H 
	MATRIXG: DB 30 , 95 , 25 , 50 , 15 , 20 , 5 , 15 , 45 
	ORG 40H
 	MATRIXL: DB 40 , 80 , 25 , 15 , 30 , 20 , 9 , 5 , 35 
	
	ORG 0200H
MAIN:	
;========================== Part 1 =============================
TRANSFER:	
		
	MOV R1,#20H
	MOV R2,#00H
	MOV R3,#30H
	MOV R4,#10H
	MOV R5,#40H
	MOV R6,#20H

	MOV R7,#09
	MOV DPH,#00H
	
	TRNS:	CLR A
		MOV DPL,R1
		MOVC A,@A+DPTR
		MOV DPL,R2
		MOVX @DPTR,A
		
		CLR A
		MOV DPL,R3
		MOVC A,@A+DPTR
		MOV DPL,R4
		MOVX @DPTR,A
		
		CLR A
		MOV DPL,R5
		MOVC A,@A+DPTR
		MOV DPL,R6
		MOVX @DPTR,A
		
		INC R1
		INC R2
		INC R3
		INC R4
		INC R5
		INC R6
		
		DJNZ R7,TRNS	
		

;========================== Part 2 =============================	
OUTPWR:
	MOV 2FH,#09D	;Length of the vector.  
	MOV DPTR,#0020H	;Reading data from the ROM
	
;------- Parameter of the program ----------------
	
	MOV 30H,#05D	;cut_in
	MOV 31H,#11D	;rated
	MOV 32H,#25D	;cut_out
	MOV 33H,#50D	;rated power
	MOV 34H,#20H	;Reading from the ROM
	MOV R0 ,#50H	;Saving location
	
	;41H is the address of the output
	
;------------------------------------------------
	
	MOV  A,31H
	SUBB A,30H
	MOV 36H,A	;DEN. for part 3	
	
HERE:	
	CLR A
	CLR C
	MOVC A,@A+DPTR	
	
	
	
	
	
	CJNE A,30H,N1	;Condition 1
	SJMP N2
	
	N1:	JNC N2
	ZERO:	MOV 37H,#00H	;output = 00	
		SJMP THERE
	N2:	
		CJNE A,31H,N3	;Condition 2
		SJMP N4
	N3:	JNC N4
;-------- SECOND EQUATION 

		CLR C	
		SUBB A,30H	;Vci < A < Vrt ==> 5 < A < 11
		MOV B,33H	;Rated Power
		MOV R1,36H	;DEN
	;the above 3 lines are the args.
	;for the function MULT
		ACALL MULTDIV	;Calling the MULT subroutine
		MOV 37H,A	;(A-5)*P_rated/(11-5)=A*B/R1
		SJMP THERE
		
	N4:	
		CJNE A,32H,N5	;Condition 3
		SJMP ZERO
					
	N5:	JNC ZERO
	
;-------- Third equation 
		MOV 37H,33H	;output = P_rated
				
	THERE:	MOV @R0,37H	;Storing the result to the RAM
		MOV DPL,R0
		MOV A,37H
		MOVX @DPTR,A
		INC R0
		INC 34H
		MOV DPL,34H
		DJNZ 2FH,HERE	;Decrement the counter
	
	
	
;=========================== Part 3: LOLE ============================

;This program keep track of how many times
;the demand power outstriped generation
LOLE:		
	MOV R7,#09D
	MOV R2,#30H	;GEN. PWR.
	MOV R3,#40H	;DEM. PWR.
	MOV DPH,#00H
	MOV R6,#00H	;Counter to count how many times the demand outstriped generation
	
	BACK3:	
		MOV DPL,R2
		CLR A
		MOVC A,@A+DPTR	;Retrieving data from ROM
		MOV R4,A	;Storing GEN. PWR. to R4
		CLR A		
		MOV DPL,R3
		MOVC A,@A+DPTR	;Retrieving data from ROM
		CJNE A,04H,L3	;Comparing the GEN. PWR. to demanded power
			SJMP EXIT3
			
		L3:	JC EXIT3
			INC R6	
		EXIT3:	
			CLR C
			CLR A
			INC R2
			INC R3
			DJNZ R7,BACK3
	
	MOV DPTR,#0060H	;xRAM location
	MOV A,R6
	MOVX @DPTR,A	;Storing the result to xRAM
	
;======================= Part 4 ============================

	
LOLP:	
	MOV DPTR,#0060H
	MOVX A,@DPTR	;loading the LOLE value to register A
	MOV DPTR,#PERCEN
	MOVC A,@A+DPTR	;
	MOV 70H,A
	MOV DPTR,#0070H
	MOVX @DPTR,A	;Storing the result to xRAM
	
;================ Part 5: Energy served (ES) ===============

;This program calculate the total energy served for all instances

;	R1 = ACC. LOWER BYTE
;	R2 = ACC. HIGHER BYTE

ESERV:		
	
	MOV R7,#09D
	MOV R2,#30H	;GEN. PWR.
	MOV R3,#40H	;DEM. PWR.
	MOV DPH,#00H
	MOV R0,#00H	;HIGHER BYTE
	MOV R1,#00H	;LOWER BYTE
	
	BACK5:	
		MOV DPL,R2
		CLR A
		MOVC A,@A+DPTR	;Retrieving data from ROM
		MOV R6,A	;Storing GEN. PWR. to R6
		CLR A		
		MOV DPL,R3
		MOVC A,@A+DPTR	;Reading the DEM. PWR. to A
		CJNE A,06H,L5	;Comparing the A=DEM. with R6=GEN.
		
			MOV R6,A
			SJMP EXIT5
			
		L5:	JNC EXIT5	
			MOV R6,A	;If the DEM. < GEN. save the DEM. value to R6
		EXIT5:	
			CLR C
			MOV A,R6
			MOV B,R1
			ADD A,B
			JNC NEXT5
			INC R0
		NEXT5:	
			MOV R1,A	;LOWER BYTE
			CLR A
			INC R2
			INC R3
			DJNZ R7,BACK5
	
	MOV DPTR,#0080H	
	MOV A,R1	
	MOVX @DPTR,A	;LOWER BYTE
	MOV 80H,A	;Storing the result to RAM
	MOV DPTR,#0081H
	MOV A,R0
	MOVX @DPTR,A	;HIGHER BYTE
	MOV 81H,A	;Storing the result to RAM
	
;====================== Part 6 =======================	
ENSERV:	
		
	MOV R7,#09D
	MOV R2,#30H	;GEN. PWR.
	MOV R3,#40H	;DEM. PWR.
	MOV DPH,#00H
	MOV R1,#00H	
	MOV R0,#00H
	
	BACK6:	
		MOV DPL,R2
		CLR A
		MOVC A,@A+DPTR	;Retrieving data from ROM
		MOV R6,A	;Storing GEN. PWR. to R4
		CLR A		
		MOV DPL,R3
		MOVC A,@A+DPTR	;Retrieving data from ROM
		CJNE A,06H,L6	;Comparing
		;Comparing the GEN. PWR. to demanded power
			SJMP EXIT6
			
		L6:	JC EXIT6
			CLR C
			SUBB A,R6
		NEXT6:	
			ADD A,R1
			MOV R1,A
			JNC EXIT6
			INC R0		;INCREMENT THE HIGHER BYTE
	
		EXIT6:	
			INC R2
			INC R3
			DJNZ R7,BACK6
	
	MOV DPTR,#0091H
	MOV A,R1	;LOWER BYTE
	MOVX @DPTR,A	;Storing the result to xRAM
	MOV 91H,A	;Storing the result to RAM
	MOV DPTR,#0092H
	MOV A,R0	;HIGHER BYTE
	MOVX @DPTR,A	;Storing the result to xRAM
	MOV 92H,A	;Storing the result to RAM
	
;==========================================================================================
;=============================== END OF THE PROGRAM =======================================
;==========================================================================================

	ORG 0080H
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
PERCEN:		
	DB 0,11,22,33,44,56,67,78,89,100
	
; X ==> 0,1,2,3,4,5,6,7,8,9	

; 100*(X/9) ==> 0,11,22,33,44,56,67,78,89,100		

;-------------------------------------------------------------	
	END