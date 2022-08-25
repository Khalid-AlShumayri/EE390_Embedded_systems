
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
	PUSH B
	PUSH A
	
  	MOV B,#00h ;Clear B since B will count the number of left-shifted bits
div1:
	INC B     ;Increment counter for each left shift
	MOV A,R2  ;Move the current divisor low byte into the accumulator
	RLC A     ;Shift low-byte left, rotate through carry to apply highest bit to high-byte
	MOV R2,A  ;Save the updated divisor low-byte
	MOV A,R3  ;Move the current divisor high byte into the accumulator
	RLC A     ;Shift high-byte left high, rotating in carry from low-byte
	MOV R3,A  ;Save the updated divisor high-byte
	JNC div1  ;Repeat until carry flag is set from high-byte
	END
