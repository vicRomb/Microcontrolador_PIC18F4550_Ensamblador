; Control de LCD 16x2 con Timer 0
; Victor Romero Bautista

	List P=18F4550			; Modelo de uM a utilizar
	include <P18F4550.inc>		; Archivo de constantes

; /--------------------------- Configuración ------------------------------/
	CONFIG FOSC=HS				; Configuración de oscilador a 8 MHz
	CONFIG CPUDIV=OSC1_PLL2		; Divicion de la frec. del osci entre 1
	CONFIG PWRT=ON				; Estabilizar PIC al arranque
	CONFIG BOR=OFF				; Reset en bajo voltaje
	CONFIG WDT=OFF				; Perro guardian desactivado
	CONFIG MCLRE=ON				; Resete en Pin 1 activado
	CONFIG PBADEN=OFF			; Configura Puerto B como digital
	CONFIG LVP=OFF				; Uso del pic en bajo voltaje
	CONFIG DEBUG=OFF			; Bepuración en segundo plano
	CONFIG XINST=OFF			; Conjunto de instrucciones extendidas
; /-----------------------------------------------------------------------/
	Dato 	EQU 0x00	; variable para almacenar la parte baja del dip switch
	Dato2	EQU 0x01	; Variable para almacenar la parte alta del dip switch
	Dato3 	EQU	0x02
	
	ORG 0x0000
; ----------------- CONFIGURACION ---------------------------------------/
 	movlw	b'10000010' ; activa timer 0, con prescaler de 8
	movwf	T0CON		; configura timer0 a 16 bits

	movlw	0Fh
	movwf	ADCON1		; puerto A como entrada
	movlw	07h
	movwf	CMCON		; puerto A como digital

	bsf		PORTE,RDPU	; Activar resistencias Pull Up en PD
	
	clrf	PORTD		; limpia puerto D
	clrf	PORTB		; Limpia puerto B
	clrf	PORTA		; Limpia puerto A
	clrf	PORTC
	
	setf	TRISD		; Puerto D como salida
	clrf	TRISB		; puerto B como entrada  
	bcf		TRISA,0		; Puerto RC0 como salida
	bcf		TRISA,1		; Puerto RC1 como salida
	bsf		TRISA,2		; Puerto RC2 como entrada
	bsf		TRISA,3 	; Puerto RC3 como entrada
	bsf		TRISC,0		; Puerto RC4 como entrada	
	nop 				; Aguanta
; FIN CONFIGURACION	---------------------------------------------------/

; ETIQUETAS PARA PINES -----------------------------------------------/
	#define RS PORTA,0			; pin RS del LCD
	#define ENA	PORTA,1 		; pin ENABLE del LCD
	#define PUL_ES PORTA,2		; pin de pulsador para Escribir en LCD
	#define PUL_LI PORTA,3		; pin de pulsador para limpiar LCD
	#define PUL_SL PORTC,0		; pin de pulsador para salto de linea	
	nop 						; espera
; Fin etiquetas -----------------------------------------------------/

; Programa Principal -----------------------------------------------/
INICIO
	call	INICIALIZAR			; Inicializa el LCD
CARGA	
	call	RETARDO50US			; Espera
	movf	PORTD,W				; Carga el valor de PB a Registro W
	movwf	Dato2				;  PB -> Dato
	andlw	0x0F				; '00001111' * W = dejar la parte baja, y guardalo en W
	movwf	Dato				;  mueve el resultado a Dato
	swapf	Dato,W				; intercambia nibles,
	movwf	Dato3
	bcf		ENA
ESCRIBE
	btfss	PUL_ES				; Lee Pulsador Escribir
	bra		SALTO	 			; Si = 0 ve a etiqueta Borrar
	call	ESCRIBIR			; Llama subrutina para escribir a 4 bits
	bra		BORRAR
SALTO
	btfss	PUL_SL				; Lee pulsador Salto de Linea
	bra		BORRAR				; Si = 0 ve a etiqueta borrar
	call	S_LINEA				; Llama subrutina de salto de linea
	call	RETARDO50US			; Espera
	call	CARGA
BORRAR
	btfss	PUL_LI				; Lee pulsador Limpiar
	bra		CARGA				; Si = 0 Ve a etiqueta Carga
	call	LIMPIAR				; Ve a etiqueta Inicio
	bra		CARGA
; Fin programa principal ---------------------------------------------/

; Subrutina Escribir a 4 Bits
ESCRIBIR
	bsf		RS				;
	bcf		ENA
	call	RETARDO50US
	movf	Dato2,W				; Parte baja
	movwf	PORTB
	bsf		ENA
	call	RETARDO5US
	bcf		ENA
	movf	Dato3,W				; Parte alta
	movwf	PORTB
	bsf		ENA
	call	RETARDO5US
	bcf		ENA
	call	RETARDO5MS
	return

