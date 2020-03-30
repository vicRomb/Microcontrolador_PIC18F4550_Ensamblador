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

org 0x0000
	; CONFIGURA TIMER 0
	movlw	b'10000100'
	movwf	T0CON
	
	; CONFIGURAR EL PA DIGITAL
	movlw	0Fh
	movwf	ADCON1
	movlw	07h
	movwf	CMCON
	;
	clrf	PORTD	;limpia puerto D
	clrf	PORTB
	clrf	PORTC
	
	setf	TRISB	; PUERTO B como entrada
	clrf	TRISD	; puerto D como salida
	bcf	TRISC,0 ; PD,0 como salida RS
	bcf	TRISC,1	; PD,1 como salida ENABLE
	bsf	TRISC,2	; PD,2 como entrada Pulsador Escribir
	bsf	TRISC,3	; PD,3 como entrada Pulsador Limpiar
	bsf	TRISC,4	; PD,4 como entrada Pulsador Salto Linea
	
	; ETIQUETAS ***************************************
	#define RS PORTC,0	; Pin RS del LCD
	#define ENA PORTC,1	; Pin Enable del LCD
	#define B_E PORTC,2	; Pulsador Escribir
	#define B_L PORTC,3	; Pulsador Limpiar pantalla
	#define B_SL PORTC,4	; Pulsador Salto Linea
	
	INICIO
	    call    INICIALIZAR
	    
	
	; INICIALIZAR LCD
	INICIALIZAR
	; FUNCTION SET
	    call    RETARDO20MS	
	    call    RETARDO5MS
	    movlw   b'00111000'
	    movwf   PORTD
	    bcf	    RS
	    call    RETARDO50US
	    bsf	    RS
	    call    RETARDO50US
	    bcf	    ENA
	    call    RETARDO50US
	; DISPLAY ON/OFF CONTROL
	    movlw   b'00001111'
	    movwf   PORTD
	    bcf	    RS
	    call    RETARDO50US
	    bsf	    RS
	    call    RETARDO50US
	    bcf	    ENA
	    ;
	    call    RETARDO50US
	; DISPLAY CLEAR
	    movlw   b'00000001'
	    movwf   PORTD
	    bcf	    RS
	    call    RETARDO50US
	    bsf	    RS
	    call    RETARDP50US
	    bcf	    ENA
	    ;
	    call    RETARDO5MS
	 ; ENTRY MODE
	    movlw   b'00000110'
	    movwf   PORTD
	    bcf	    RS
	    bsf	    ENA
	    call    RETARDO50US
	    bsf	    RS
	    bcf	    ENA
	    call    RETARDO5MS
	    return
	  