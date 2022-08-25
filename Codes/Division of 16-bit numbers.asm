
	ORG 00H
	
	MOV R2,#255D
	MOV R3,#220D
	;First number: 220,255
	MOV R4,#01D
	MOV R5,#150d
	;Second number:150,001
	
	
	;dividing first number by second number
	;
	;	220,255/(150,001) = 1000*220/(150,001) + 255/(150,001)
	;
	MOV A,R3
	MOV B,R5
	DIV AB
	MOV R6,A
	MOV R7,B
	MOV A,R3
	MOV B,R4
	DIV AB
	
	END
