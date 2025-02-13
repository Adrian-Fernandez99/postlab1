/*

	Postlab1.asm

Created: 2/12/2025 9:05:30 PM
Author : Adrián Fernández
Descripción:
	Se realiza dos contadores binario de 4 bits.
	El conteo es visto por medio de LEDs en la protoboard.
	Se usan pushbuttons para el incremento y decrecimiento 
	de los valores.
	Por ultimo se suman ambos contadores y se muestran en 4
	leds aparte, una lad extra para mostrar overflow
*/


// Configurar la pila
.include "M328PDEF.inc"
.cseg
.org 0x0000


// Configurar el MCU
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R16, HIGH(RAMEND)
OUT SPH, R16

SETUP:
// Configurar pines de entrada y salida (DDRx, PORTx, PINx)
// PORTD como entrada con pull-up habilitado
	LDI		R16, 0x00
	OUT		DDRB, R16		// Setear puerto D como entrada
	LDI		R16, 0xFF
	OUT		PORTB, R16		// Habilitar pull-ups en puerto D

// PORTB como salida inicialmente encendido
	LDI		R16, 0xFF
	OUT		DDRD, R16		// Setear puerto B como salida
// PORTD como salida inicialmente encendido
	LDI		R16, 0xFF
	OUT		DDRC, R16		// Setear puerto C como salida

// Realizar variables
	LDI		R16, 0xFF		// Registro de ingresos
	LDI		R17, 0xFF		// Registro de comparación
	LDI		R18, 0xFF		// Registro del delay
	LDI		R19, 0x00		// Registro de contador1
	LDI		R20, 0x00		// Registro de contador2
	LDI		R21, 0x00		// Registro de contadores juntos

// Se realiza el main loop

CONTADOR:
	MOV		R17, R16
	OUT		PORTD, R21
	IN		R16, PINB
	CP		R16, R17
	BREQ	CONTADOR

DECREMENTO1:
	LDI		R17, 0xFB
	CP		R16, R17
	BRNE	INCREMENTO1
	CALL	DELAY
	IN		R16, PINB
	CP		R17, R16
	BRNE	CONTADOR
	BOTON_SUELTO:
		CALL	DELAY
		IN		R16, PINB
		SBIS	PINB, 2
		RJMP	BOTON_SUELTO
	DEC		R19
	CALL CAMBIO
	JMP		CONTADOR

INCREMENTO1:
	LDI		R17, 0xF7
	CP		R16, R17
	BRNE	DECREMENTO2
	CALL	DELAY
	IN		R16, PINB
	CP		R17, R16
	BRNE	CONTADOR
	BOTON_SUELTO2:
		CALL	DELAY
		IN		R16, PINB
		SBIS	PINB, 3
		RJMP	BOTON_SUELTO2
	CALL	SUMA1
	CALL CAMBIO
	JMP		CONTADOR

DECREMENTO2:
	LDI		R17, 0xEF
	CP		R16, R17
	BRNE	INCREMENTO2
	CALL	DELAY
	IN		R16, PINB
	CP		R17, R16
	BRNE	CONTADOR
	BOTON_SUELTO3:
		CALL	DELAY
		IN		R16, PINB
		SBIS	PINB, 4
		RJMP	BOTON_SUELTO3
	DEC		R20
	CALL CAMBIO
	JMP		CONTADOR

INCREMENTO2:
	LDI		R17, 0xDF
	CP		R16, R17
	BRNE	CONTADOR
	CALL	DELAY
	IN		R16, PINB
	CP		R17, R16
	BRNE	CONTADOR
	BOTON_SUELTO4:
		CALL	DELAY
		IN		R16, PINB
		SBIS	PINB, 5
		RJMP	BOTON_SUELTO4
	CALL	SUMA2
	CALL CAMBIO
	JMP		CONTADOR

// Sub-rutina (no de interrupción)
DELAY:
	LDI		R18, 0xFF
SUB_DELAY1:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY1
	LDI		R18, 0xFF
SUB_DELAY2:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY2
	LDI		R18, 0xFF
SUB_DELAY3:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY3
	LDI		R18, 0xFF
SUB_DELAY4:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY4
	RET

SUMA1:
	INC		R19
	SBRC	R19, 4
	LDI		R19, 0x00
	RET

SUMA2:
	INC		R20
	SBRC	R20, 4
	LDI		R20, 0x00
	RET

CAMBIO:
	LDI		R21, R20
	SWAP	R21
	ADD		R21, R19
	RET

// Rutinas de interrupción