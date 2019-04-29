	;
	; DEFINICIONES Y CONSTANTES DE MSX 1
	; LIBRERA BASICA DE MSX 1
	;
	; (2019) Humberto Martinez barbera
	;
	; --------------------------------------------------
	;
	; DEFINICIONES ROM-BIOS (MSX1)
	;
WRTVDP	equ	#0047 	; Escribir registro VDP
RDVRM	equ	#004a	; Leer valor de VRAM
WRTVRM	equ	#004d	; Escribir valor en VRAM
LDIRVM	equ	#005c	; Copia en bloque RAM->VRAM
CHGMOD	equ	#005f	; Inicializa la pantalla
CHGCLR	equ	#0062	; Cambia los colores
CLRSPR	equ	#0069	; Inicializa los sprites
GICINI	equ	#0090	; Inicializacion del PSG
WRTPSG	equ	#0093	; Escritura en el PSG
RDPSG	equ	#0096	; Lectura del PSG
BEEP	equ	#00c0	; Realiza un pitido
GTSTCK	equ	#00d5	; Lectura estado joystick
GTTRIG	equ	#00d8	; Lectura estado trigger
GTPAD	equ	#00db	; Lectura movimiento de raton
SNSMAT	equ	#0141	; Valor de tecla pulsada
	;
	; DEFINICIONES BASIC SYSTEM VARIABLES (MSX1)
	;
FORCLR	equ	#f3e9	; color frontal
BAKCLR	equ	#f3ea	; color de fondo
BDRCLR	equ	#f3eb	; color del borde
PUTPNT	equ	#f3f8	; direccion buffer teclado (libre)
GETPNT	equ	#f3fa	; direccion siguiente dato buffer teclado
RETVAL	equ	#f7f8	; valor de retorno USR(n)
SCRMOD	equ	#fcaf	; modo de pantalla (0-8)
	;
	; OTRAS DEFINICIONES
	;
VDP_0	equ	#f3df	; VDP registers 0-7
VDP_8	equ	#ffe7	; VDP registers 8-23
VDP_25	equ	#fffa	; VDP registers 25-27
	;
	; DEFINICIONES PUERTOS I/O
	;
VDP_PORT0	equ	#98	; VRAM read/write
VDP_PORT1	equ	#99	; VDP registers read/write
VDP_PORT2	equ	#9a	; Palette registers write
VDP_PORT3	equ	#9b	; Indirect register write
	;
PSG_PORT0	equ	#a0	; PSG register write port
PSG_PORT1	equ	#a1	; Value wirte port
PSG_PORT2	equ	#a2	; Value read port
	;
	; DEFINICIONES PANTALLAS (VDP)
	;
SC2_TILEPAT	equ	#0000	; bancos de patrones   (0x1800)
SC2_TILEMAP	equ	#1800	; mapa de patrones     (0x0300)
SC2_SPRITATTR	equ	#1b00	; atributos de sprites (0x0080)
SC2_TILECOL	equ	#2000	; bancos de colores    (0x1800)
SC2_SPRITPAT	equ	#3800	; patrones de sprites  (0x0800)
	;
	; DEFINICIONES REGISTROS PSG
	;
PSG_FREQ_A0	equ	#00	; Frecuencia canal A (bajo)
PSG_FREQ_A1	equ	#01	; Frecuencia canal A (alto)
PSG_FREQ_B0	equ	#02	; Frecuencia canal B (bajo)
PSG_FREQ_B1	equ	#03	; Frecuencia canal B (alto)
PSG_FREQ_C0	equ	#04	; Frecuencia canal C (bajo)
PSG_FREQ_C1	equ	#05	; Frecuencia canal C (alto)
PSG_NOISE	equ	#06	; Frecuencia del ruido
PSG_SETTINGS	equ	#07	; Configuracion de canales
PSG_VOL_A	equ	#08	; Volumen canal A
PSG_VOL_B	equ	#09	; Volumen canal B
PSG_VOL_C	equ	#0a	; Volumen canal C
PSG_ENVEL0	equ	#0b	; Ciclo envolvente (bajo)
PSG_ENVEL1	equ	#0c	; Ciclo envolvente (alto)
PSG_PATTERN	equ	#0d	; Patron envolvente
PSG_IOPORT_A	equ	#0e	; Puerto de E/S A
PSG_IOPORT_B	equ	#0f	; Puerto de E/S B
	;
	; DEFINICIONES IDENTIFICADORES GTSTCK/GTTRIG/GTPAD
	;
	; MSX1
