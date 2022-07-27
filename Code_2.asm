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
;Cut_in	 05D
;Rated	 11D
;Cut_out 25D
;Power   50D
	MOV  A,#50D
	SUBB A,#05D
	MOV 40H,A
DEN	EQU 40H	
	
HERE:	
	CLR A
	CLR C
	MOVC A,@A+DPTR	
	CJNE A,#05D,N1	;CONDITION 1
	SJMP N2
N1:	JNC N2
ZERO:	MOV 41H,#00H	;41H is the address of the output
	SJMP THERE
N2:	
	CJNE A,#11D,N3	;CONDITION 2
	SJMP N4
N3:	JNC N4
;------ Second equation --------
	CLR C	
	SUBB A,#05D	;Vci < A < Vrt
	MOV B,#50D	;5 < A < 11
	MUL AB		;Multiplication: (A-5)*P_rated
	MOV B,#06D
	DIV AB
	MOV 41H,A
	SJMP THERE
;-----------------------------	
N4:	
	CJNE A,#25D,N5
	SJMP ZERO			
N5:	JNC ZERO
	MOV 41H,#50D
			
THERE:	MOV @R0,41H
	INC R0
	INC DPTR
	DJNZ 43H,HERE	;Decrement the counter

	
	END