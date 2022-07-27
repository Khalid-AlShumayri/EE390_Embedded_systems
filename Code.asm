	ORG 00H
	LJMP MAIN	
		
	ORG 20H
	MATRIXS: DB 45, 4, 0, 8, 11, 29, 9, 5, 6
	ORG 30H 
	MATRIXG: DB 30 , 95 , 25 , 50 , 15 , 20 , 5 , 15 , 45 
	ORG 40H
 	MATRIXL: DB 40 , 80 , 25 , 15 , 30 , 20 , 9 , 5 , 35 
	
MAIN:	
	
OUTPWR:
	MOV 43H,#09D	;COUNTER 
	MOV DPTR,#0020H	;READING DATA FROM THE ROM
	MOV R0,#50H	;SAVING LOCATION
CI	EQU 05D
RT	EQU 11D
CO	EQU 25D
PR	EQU 50D
	MOV A,#RT
	SUBB A,#CI
	MOV 40H,A
DEN	EQU 40H	
	
HERE:	
	CLR A
	CLR C
	MOVC A,@A+DPTR	
	CJNE A,#CI,N1	;CONDITION 1
	SJMP N2
N1:	JNC N2
ZERO:	MOV 41H,#00H	;41H is the address of the output
	SJMP THERE
N2:	
	CJNE A,#RT,N3	;CONDITION 2
	SJMP N4
N3:	JNC N4
;------ Second equation --------
	CLR C	
	SUBB A,#CI	;Vci < A < Vrt
	MOV B,#PR	;5 < A < 11
	MUL AB		;Multiplication: (A-5)*P_rated
	MOV R2,B
	MOV R3,A
	MOV B,#DEN
	DIV AB
	MOV R4,B	;Remainder 1
	MOV R5,A	;Qut 2
	MOV A,R2	;Higher byte of the multiplication
	MOV B,#DEN
	DIV AB		;divide higher byte by DEN
	ADD A,R5	;Add the Qut
	MOV R3,A	;Save the sum of Qut
	MOV A,B		;Remainder 2
	ADD A,R4	;Sum of the remainders
	MOV B,#DEN	;
	DIV AB		;Divide the sum of remainders by DEN
	ADD A,R3	;(A-5)*P_rated/(11-5)
	MOV 41H,A
	SJMP THERE
;-----------------------------	
N4:	
	CJNE A,#CO,N5
	SJMP ZERO			
N5:	JNC ZERO
	MOV 41H,#PR
			
THERE:	MOV @R0,41H
	INC R0
	INC DPTR
	DJNZ 43H,HERE	;Decrement the counter

	
	END