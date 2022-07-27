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
;============= Part 3 =====================	

LOLP:	
	MOV A,60H	;loading the LOLE value to register A
	MOV B,#100D	
	MOV R1,#09D	;DEN
	ACALL MULT
	MOV 70H,A
		

MULT:	
	MUL AB		;Multiplication: (A-5)*P_rated
	MOV R2,B	;Higher byte stored in B
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
	
	
	
	END