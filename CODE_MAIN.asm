	ORG 00H
	LJMP MAIN	
		
	ORG 20H
	MATRIXS: DB 45, 4, 0, 8, 11, 29, 9, 5, 6
	ORG 30H 
	MATRIXG: DB 30 , 95 , 25 , 50 , 15 , 20 , 5 , 15 , 45 
	ORG 40H
 	MATRIXL: DB 40 , 80 , 25 , 15 , 30 , 20 , 9 , 5 , 35 
	
	ORG 70H
MAIN:	
;===============Part 1================	
OUTPWR:
	MOV 34H,#09D	;Length of the vector. COUNTER 
	MOV DPTR,#0020H	;READING DATA FROM THE ROM
	
;------ Parameter of the program ----------------	
	MOV R0,#50H	;SAVING LOCATION
	MOV 30H,#05D	;cut_in
	MOV 31H,#11D	;rated
	MOV 32H,#25D	;cut_out
	MOV 33H,#50D	;rated power
;------------------------------------------------	
	MOV  A,31H
	SUBB A,30H
	MOV 36H,A	;DEN	
;41H is the address of the output
	
HERE:	
	CLR A
	CLR C
	MOVC A,@A+DPTR	
	CJNE A,30H,N1	;CONDITION 1
	SJMP N2
N1:	JNC N2
ZERO:	MOV 37H,#00H	;OUTPUT = 00	
	SJMP THERE
N2:	
	CJNE A,31H,N3	;CONDITION 2
	SJMP N4
N3:	JNC N4
;------ Second equation ---------------
	CLR C	
	SUBB A,30H	;Vci < A < Vrt ==> 5 < A < 11
	MOV B,33H	;Rated Power
	MOV R1,36H	;DEN
	;the above 3 lines are the args.
	;for the function MULT
	ACALL MULT	;(A-5)*P_rated/(11-5)=A*B/R1
	MOV 37H,A
	SJMP THERE
;--------------------------------------

N4:	
	CJNE A,32H,N5	;CONDITION 3
	SJMP ZERO			
N5:	JNC ZERO
;------- THIRD EQUATION -----------------
	MOV 37H,33H	;OUTPUT = P_rated
;----------------------------------------		
THERE:	MOV @R0,37H
	INC R0
	INC DPTR
	DJNZ 34H,HERE	;Decrement the counter
	
;================Part 2=======================
LOLE:		
	MOV R7,#09D
	MOV R2,#30H	;GEN.
	MOV R3,#40H	;LOAD
	MOV DPH,#00H
	MOV R6,#00H
	
BACK1:	MOV DPL,R2
	CLR A
	MOVC A,@A+DPTR
	MOV R4,A	;Storing GEN. to R4
	CLR A
	MOV DPL,R3
	MOVC A,@A+DPTR
	CJNE A,04H,L1
	SJMP EXIT
L1:	JC EXIT
	INC R6	
EXIT:	
	CLR C
	CLR A
	INC R2
	INC R3
	DJNZ R7,BACK1
	MOV 60H,R6
;==============Part 3======================	

LOLP:	
	MOV A,60H	;loading the LOLE value to register A
	MOV B,#100D	
	MOV R1,#09D	;DEN
	ACALL MULT
	MOV 70H,A
		
;==============Part 4======================

MULT:	
	MUL AB		;Multiplication: (A-5)*P_rated
	MOV R2,B
	MOV B,R1	;DEN
	DIV AB		;Dividing the lower byte by DEN
	MOV R4,B	;Remainder 1
	MOV R5,A	;Qut 2
	MOV A,R2	;Higher byte of the multiplication
	MOV B,R1	;DEN
	DIV AB		;divide the higher byte by DEN
	ADD A,R5	;Add the Qut
	MOV R3,A	;Save the sum of Qut
	MOV A,B		;Remainder 2
	ADD A,R4	;Sum of the remainders
	MOV B,R1	;DEN
	DIV AB		;Divide the sum of remainders by DEN
	ADD A,R3	;
	RET	
		
	END