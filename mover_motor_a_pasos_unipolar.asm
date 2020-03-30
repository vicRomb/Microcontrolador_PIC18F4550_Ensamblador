;******************************************************************************

	List    P=18F4550	  ;Microcontrolador a utilizar
	include <P18F4550.inc>	  ;Definiciones de constantes

; 16 mil instrucciones le caben al microcontrolador
	
;***********   Palabra de conficuración	***************************************
	CONFIG FOSC=HS	         ; Internal oscillator                                
	CONFIG PWRT=ON		  ; Power-up Timer Enable bit
	CONFIG BOR=OFF		  ; Brown-out Reset disabled in hardware and software
	CONFIG WDT=OFF		  ; WDT disabled
	CONFIG MCLRE=ON		  ; MCLR pin enabled
	CONFIG PBADEN=OFF	  ; PORTB<4:0> pins are configured as digital I/O
	CONFIG LVP=OFF		  ; Single-Supply ICSP disabled
	CONFIG DEBUG = OFF        ; Background debugger disabled
	CONFIG XINST = OFF	  ; Extended Instruction disabled
;*******************************************************************************

; *********** Variables globales *****************
 n EQU 0x00	    ; 
 g EQU 0x01
 t EQU 0X02
;************************************************

ORG 0X0000
 
bcf INTCON2,RBPU	    ; Habilitar las resistencias en modo pull up del uC

clrf	PORTB		    ; LIMPIA PUERTO B
clrf	PORTD		    ; lIMPIA PUERTO D

; CONFIGURACIÓN DE PUERTOS B Y D ******************************
setf	TRISB		    ; Puerto B como entrada
clrf	TRISD		    ; PUERTO D como salida
 ; ************************************************************
 
 ; Etiquetas para los botones************************************
#define	Bizq	PORTB,2 ; Pulsador 2 conectado a pueero RB2
#define Bder	PORTB,3 ; Pulsador 2 conectado a pueero RB3

; Inicio del programa ---------------------------------------------------/
INICIO
	btfss	Bizq		; Verifica si botón 1 esta activado
	bra 	Dos		; Si no, ve a etiquta DOS
	btfsc	Bder		; Verifica si botón 2 esta desactivado
	bra 	INICIO		; si esta activado, ve a INICIO
	call	S_HORARIO	; gira motor en sentido horario
Dos				; Etiquta DOS
	btfss	Bder		; Verifica si botón 2 esta activado
	bra	INICIO		; Si no, ve a INICIO
	btfsc	Bizq		; Verifica si botón 1 esta desactivado
	bra	INICIO		; Si esta activado, ve a INICIO
	call	S_ANTIHORA	; Gira motor en sentido antihorario
	bra	INICIO		; Regresa a INICIO
; ************************************************************************
	
; Subrutina para giro en sentido horario -----------------------------/
S_ANTIHORA
	movlw	B'00000001'	; mueve el valor al registro W
	movwf	PORTD		; envia el valor de W al puerto D
	call	RETARDO		; Espera de 500 ms
	movlw	B'00000010'	; mueve el valor al registro W
	movwf	PORTD		; envia el valor de W al puerto D
	call	RETARDO		; Espera de 500 ms
	movlw	B'00000100'	; mueve el valor al registro W
	movwf	PORTD		; envia el valor de W al puerto D
	call 	RETARDO		; Espera de 500 ms
	movlw	B'00001000'	; mueve el valor al registro W
	movwf	PORTD		; envia el valor de W al puerto D
	call	RETARDO		; Espera de 500 ms
	return

; Subrutina para giro en sentido horario ----------------------/
S_HORARIO
	movlw	B'00001000'	; mueve el valor al registro W
	movwf	PORTD		; envia el valor de W al puerto D
	call	RETARDO		; Espera de 500 ms
	movlw	B'00000100'	; mueve el valor al registro W
	movwf	PORTD		; envia el valor de W al puerto D
	call	RETARDO		; Espera de 500 ms
	movlw	B'00000010'	; mueve el valor al registro W
	movwf	PORTD		; envia el valor de W al puerto D
	call	RETARDO		; Espera de 500 ms
	movlw	B'00000001'	; mueve el valor al registro W
	movwf	PORTD		; envia el valor de W al puerto D
	call	RETARDO		; Espera de 500 ms
	return

; subrutina de ratardo de 500 ms --------------------------------------/
RETARDO
	movlw	.2
	movwf	t
	movlw	.231
	movwf	g
	movlw	.255
	movwf	n
CICLO1
	nop
	decfsz	n,1			; Decrementa valor de n y guarda el resultado en n
	bra		CICLO1		
CICLO2					; al terminar decremento, se tiene un total de 1 ms
	nop					;
	decfsz	g,1			; 
	bra		CICLO1		; multiplica g * n (1 ms), seria el tiempo obtenido
CICLO3
	nop
	decfsz	t,1
	bra		CICLO1		; multiplica el valor de g * t
	return				; Regresa a la linea donde fue llamado

end