; Subrutina para salto de linea -------------------------------------/
S_LINEA
	bcf		RS
	bcf		ENA
	call	RETARDO50US
	movlw	b'11000000'
	movwf	PORTB
	bsf		ENA
	call	RETARDO5US
	bcf		ENA
	call	RETARDO5US
	movlw	b'00000000'
	movwf	PORTB
	bsf		ENA
	call	RETARDO5US
	bcf		ENA
	call	RETARDO5MS
	return

; Subrutina para limpiar LCD
LIMPIAR
	bcf		RS
	bcf		ENA
	call	RETARDO50US
	movlw	b'00000000'
	movwf	PORTB
	bsf		ENA
	call	RETARDO50US
	bcf		ENA
	call	RETARDO50US
	movlw	b'00010000'
	movwf	PORTB
	bsf		ENA
	call	RETARDO50US
	bcf		ENA
	call	RETARDO5MS
	return
; Subrutina para inicializar LCD a 4 bits ------------------------------/
INICIALIZAR
	call	RETARDO20MS
	call	RETARDO5MS		; Retardo de 25ms
; Function Set
	movlw	b'00100000'
	movwf	PORTB
	bcf		RS
	call	RETARDO50US
	bsf		ENA
	call	RETARDO50US
	bcf		ENA
	movlw	b'00100000'
	movwf	PORTB
	call	RETARDO50US
	bcf		RS
	bsf		ENA
	call	RETARDO50US
	bcf		ENA
	call	RETARDO50US
	movlw	b'10000000'
	movwf	PORTB
	call	RETARDO50US
	bsf		ENA
	bcf		RS
	call	RETARDO50US
	bcf		ENA
; ----------------------------------------------
	call	RETARDO50US
; DISPLAY ON/OFF
	movlw	b'00000000'
	movwf	PORTB
	call	RETARDO50US
	bsf		ENA
	bcf		RS
	call	RETARDO50US
	bcf		ENA
	call	RETARDO50US
	movlw	b'11110000'
	movwf	PORTB
	call	RETARDO5US
	bsf		ENA
	bcf		RS
	call	RETARDO5US
	bcf		ENA
; ---------------------------------------------
	call	RETARDO50US
; Display Clear
	movlw	b'00000000'
	movwf	PORTB
	bsf		ENA
	bcf		RS
	call	RETARDO5US
	bcf		ENA
	movlw	b'00010000'
	movwf	PORTB
	bsf		ENA
	bcf		RS
	call	RETARDO5US
	bcf		ENA	
;----------------------------------------------
	call	RETARDO5MS
; Entry Mode
	movlw	b'00000000'
	movwf	PORTB
	bsf		ENA
	bcf		RS
	call	RETARDO50US
	bcf		ENA
	call	RETARDO50US
	movlw	b'00110000'
	movwf	PORTB
	bsf		ENA
	bcf		RS
	call	RETARDO5MS
	bcf		ENA
; ---------------------------------------------
	call	RETARDO5MS 	; Listo
	return
; Finaliza subrutina de inicialización --------------------------------/

; ********************* SUBRUTINAS DE RETARDO **************************
; Retardo 5 microsegundos cargar 8ACE ---------------------------------/
RETARDO5US
; parte alta
	movlw	0x8A
	movwf	TMR0H		; Carga a parte alta
; Parte baja
	movlw	0xCE
	movwf	TMR0L		; Carga a parte baja
ENCUE5US
	btfss	INTCON,TMR0IF
	bra		ENCUE5US
	bcf		INTCON,TMR0IF
	return
;---------------------------------------------------------------------

; Retardo 50 microsegundos cargar 8AC3 -------------------------------/
RETARDO50US
	movlw	0x8A	
	movwf	TMR0H
	movlw	0xC3
	movwf	TMR0L
ENCUE50US	
	btfss	INTCON,TMR0IF
	bra		ENCUE50US
	bcf		INTCON,TMR0IF
	return
;--------------------------------------------------------------------/

; Retardo 5 milisegundos cargar 85EE ---------------------------------/
RETARDO5MS
	movlw	0x85
	movwf	TMR0H
	movlw	0xEE
	movwf	TMR0L
ENCUE5MS
	btfss	INTCON,TMR0IF
	bra		ENCUE5MS
	bcf		INTCON,TMR0IF
	return
;---------------------------------------------------------------------/

; Retardo 20 milisegundos cargar 7748 --------------------------------/
RETARDO20MS
	movlw	0x77
	movwf	TMR0H
	movlw	0x48
	movwf	TMR0L
ENCUE20MS	
	btfss	INTCON,TMR0IF
	bra		ENCUE20MS
	bcf		INTCON,TMR0IF
	return
;--------------------------------------------------------------------/
end