SPAC_BUT1	equ	0	; Barra espaciadora
JOY1_BUT1	equ	1	; Joystick 1, boton A
JOY1_BUT2	equ	3	; Joystick 1, boton B
JOY2_BUT1	equ	2	; Joystick 2, boton A
JOY2_BUT2	equ	4	; Joystick 2, boton B
	;
	; DEFINICIONES PARAMETROS MSX
	;
SCRMODE_TXT1	equ	0	; SCREEN 0, 40 chars/column
SCRMODE_MULTI	equ	3	; SCREEN 3
SCRMODE_GFX1	equ	1	; SCREEN 1
SCRMODE_GFX2	equ	2	; SCREEN 2, 256x192 16 cols

SCREEN_OFF	equ	#00
SCREEN_ON	equ	#40

SPRITES_8x8	equ	%00
SPRITES_16x16	equ	%10
SPRITES_x1	equ	%00
SPRITES_x2	equ	%01
	;
	; --------------------------------------------------
	;
	; DEFINICIONES DE MACROS
	;
	; --------------------------------------------------
	;
	; Compara HL con otro registro de 16 bits
	;
CompareHl	MACRO	?reg
	or	a	; borra el flag C
	sbc	hl, ?reg
	add	hl, ?reg
	ENDM
	;
	; Escribe en un registro del VDP
	; A = valor a escribir en el registro
	;
VdpSetReg	MACRO	?reg
	di
	out	(VDP_PORT1),a
	ld	a,128 + ?reg	; registro VDP(?reg)
	ei
	out	(VDP_PORT1),a
	ENDM
	;
	; Escribe en un registro del VDP, no deshabilita interrupciones
	; A = valor a escribir en el registro
	;
VdpSetRegNI	MACRO	?reg
	out	(VDP_PORT1),a
	ld	a,128 + ?reg	; registro VDP(?reg)
	out	(VDP_PORT1),a
	ENDM
	;
	; Copia un bloque de RAM a la VRAM, en la pagina 0
	; Maximo 256 bytes !!!!!
	;
MvRam2Vram	MACRO	?ram, ?vram, ?len
	ld	a, #00
	ld	hl, ?vram
	call	VdpVramWrite
	ld	hl, ?ram
	ld	b, ?len
	ld	c, VDP_PORT0
	otir
	ENDM
	;
	; --------------------------------------------------
	;
	; ACCESO A FUNCIONALIDADES VDP
	;
	; --------------------------------------------------
	;
	; A = screen mode (0 to 8)
	; B = sprites type
	; D = screen on/off
	; ********* OJO falta ver si es SCREEN0 / 80 chars
VdpScnMode	push	bc
	sla	a
	ld	b, 0
	ld	c, a
	ld	ix, VdpScnTable
	add	ix, bc
	ld	a, (ix)
	VdpSetReg	0
	pop	bc
	ld	a, (ix+1)
	or	b
	or	d
	VdpSetReg	1
	ret
	;
	; VDP(0)
	; %00000010: set if we're in gfx mode 2 (all other bits must be 0)
	;
	; VDP(1)
	; %10000000: always 1 (4/16k vram)
	; %01000000: 1: screen active / 0: screen not active
	; %00100000: 1: interrupts active / 0: interrupts not active
	; %00010000: 1: mode text / 0: other modes
	; %00001000: 1: mode multicolor / 0: other modes
	; %00000000: always 0
	; %00000010: 1: sprites 16x16 / 0: sprites 8x8
	; %00000001: 1: sprites *2 / 0: sprites *1
	;
VdpScnTable	db	%00000000, %10010000
	db	%00000000, %10000000
	db	%00000010, %10000000
	db	%00000000, %10001000
	;
	; --------------------------------------------------
	; Set VDP port #99 to start writing at address AHL (17-bit)
	;
VdpVramWrite	rlc	h
	rla
	rlc	h
	rla
	srl	h
	srl	h
	di
              out	(VDP_PORT1),a ;set bits 15-17
              ld 	a,14+128
              out	(VDP_PORT1),a
              ld	a,l           ;set bits 0-7
              nop
	out	(VDP_PORT1),a
	ld	a,h	; set bits 8-14
	or	64	; + write access
	ei
	out	(VDP_PORT1),a
	ret              
	;
	; --------------------------------------------------
	; Set VDP port #99 to start reading at address AHL (17-bit)
	;
VdpVramRead	rlc	h
              rla
              rlc	h
              rla
              srl	h
              srl	h
              di
              out	(VDP_PORT1),a ;set bits 15-17
              ld 	a,14+128
              out	(VDP_PORT1),a
              ld	a,l           ;set bits 0-7
              nop
              out	(VDP_PORT1),a
              ld 	a,h           ;set bits 8-14
              ei                    	; + read access
              out	(VDP_PORT1),a
              ret
