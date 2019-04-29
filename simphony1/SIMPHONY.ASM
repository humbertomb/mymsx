	;
	; SIMPHONY, version MSX1, cargador BASIC
	;
	; (1987) Humberto Martinez Barbera
	; (2019) Humberto Martinez barbera
	;
	; --------------------------------------------------
	;
	; DIRECCIONES USUARIO
	;
bufflen1	equ	#d500	; longitud de buffer T#1
bufflen2	equ	#da00	; longitud de buffer T#2
	;
notabuff1	equ	bufflen1+2	; buffer para T#1
notabuff2	equ	bufflen2+2	; buffer para T#2
	;
	; CONSTANTES USUARIO
	;
tespera	equ	#1000
	;
DISABLE	equ	#00	; elemento deshabilitado
ENABLE	equ	#01	; elemento habilitado
	;
	; --------------------------------------------------
	;
	; CABECERA ARCHIVO 'BIN'
	;
	; --------------------------------------------------
	;
	org	#c100	; direccion inicio en MSX-BASIC
	;
	db	#fe
	dw	INICIO1
	dw	FINAL
	dw	INICIO1
	; --------------------------------------------------
	;
	; INICIALIZACION (SOLO UNA VEZ)
	;
	; --------------------------------------------------
INICIO1	call	INITSCREEN
	call	INITPSG
	;
	; resetea los buffers, longitudes iniciales a cero
	ld	hl, #0000
	ld	(bufflen1), hl
	;
	ld	hl, #0000
	ld	(bufflen2), hl
	;
	; --------------------------------------------------
	;
	; INICIALIZACION (RE-ENTRADA)
	;
	; --------------------------------------------------
	;
INICIO2	ld	hl, SPRI_SALVAR+2
	ld	a, PAT_BLANCO
	call	WRTVRM
	;
	ld	hl, SPRI_CARGAR+2
	ld	a, PAT_BLANCO
	call	WRTVRM
	;
	; --------------------------------------------------
	;
	; BUCLE PRINCIPAL
	;
	; --------------------------------------------------
	;
loop	call	ENVOLVENTE
	call	VOLUMEN
	call	TECLADO1
	call	GRABA1
	call	TECLADO2
	call	GRABA2
	call	REPET1
	call	REPET2
	call	RUIDO
	call	ACOMP
	;
	; comprobamos la tecla pulsada
	ld	a, #07
	call	SNSMAT
	bit	2, a	; 'ESC'
	jp	z, quit
	;
	ld	a, #06
	call	SNSMAT
	bit	3, a	; 'CAPS'
	jp	z, save
	bit	1, a	; 'CTRL'
	jp	z, load
	;
	; esperamos un tiempo para ralentizar el bucle
	ld	de, tespera
espera	dec	de
	ld	a, d
	or	e
	jp	nz, espera
	jp	loop
	;
	; salida a BASIC con A=10
save	ld	hl, SPRI_SALVAR+2
	ld	a, PAT_SI
	call	WRTVRM
	;
	ld	hl, #000a
	ld	(RETVAL), hl
	ret
	;
	; salida a BASIC con A=20
load	ld	hl, SPRI_CARGAR+2
	ld	a, PAT_SI	
	call	WRTVRM
	;
	ld	hl, #0014
	ld	(RETVAL), hl
	ret
	;
	; salida a BASIC con A=0
quit	ld	hl, #0000
	ld	(RETVAL), hl
	ret
	;
	; --------------------------------------------------
	;
	; REPETICION #1
	;
	; --------------------------------------------------
REPET1	; comprobamos si esta habilitado el teclado
	ld	a, (keyena1)
	cp	ENABLE
	jp	nz, repplay1 
	; comprobamos la tecla pulsada
	ld	a,#07
	call	SNSMAT
	bit	7,a	; 'RET'
	jp	z,repini1
	bit	5,a	; 'BS'	
	jp	z,repini1
	ret
	;
	; inicializamos los parametros de reproduccion
	;
repini1	ld	hl, SPRI_REP1+2 ; muestra sprite
	ld	a, PAT_SI
	call	WRTVRM
	;
	ld	a, DISABLE	; deshabilitamos el teclado
	ld	(keyena1), a
	; 
	ld	hl, notabuff1
	ld	(buffndx1), hl ; posicion inicial del buffer
	ld	bc, (bufflen1) ; longitud usada del buffer
	add	hl, bc
	ld	(buffend1), hl ; fin del buffer
	;
	; reproducimos la nota almacenada
	;
repplay1	ld	hl, (buffndx1)
	ld	bc, (buffend1)
	CompareHl	bc
	jp	z, repfin1
	;
	ld	hl, (buffndx1)
	ld	a, (hl)	; carga nota actual (L)
	ld	e, a
	ld	a, PSG_FREQ_A0
	call	WRTPSG
	;
	inc	hl
	ld	a, (hl)	; carga nota actual (H)
	ld	e, a
	ld	a, PSG_FREQ_A1
	call	WRTPSG
	;
	inc	hl
	ld	(buffndx1), hl ; siguiente posicion buffer
	ret
	;
	; fin de la reproduccion
	;
repfin1	ld	hl, SPRI_REP1+2 ; oculta sprite
	ld	a, PAT_BLANCO
	call	WRTVRM
	;
	ld	e, #00
	ld	a, PSG_FREQ_A0 ; desactiva el sonido
	call	WRTPSG
	ld	e, #00
	ld	a, PSG_FREQ_A1 ; desactiva el sonido
	call	WRTPSG
	;
	ld	a, ENABLE	; habilitamos el teclado
	ld	(keyena1), a
	ret
	; --------------------------------------------------
	;
	; REPETICION #2
	;
	; --------------------------------------------------
REPET2	; comprobamos si esta habilitado el teclado
	ld	a, (keyena2)
	cp	ENABLE
	jp	nz, repplay2 
	; comprobamos la tecla pulsada
	ld	a,#01
	call	SNSMAT
	bit	7,a	; 'Ñ'
	jp	z,repini2
	ld	a,#07
	call	SNSMAT
	bit	5,a	; 'BS'
	jp	z,repini2
	ret
	;
	; inicializamos los parametros de reproduccion
	;
repini2	ld	hl, SPRI_REP2+2 ; muestra sprite
	ld	a, PAT_SI
	call	WRTVRM
	;
	ld	a, DISABLE	; deshabilitamos el teclado
	ld	(keyena2), a
	; 
	ld	hl, notabuff2
	ld	(buffndx2), hl ; posicion inicial del buffer
	ld	bc, (bufflen2) ; longitud usada del buffer
	add	hl, bc
	ld	(buffend2), hl ; fin del buffer
	;
repplay2	; reproducimos la nota almacenada
	;
	ld	hl, (buffndx2)
	ld	bc, (buffend2)
	CompareHl	bc
	jp	z, repfin2
	;
	ld	hl, (buffndx2)
	ld	a, (hl)	; carga nota actual (L)
	ld	e, a
	ld	a, PSG_FREQ_B0
	call	WRTPSG
	;
	inc	hl
	ld	a, (hl)	; carga nota actual (H)
	ld	e, a
	ld	a, PSG_FREQ_B1
	call	WRTPSG
	;
	inc	hl
	ld	(buffndx2), hl ; siguiente posicion buffer
	ret
	;
	; fin de la reproduccion
	;
repfin2	ld	hl, SPRI_REP2+2 ; oculta sprite
	ld	a, PAT_BLANCO
	call	WRTVRM
	;
	ld	e, #00
	ld	a, PSG_FREQ_B0 ; desactiva el sonido
	call	WRTPSG
	ld	e, #00
	ld	a, PSG_FREQ_B1 ; desactiva el sonido
	call	WRTPSG
	;
	ld	a, ENABLE	; habilitamos el teclado
	ld	(keyena2), a
	ret
	; --------------------------------------------------
	;
	; GRABACION #1
	;
	; --------------------------------------------------
GRABA1	; comprobamos si esta habilitado el teclado
	ld	a, (keyena1)
	cp	ENABLE
	ret	nz 
	; comprobamos si estamos grabando
	ld	a, (graena1)
	cp	ENABLE
	jp	z, grachk1 
	; comprobamos la tecla pulsada
	ld	a,#02
	call	SNSMAT
	bit	0,a	; '''
	jp	z,graini1
	ret
	; comprobamos la tecla pulsada	
grachk1	ld	a,#02
	call	SNSMAT
	bit	1,a	; ';'	
	jp	z,grafin1
	jp	grarec1
	;
	; inicializamos los parametros de grabacion
	;
graini1	ld	hl, SPRI_GRA1+2 ; muestra sprite
	ld	a, PAT_SI
	call	WRTVRM
	;
	ld	a, ENABLE	; activamos la grabacion
	ld	(graena1), a
	; 
	ld	hl, #0000
	ld	(bufflen1), hl ; longitud inicial del buffer
	ld	hl, notabuff1
	ld	(buffndx1), hl ; posicion inicial del buffer
	;
grarec1	; almacenamos la nota actual
	;
	ld	hl, (buffndx1)
	ld	a, (curnote1)	; ultima nota pulsada (L)
	ld	(hl), a	; almacena nota actual
	inc	hl
	ld	a, (curnote1+1) ; ultima nota pulsada (H)
	ld	(hl), a	; almacena nota actual
	inc	hl
	ld	(buffndx1), hl ; avanza el indice del buffer
	ld	hl, (bufflen1)
	inc	hl
	inc	hl
	ld	(bufflen1), hl ; aumenta el tamaño del buffer
	;
	; hacer parpadear el sprite !!!!!!
	;
	ret
	;
	; fin de la grabacion
	;
grafin1	ld	hl, SPRI_GRA1+2 ; oculta sprite
	ld	a, PAT_BLANCO
	call	WRTVRM
	;
	ld	a, DISABLE	; desactivamos la grabacion
	ld	(graena1), a
	ret
	; --------------------------------------------------
	;
	; GRABACION #2
	;
	; --------------------------------------------------
GRABA2	; comprobamos si esta habilitado el teclado
	ld	a, (keyena2)
	cp	ENABLE
	ret	nz 
	; comprobamos si estamos grabando
	ld	a, (graena2)
	cp	ENABLE
	jp	z, grachk2 
	; comprobamos la tecla pulsada
	ld	a, #02
	call	SNSMAT
	bit	4, a	; '\'
	jp	z, graini2
	ret
	; comprobamos la tecla pulsada	
grachk2	ld	a, #02
	call	SNSMAT
	bit	5, a	; 'DEAD'	
	jp	z, grafin2
	jp	grarec2
	;
	; inicializamos los parametros de grabacion
	;
graini2	ld	hl, SPRI_GRA2+2 ; muestra sprite
	ld	a, PAT_SI
	call	WRTVRM
	;
	ld	a, ENABLE	; activamos la grabacion
	ld	(graena2), a
	; 
	ld	hl, #0000
	ld	(bufflen2), hl ; longitud inicial del buffer
	ld	hl, notabuff2
	ld	(buffndx2), hl ; posicion inicial del buffer
	;
grarec2	; almacenamos la nota actual
	;
	ld	hl, (buffndx2)
	ld	a, (curnote2)	 ; ultima nota pulsada (L)
	ld	(hl), a	; almacena nota actual
	inc	hl
	ld	a, (curnote2+1) ; ultima nota pulsada (H)
	ld	(hl), a	; almacena nota actual
	inc	hl
	ld	(buffndx2), hl ; avanza el indice del buffer
	ld	hl, (bufflen2)
	inc	hl
	inc	hl
	ld	(bufflen2), hl ; aumenta el tamaño del buffer
	;
	; hacer parpadear el sprite !!!!!!
	;
	ret
	;
	; fin de la grabacion
	;
grafin2	ld	hl, SPRI_GRA2+2 ; oculta sprite
	ld	a, PAT_BLANCO
	call	WRTVRM
	;
	ld	a, DISABLE	; desactivamos la grabacion
	ld	(graena2), a
	ret
	;
	; --------------------------------------------------
	;
	; TECLADO INFERIOR #2
	;
	; --------------------------------------------------
TECLADO2	; comprobamos si esta habilitado el teclado
	ld	a, (keyena2)
	cp	ENABLE
	ret	nz 
	; comprobamos la tecla pulsada
	ld 	a,#02
	call	SNSMAT
	bit	6,a	; 'A'
	jp	z,t2cs
	bit	7,a	; 'B'
	jp	z,t2a
	;
	ld	a,#03
	call	SNSMAT
	bit	0,a	; 'C'
	jp	z,t2f
	bit	3,a	; 'F'
	jp	z,t2fs
	bit	4,a	; 'G'
	jp	z,t2gs
	bit	5,a	; 'H'
	jp	z,t2as
	;
	ld	a,#04
	call	SNSMAT
	bit	3,a	; 'N'
	jp	z,t2b
	;
	ld	a,#05
	call	SNSMAT
	bit	0,a	; 'S'
	jp	z,t2ds
	bit	3,a	; 'V'
	jp	z,t2g
	bit	5,a	; 'X'
	jp	z,t2e
	bit	7,a	; 'Z'
	jp	z,t2d
	;
	ld	a,#06
	call	SNSMAT
	bit	0,a	; 'SHIFT'
	jp	z,t2c
	; no hay tecla pulsada
	ld	a, #00
	ld	(curkey2),a
	ld	e, notaoff
	ld	b, #cf
	;
	; situamos 4 sprites 16x16 y generamos el sonido
	; A: coordenadas X de los sprites
	; B: coordenadas Y de los sprites
	; E: codigo de nota
	;
	; coordenadas X
t2fin	ld	hl, SPRI_T2_SPR0+1
	call	WRTVRM
	ld	hl, SPRI_T2_SPR1+1
	call	WRTVRM
	add	a, #10
	ld	hl, SPRI_T2_SPR2+1
	call	WRTVRM
	ld	hl, SPRI_T2_SPR3+1
	call	WRTVRM
	; coordenadas Y 
	ld	a, b
	ld	hl, SPRI_T2_SPR0
	call	WRTVRM
	ld	hl, SPRI_T2_SPR2
	call	WRTVRM
	add	a, #10
	ld	hl, SPRI_T2_SPR1
	call	WRTVRM
	ld	hl, SPRI_T2_SPR3
	call	WRTVRM
	;	
	; nota = tablanotas + nota x 16 + octava x 2
	ld	hl, tablanotas ; HL = tablanotas
	ld	b, #00
	ld	a, (octave2)
	sla	a
	ld	c, a
	add	hl, bc	; HL += octava x 2
	sla	e
	sla	e
	sla	e
	sla	e
	ld	c, e
	add	hl, bc	; HL += nota x 16
	;	
	; establece el valor de la nota en el PSG
	ld	a, (hl)
	ld	(curnote2), a	; almacena la nota (L)
	ld	e, a
	ld	a, PSG_FREQ_B0
	call	WRTPSG
	;
	inc	hl
	ld	a, (hl)
	ld	(curnote2+1), a ; almacena la nota (H)
	ld	e, a
	ld	a, PSG_FREQ_B1
	call	WRTPSG
	ret
	;
	; establecimiento de notas y sus parametros
	;
	; notas naturales
	;	
t2c	ld	a, (curkey2)
	cp	#01
	ret	z
	ld	a, #01
	ld	(curkey2), a
	ld	e, notaC
	ld	a, #0f
	ld	b, #7d
	jp	t2fin
	;
t2d	ld	a, (curkey2)
	cp	#02
	ret	z
	ld	a, #02
	ld	(curkey2), a
	ld	e, notaD
	ld	a, #19
	ld	b, #7d
	jp	t2fin
	;
t2e	ld	a, (curkey2)
	cp	#03
	ret	z
	ld	a, #03
	ld	(curkey2), a
	ld	e, notaE
	ld	a, #23
	ld	b, #7d
	jp	t2fin
	;
t2f	ld	a, (curkey2)
	cp	#04
	ret	z
	ld	a, #04
	ld	(curkey2), a
	ld	e, notaF
	ld	a, #2d
	ld	b, #7d
	jp	t2fin
	;
t2g	ld	a, (curkey2)
	cp	#05
	ret	z
	ld	a, #05
	ld	(curkey2), a
	ld	e, notaG
	ld	a, #37
	ld	b, #7d
	jp	t2fin
	;
t2a	ld	a, (curkey2)
	cp	#06
	ret	z
	ld	a, #06
	ld	(curkey2), a
	ld	e, notaA
	ld	a, #41
	ld	b, #7d
	jp	t2fin
	;
t2b	ld	a, (curkey2)
	cp	#07
	ret	z
	ld	a, #07
	ld	(curkey2), a
	ld	e, notaB
	ld	a, #4b
	ld	b, #7d
	jp	t2fin
	;
	; notas alteradas (cromaticas)
	;				
t2cs	ld	a, (curkey2)
	cp	#08
	ret	z
	ld	a, #08
	ld	(curkey2), a
	ld	e, notaCs
	ld	a, #14
	ld	b, #69
	jp	t2fin
	;
t2ds	ld	a, (curkey2)
	cp	#09
	ret	z
	ld	a, #09
	ld	(curkey2), a
	ld	e, notaDs
	ld	a, #1e
	ld	b, #69
	jp	t2fin
	;
t2fs	ld	a, (curkey2)
	cp	#0a
	ret	z
	ld	a, #0a
	ld	(curkey2), a
	ld	e, notaFs
	ld	a, #32
	ld	b, #69
	jp	t2fin
	;
t2gs	ld	a, (curkey2)
	cp	#0b
	ret	z
	ld	a, #0b
	ld	(curkey2), a
	ld	e, notaGs
	ld	a, #3c
	ld	b, #69
	jp	t2fin
	;
t2as	ld	a, (curkey2)
	cp	#0c
	ret	z
	ld	a, #0c
	ld	(curkey2), a
	ld	e, notaAs
	ld	a, #46
	ld	b, #69
	jp	t2fin
	;
	; --------------------------------------------------
	;
	; TECLADO SUPERIOR #1
	;
	; --------------------------------------------------	
TECLADO1	; comprobamos si esta habilitado el teclado
	ld	a, (keyena1)
	cp	ENABLE
	ret	nz 
	; comprobamos la tecla pulsada
	ld 	a,#00
	call	SNSMAT
	bit	1,a	; '1'
	jp	z,t1cs1
	bit	2,a	; '2'
	jp	z,t1ds1
	bit	4,a	; '4'
	jp	z,t1fs1
	bit	5,a	; '5'
	jp	z,t1gs1
	bit	6,a	; '6'
	jp	z,t1as1
	;
	ld	a,#01
	call	SNSMAT
	bit	0,a	; '8'
	jp	z,t1cs2
	bit	1,a	; '9'
	jp	z,t1ds2
	bit	2,a	; '-'
	jp	z,t1fs2
	bit	3,a	; '='
	jp	z,t1gs2
	bit	4,a	; '\'
	jp	z,t1as2
	bit	5,a	; '['
	jp	z,t1g2
	bit	6,a	; ']'
	jp	z,t1a2
	;
	ld	a,#03
	call	SNSMAT
	bit	6,a	; 'I'
	jp	z,t1d2
	bit	2,a	; 'E'
	jp	z,t1f1
	;
	ld	a,#04
	call	SNSMAT
	bit	7,a	; 'R'
	jp	z,t1g1
	bit	6,a	; 'Q'
	jp	z,t1d1
	bit	5,a	; 'P'
	jp	z,t1f2
	bit	4,a	; 'O'
	jp	z,t1e2
	;
	ld	a,#05
	call	SNSMAT
	bit	4,a	; 'W'
	jp	z,t1e1
	bit	1,a	; 'T'
	jp	z,t1a1
	bit	6,a	; 'Y'
	jp	z,t1b1
	bit	2,a	; 'U'
	jp	z,t1c2
	;
	ld	a,#07
	call	SNSMAT
	bit	6,a	; 'SEL'
	jp	z,t1b2
	bit	3,a	; 'TAB'
	jp	z,t1c1
	; no hay tecla pulsada
	ld	a,#00
	ld	(curkey1),a
	ld	e, notaoff
	ld	c, #00
	ld	b,#cf
	;
	; situamos 4 sprites 16x16 y generamos el sonido
	; A: coordenadas X de los sprites
	; B: coordenadas Y de los sprites
	; E: codigo de nota
	; C: codigo de octava
	;
	; coordenadas X
t1fin	ld	hl, SPRI_T1_SPR0+1
	call	WRTVRM
	ld	hl, SPRI_T1_SPR1+1
	call	WRTVRM
	add	a,#10
	ld	hl, SPRI_T1_SPR2+1
	call	WRTVRM
	ld	hl, SPRI_T1_SPR3+1
	call	WRTVRM
	; coordenadas Y 
	ld	a,b
	ld	hl, SPRI_T1_SPR0
	call	WRTVRM
	ld	hl, SPRI_T1_SPR2
	call	WRTVRM
	add	a,#10
	ld	hl, SPRI_T1_SPR1
	call	WRTVRM
	ld	hl, SPRI_T1_SPR3
	call	WRTVRM
	;	
	; nota = tablanotas + nota x 16 + octava x 2
	ld	hl, tablanotas ; HL = tablanotas
	ld	b, #00
	ld	a, (octave1)
	add	a, c	; incremento de octava del teclado
	sla	a
	ld	c, a
	add	hl, bc	; HL += octava x 2
	sla	e
	sla	e
	sla	e
	sla	e
	ld	c, e
	add	hl, bc	; HL += nota x 16
	;	
	; establece el valor de la nota en el PSG
	ld	a, (hl)
	ld	(curnote1), a	; almacena la nota (L)
	ld	e, a
	ld	a, PSG_FREQ_A0
	call	WRTPSG
	;
	inc	hl
	ld	a, (hl)
	ld	(curnote1+1), a ; almacena la nota (H)
	ld	e, a
	ld	a, PSG_FREQ_A1
	call	WRTPSG
	ret
	; establecimiento de notas y sus parametros
	;
	; notas naturales
	;	
t1c1	ld	a,(curkey1)
	cp	#01
	ret	z
	ld	a,#01
	ld	(curkey1),a
	ld	e, notaC
	ld	c, #00
	ld	b,#2d
	ld	a,#2d
	jp	t1fin
	;		
t1d1	ld	a,(curkey1)
	cp	#02
	ret	z
	ld	a,#02
	ld	(curkey1),a
	ld	e, notaD
	ld	c, #00
	ld	b,#2d
	ld	a,#37
	jp	t1fin
	;		
t1e1	ld	a,(curkey1)
	cp	#03
	ret	z
	ld	a,#03
	ld	(curkey1),a
	ld	e, notaE
	ld	c, #00
	ld	b,#2d
	ld	a,#41
	jp	t1fin
	;		
t1f1	ld	a,(curkey1)
	cp	#04
	ret	z
	ld	a,#04
	ld	(curkey1),a
	ld	e, notaF
	ld	c, #00
	ld	b,#2d
	ld	a,#4b
	jp	t1fin
	;		
t1g1	ld	a,(curkey1)
	cp	#05
	ret	z
	ld	a,#05
	ld	(curkey1),a
	ld	e, notaG
	ld	c, #00
	ld	b,#2d
	ld	a,#55
	jp	t1fin
	;		
t1a1	ld	a,(curkey1)
	cp	#06
	ret	z
	ld	a,#06
	ld	(curkey1),a
	ld	e, notaA
	ld	c, #00
	ld	b,#2d
	ld	a,#5f
	jp	t1fin
	;		
t1b1	ld	a,(curkey1)
	cp	#07
	ret	z
	ld	a,#07
	ld	(curkey1),a
	ld	e, notaB
	ld	c, #00
	ld	b,#2d
	ld	a,#69
	jp	t1fin
	;		
t1c2	ld	a,(curkey1)
	cp	#08
	ret	z
	ld	a,#08
	ld	(curkey1),a
	ld	e, notaC
	ld	c, #01
	ld	b,#2d
	ld	a,#73
	jp	t1fin
	;		
t1d2	ld	a,(curkey1)
	cp	#09
	ret	z
	ld	a,#09
	ld	(curkey1),a
	ld	e, notaD
	ld	c, #01
	ld	b,#2d
	ld	a,#7d
	jp	t1fin
	;		
t1e2	ld	a,(curkey1)
	cp	#0a
	ret	z
	ld	a,#0a
	ld	(curkey1),a
	ld	e, notaE
	ld	c, #01
	ld	b,#2d
	ld	a,#87
	jp	t1fin
	;		
t1f2	ld	a,(curkey1)
	cp	#0b
	ret	z
	ld	a,#0b
	ld	(curkey1),a
	ld	e, notaF
	ld	c, #01
	ld	b,#2d
	ld	a,#91
	jp	t1fin
	;		
t1g2	ld	a,(curkey1)
	cp	#0c
	ret	z
	ld	a,#0c
	ld	(curkey1),a
	ld	e, notaG
	ld	c, #01
	ld	b,#2d
	ld	a,#9b
	jp	t1fin
	;		
t1a2	ld	a,(curkey1)
	cp	#0d
	ret	z
	ld	a,#0d
	ld	(curkey1),a
	ld	e, notaA
	ld	c, #01
	ld	b,#2d
	ld	a,#a5
	jp	t1fin
	;		
t1b2	ld	a,(curkey1)
	cp	#0e
	ret	z
	ld	a,#0e
	ld	(curkey1),a
	ld	e, notaB
	ld	c, #01
	ld	b,#2d
	ld	a,#af
	jp	t1fin
	;
	; notas alteradas (cromaticas)
	;				
t1cs1	ld	a,(curkey1)
	cp	#0f
	ret	z
	ld	a,#0f
	ld	(curkey1),a
	ld	e, notaCs
	ld	c, #00
	ld	b,#19
	ld	a,#32
	jp	t1fin
	;		
t1ds1	ld	a,(curkey1)
	cp	#10
	ret	z
	ld	a,#10
	ld	(curkey1),a
	ld	e, notaDs
	ld	c, #00
	ld	b,#19
	ld	a, #3d
	jp	t1fin
	;		
t1fs1	ld	a,(curkey1)
	cp	#11
	ret	z
	ld	a,#11
	ld	(curkey1),a
	ld	e, notaFs
	ld	c, #00
	ld	b,#19
	ld	a,#50
	jp	t1fin
	;		
t1gs1	ld	a,(curkey1)
	cp	#12
	ret	z
	ld	a,#12
	ld	(curkey1),a
	ld	e, notaGs
	ld	c, #00
	ld	b,#19
	ld	a,#5a
	jp	t1fin
	;		
t1as1	ld	a,(curkey1)
	cp	#13
	ret	z
	ld	a,#13
	ld	(curkey1),a
	ld	e, notaAs
	ld	c, #00
	ld	b,#19
	ld	a,#64
	jp	t1fin
	;		
t1cs2	ld	a,(curkey1)
	cp	#14
	ret	z
	ld	a,#14
	ld	(curkey1),a
	ld	e, notaCs
	ld	c, #01
	ld	b,#19
	ld	a,#78
	jp	t1fin
	;		
t1ds2	ld	a,(curkey1)
	cp	#15
	ret	z
	ld	a,#15
	ld	(curkey1),a
	ld	e, notaDs
	ld	c, #01
	ld	b,#19
	ld	a,#82
	jp	t1fin
	;		
t1fs2	ld	a,(curkey1)
	cp	#16
	ret	z
	ld	a,#16
	ld	(curkey1),a
	ld	e, notaFs
	ld	c, #01
	ld	b,#19
	ld	a,#96
	jp	t1fin
	;		
t1gs2	ld	a,(curkey1)
	cp	#17
	ret	z
	ld	a,#17
	ld	(curkey1),a
	ld	e, notaGs
	ld	c, #01
	ld	b,#19
	ld	a,#a0
	jp	t1fin
	;		
t1as2	ld	a,(curkey1)
	cp	#18
	ret	z
	ld	a,#18
	ld	(curkey1),a
	ld	e, notaAs
	ld	c, #01
	ld	b,#19
	ld	a,#aa
	jp	t1fin
	;
	; --------------------------------------------------
	;
	; ENVOLVENTE
	;
	; --------------------------------------------------
ENVOLVENTE	; comprobamos la tecla pulsada
	ld 	a, #06
	call	SNSMAT
	bit	5, a	; 'F1'
	jp	z, envena
	bit	6, a	; 'F2'
	jp	z, envdisa
	;
	ld 	a, #08
	call	SNSMAT
	bit	7, a	; 'CSR_RIGHT'
	jp	z, efrqmas
	bit	4, a	; 'CSR_LEFT'
	jp	z, efrqmenos
	; comprobar el flag de tecla pulsada
	ld	e, a
	ld	a, (teclaonda)
	cp	#00
	jp	nz, envclear
	;
	bit	1, e	; 'HOME'
	jp	z, ewavemenos
	bit	2, e	; 'INS'
	jp	z, ewavemas
	;
	ld	a, #00
	ld	(teclaonda), a
	ret
	; resetear el flag cuando no este pulsada ninguna tecla
envclear	bit	1, e	; 'HOME'
	ret	z
	bit	2, e	; 'INS'
	ret	z
	ld	a, #00
	ld	(teclaonda), a
	ret
	;
	; habilita/deshabilita la envolvente (bit 4)
	;
envena	ld	a, PSG_VOL_A
	call	RDPSG
	ld	e, a
	set	4, e
	ld	a, PSG_VOL_A
	call	WRTPSG
	;
	ld	a, PSG_VOL_B
	call	RDPSG
	ld	e, a
	set	4, e
	ld	a, PSG_VOL_B
	call	WRTPSG
	;
	ld	a, PSG_VOL_C
	call	RDPSG
	ld	e, a
	set	4, e
	ld	a, PSG_VOL_C
	call	WRTPSG
	;
	ld	hl, SPRI_RITMO+2
	ld	a, PAT_SI
	call	WRTVRM
	ret
	;
envdisa	ld	a, PSG_VOL_A
	call	RDPSG
	ld	e, a
	res	4, e
	ld	a, PSG_VOL_A
	call	WRTPSG
	;
	ld	a, PSG_VOL_B
	call	RDPSG
	ld	e, a
	res	4, e
	ld	a, PSG_VOL_B
	call	WRTPSG
	;
	ld	a, PSG_VOL_C
	call	RDPSG
	ld	e, a
	res	4, e
	ld	a, PSG_VOL_C
	call	WRTPSG
	;
	ld	hl, SPRI_RITMO+2
	ld	a, PAT_BLANCO
	call	WRTVRM
	ret
	;	
	; forma de onda de la envolvente
	;
ewavemenos	ld	a, #01
	ld	(teclaonda), a ; ultima accion realizada
	;
	ld	a, (formaonda)
	cp	#01
	ret	z
	dec	a
	ld	(formaonda), a
	jp	ewavecheck
	;
ewavemas	ld	a, #02
	ld	(teclaonda), a ; ultima accion realizada
	;
	ld	a,(formaonda)
	cp	#0a
	ret	z
	inc	a
	ld	(formaonda), a
	;
ewavecheck	ld	a, (formaonda)
	cp	#01
	jp	nz, ewavechk2
	ld	e, #00
	ld	b, PAT_ONDA6
	ld	c, PAT_ONDA9
	jp	ewavefin
	;
ewavechk2	cp	#02
	jp	nz, ewavechk3
	ld	e, #04
	ld	b, PAT_ONDA5
	ld	c, PAT_ONDA9
	jp	ewavefin
	;
ewavechk3	cp	#03
	jp	nz, ewavechk4
	ld	e, #08
	ld	b, PAT_ONDA0
	ld	c, PAT_ONDA0
	jp	ewavefin
	;
	;
ewavechk4	cp	#04
	jp	nz, ewavechk5
	ld	e, #09
	ld	b, PAT_ONDA6
	ld	c, PAT_ONDA9
	jp	ewavefin
	;
	;
ewavechk5	cp	#05
	jp	nz, ewavechk6
	ld	e, #0a
	ld	b, PAT_ONDA1
	ld	c, PAT_ONDA2
	jp	ewavefin
	;
	;
ewavechk6	cp	#06
	jp	nz, ewavechk7
	ld	e, #0b
	ld	b, PAT_ONDA7
	ld	c, PAT_ONDA10
	jp	ewavefin
	;
	;
ewavechk7	cp	#07
	jp	nz, ewavechk8
	ld	e, #0c
	ld	b, PAT_ONDA3
	ld	c, PAT_ONDA3
	jp	ewavefin
	;
	;
ewavechk8	cp	#08
	jp	nz, ewavechk9
	ld	e, #0d
	ld	b, PAT_ONDA8
	ld	c, PAT_ONDA10
	jp	ewavefin
	;
	;
ewavechk9	cp	#09
	jp	nz, ewavechk10
	ld	e, #0e
	ld	b, PAT_ONDA4
	ld	c, PAT_ONDA4
	jp	ewavefin
	;
	;
ewavechk10	ld	e, #0f
	ld	b, PAT_ONDA5
	ld	c, PAT_ONDA9
	;	
ewavefin	; establece la forma de onda
	; E: valor del registro del PSG
	; B: patron del sprite izquierda
	; C: patron del sprite derecho
	ld	a, PSG_PATTERN
	call	WRTPSG
	ld	hl, SPRI_ENV0+2
	ld	a, b
	call	WRTVRM
	ld	hl, SPRI_ENV1+2
	ld	a, c
	call	WRTVRM
	ret
	;
	; frecuencia de la envolvente
	;
efrqmas	ld	a, (frecuencia)
	cp	#09
	ret	z
	inc	a
	ld	(frecuencia),a
	ld	e, a
	ld	a, PSG_ENVEL1
	call	WRTPSG	
	;
	ld	hl, SPRI_FREQ+1
	call	RDVRM
	add	a, #03
	call	WRTVRM
	ret
	;
efrqmenos	ld	a, (frecuencia)
	cp	#00
	ret	z
	dec	a
	ld	(frecuencia),a
	ld	e, a
	ld	a, PSG_ENVEL1
	call	WRTPSG
	;	
	ld	hl, SPRI_FREQ+1
	call	RDVRM
	sub	#03
	call	WRTVRM
	ret
	;
	; --------------------------------------------------
	;
	; GENERADOR DE RUIDO
	;
	; --------------------------------------------------
RUIDO	; comprobamos la tecla pulsada
	ld	a, #06
	call	SNSMAT
	bit	7, a	; 'F3'
	jp	z, ruidoena
	;
	ld	a, #07
	call	SNSMAT
	bit	0, a	; 'F4'
	jp	z, ruidodisa
	ret
	;
	; habilita el ruido en el canal C
	;
ruidoena	ld	a, PSG_SETTINGS
	call	RDPSG
	ld	e, a
	res	5, e
	ld	a, PSG_SETTINGS
	call	WRTPSG
	;
	ld	hl, SPRI_RUIDO+2
	ld	a, PAT_SI
	call	WRTVRM
	ret
	;
ruidodisa	ld	a, PSG_SETTINGS
	call	RDPSG
	ld	e, a
	set	5, e
	ld	a, PSG_SETTINGS
	call	WRTPSG
	;
	ld	hl, SPRI_RUIDO+2
	ld	a, PAT_BLANCO
	call	WRTVRM
	ret
	;
	; --------------------------------------------------
	;
	; VOLUMEN
	;
	; --------------------------------------------------
	; comprobamos la tecla pulsada
VOLUMEN	ld 	a,#02
	call	SNSMAT
	bit	3,a	; '.'
	jp	z,vol2menos
	bit	2,a	; ','
	jp	z,vol2mas
	;
	ld 	a,#04
	call	SNSMAT
	bit	0,a	; 'K'
	jp	z,vol1menos
	bit	1,a	; 'L'
	jp	z,vol1mas
	ret
	;
	; volumen de los canales
	;
vol2menos	ld	a, (volumen2)
	cp	#0f
	ret	z
	inc	a
	ld	(volumen2), a
	;
	ld	a, PSG_VOL_B
	call	RDPSG	
	and	%11110000	; preserva los bits significativos 
	ld	e, a
	ld	a, (volumen2)
	or	e
	ld	e, a
	ld	a, PSG_VOL_B
	call	WRTPSG	
	;	
	ld	hl, SPRI_T2_VOL+1
	call	RDVRM
	add	a, #03
	call	WRTVRM
	ret
	;
vol2mas	ld	a, (volumen2)
	cp	#01
	ret	z
	dec	a
	ld	(volumen2), a
	;
	ld	a, PSG_VOL_B
	call	RDPSG	
	and	%11110000	; preserva los bits significativos 
	ld	e, a
	ld	a, (volumen2)
	or	e
	ld	e, a
	ld	a, PSG_VOL_B
	call	WRTPSG	
	;	
	ld	hl, SPRI_T2_VOL+1
	call	RDVRM
	sub	#03
	call	WRTVRM
	ret
	;
vol1menos	ld	a, (volumen1)
	cp	#01
	ret	z
	dec	a
	ld	(volumen1), a
	;
	ld	a, PSG_VOL_A
	call	RDPSG	
	and	%11110000	; preserva los bits significativos 
	ld	e, a
	ld	a, (volumen1)
	or	e
	ld	e, a
	ld	a, PSG_VOL_A
	call	WRTPSG	
	;	
	ld	hl, SPRI_T1_VOL+1
	call	RDVRM
	sub	#03
	call	WRTVRM
	ret
	;
vol1mas	ld	a, (volumen1)
	cp	#0f
	ret	z
	inc	a
	ld	(volumen1), a
	;
	ld	a, PSG_VOL_A
	call	RDPSG	
	and	%11110000	; preserva los bits significativos 
	ld	e, a
	ld	a, (volumen1)
	or	e
	ld	e, a
	ld	a, PSG_VOL_A
	call	WRTPSG	
	;	
	ld	hl, SPRI_T1_VOL+1
	call	RDVRM
	add	a, #03
	call	WRTVRM
	ret
	;
	; --------------------------------------------------
	;
	; ACOMPAÑAMIENTO
	;
	; --------------------------------------------------
ACOMP	; comprobamos la tecla pulsada
	ld 	a, #08
	call	SNSMAT
	bit	5, a	; 'CSR_UP'
	jp	z, sonselup
	bit	6, a	; 'CSR_DOWN'
	jp	z, sonseldown
	;
	ld 	a, #06
	call	SNSMAT
	bit	2, a	; 'GRAPH'
	jp	z, acomfin
	; comprobamos si esta habilitado el acompañamiento
	ld	a, (sonena)
	cp	ENABLE
	jp	z, acomplay
	; comprobamos la tecla pulsada (acom. deshabilitado)
	ld 	a, #06
	call	SNSMAT
	bit	4, a	; 'CODE'
	jp	z, acomini
	ret
	;
	; inicializamos los parametros de acompañamiento
	;
acomini	ld	a, PSG_FREQ_C0
	out	(#a0), a
	in	a, (#a2)
	ld	(sonbcknote), a   ; guardamos nota actual (L)	
	ld	a, PSG_FREQ_C1
	out	(#a0), a
	in	a, (#a2)
	ld	(sonbcknote+1), a ; guardamos nota actual (H)
	;
	ld	hl, SPRI_ACOM+2
	ld	a, PAT_SI	; muestra sprite
	call	WRTVRM
	;
	ld	a, ENABLE	; habilitamos acompañamiento
	ld	(sonena), a
	;
	call	acomreset	; inicializa el buffer
	call	acomrecord 	; carga el registro actual
	;
	ld	e, #0f	; volumen en canal C
	ld	a, PSG_VOL_C
	call	WRTPSG
	ld	e, #00
	ld	a, PSG_FREQ_C0
	call	WRTPSG
	ld	e, #00
	ld	a, PSG_FREQ_C1
	call	WRTPSG
	;
	; reproducimos la nota almacenada
	;
acomplay	ld	a, (sonnote)
	cp	#ff	; comprobamos marca de fin
	jp	nz, acomplay1
	;
	; reiniciamos el ciclo
	call	acomreset	; inicializa el buffer
	call	acomrecord	; carga el registro actual
	;
acomplay1	ld	a, (sontime)
	cp	#00 	; tiempo finalizado?
	jp	z, acomnext
	dec	a
	ld	(sontime), a	; decrementa el tiempo
	;
	ld	a, (sonnote)
	ld	e, a
	ld	a, PSG_FREQ_C0
	call	WRTPSG
	ld	a, (sonnote+1)
	ld	e, a
	ld	a, PSG_FREQ_C1
	call	WRTPSG
	ret
	;
acomnext	ld	hl, (sonndx)
	inc	hl
	inc	hl
	inc	hl	; avanza siguiente posicion
	ld	(sonndx), hl
	;
	call	acomrecord	; carga el registro actual
	ret
	;
	; inicializa los indices del buffer seleccionado
	;
acomreset	ld	a, (sonselec)
	cp	#00
	jp	nz, acr1
	ld	hl, sonrithm1
	ld	(sonndx), hl ; posicion inicial del buffer
	ret	
	;
acr1	cp	#01
	jp	nz, acr2
	ld	hl, sonrithm2
	ld	(sonndx), hl ; posicion inicial del buffer
	ret	
	;
acr2	cp	#02
	jp	nz, acr3
	ld	hl, sonrithm3
	ld	(sonndx), hl ; posicion inicial del buffer
	ret	
	;
acr3	cp	#03
	jp	nz, acr4
	ld	hl, sonrithm4
	ld	(sonndx), hl ; posicion inicial del buffer
	ret	
	;
acr4	ld	hl, sonrithm5
	ld	(sonndx), hl ; posicion inicial del buffer
	ret
	;
	; carga el par <nota,tiempo> del indice del buffer
	;
acomrecord	ld	ix, (sonndx)
	ld	a, (ix+0)
	ld	(sonnote+1), a ; valor actual de nota (H)
	ld	a, (ix+1)
	ld	(sonnote), a	 ; valor actual de nota (L)
	ld	a, (ix+2)
	ld	(sontime), a	 ; valor inicial del tiempo 
	ret
	;
	; fin del acompañamiento
	;
acomfin	ld	a, (sonbcknote)
	ld	e, a   	; recuperamos nota actual (L)
	ld	a, PSG_FREQ_C0
	call	WRTPSG
	ld	a, (sonbcknote+1)
	ld	e, a  	; recuperamos nota actual (H)
	ld	a, PSG_FREQ_C1
	call	WRTPSG
	; 
	ld	hl, SPRI_RITMO+2
	call	RDVRM
	cp	PAT_SI	; esta el ritmo habilitado?
	jp	z, acomfina
	ld	e, #00	; sin volumen en canal C
	jp	acomfinb
acomfina	ld	e, #10	; con volumen en canal C
acomfinb	ld	a, PSG_VOL_C
	call	WRTPSG
	;
	ld	hl, SPRI_ACOM+2
	ld	a, PAT_BLANCO	; oculta sprite
	call	WRTVRM
	;
	ld	a, DISABLE	; deshabilitamos acompañamiento
	ld	(sonena), a
	ret
	;
	; seleccion banco de sonido (arriba)
	;
sonselup	ld	hl, SPRI_BANCO
	call	RDVRM
	cp	#98
	ret	z
	sub	#08
	call	WRTVRM	; actualiza posicion del sprite
	;
	ld	a, (sonselec)
	dec	a
	ld	(sonselec), a ; actualiza banco de ritmo
	;
	call	acomreset	; inicializa el buffer
	ret
	;
	; seleccion banco de sonido (abajo)
	;
sonseldown	ld	hl, SPRI_BANCO
	call	RDVRM
	cp	#b8
	ret	z
	add	a, #08
	call	WRTVRM	; actualiza posicion del sprite
	;
	ld	a, (sonselec)
	inc	a
	ld	(sonselec), a ; actualiza banco de ritmo
	;
	call	acomreset	; inicializa el buffer
	ret
	;
	; --------------------------------------------------
	;
	; INICIALIZACION DE PANTALLA
	;
	; --------------------------------------------------
INITSCREEN	; carga de sprites: patrones y atributos
	; longitud maxima de copia 256 bytes
	MvRam2Vram	spriteattr, SC2_SPRITATTR, 23*4
		
	MvRam2Vram	spritepatt, SC2_SPRITPAT, 8*4*8
	MvRam2Vram	spritepatt+256, SC2_SPRITPAT+256, 8*4*8
	MvRam2Vram	spritepatt+512, SC2_SPRITPAT+512, 8*4*8
	MvRam2Vram	spritepatt+768, SC2_SPRITPAT+768, 2*4*8	
	ret
	;	
	; --------------------------------------------------
	;
	; INICIALIZACION DEL PSG
	;
	; --------------------------------------------------
INITPSG	call	GICINI	; inicializa el PSG
	;
	ld	a, PSG_VOL_A
	ld	e, #0f
	call	WRTPSG
	ld	a, PSG_VOL_B
	ld	e, #0f
	call	WRTPSG
	ld	a, PSG_VOL_C
	ld	e, #0f
	call	WRTPSG
	; inicializa todos los registros de notas
	ld	b, #06
	ld	e, #00
	ld	a, PSG_FREQ_A0
s51	call	WRTPSG
	inc	a	; PSG_FREQ_A-C 0/1
	djnz	s51
	;
	ld	a, PSG_SETTINGS
	ld	e, %10111000	; solo tono en A, B, y C
	call	WRTPSG
	ld	a, PSG_NOISE
	ld	e, #02
	call	WRTPSG
	ld	a, PSG_ENVEL0
	ld	e, #03
	call	WRTPSG
	ld	a, PSG_ENVEL1
	ld	e, #14
	call	WRTPSG
	ld	a, PSG_PATTERN
	ld	e, #0e
	call	WRTPSG
	ret
	;
	; --------------------------------------------------
	;
	; LIBRERIAS
	;
	; --------------------------------------------------
	;
LIBRERIAS	include	"MSXLIB.ASM"
	;
	; --------------------------------------------------
	;
	; DATOS ESTATICOS
	;
	; --------------------------------------------------
	;
	; TABLA DE ATRIBUTOS DE SPRITES
	;
SPRI_T1_SPR0	equ	SC2_SPRITATTR+0*4
SPRI_T1_SPR1	equ	SC2_SPRITATTR+1*4
SPRI_T1_SPR2	equ	SC2_SPRITATTR+2*4
SPRI_T1_SPR3	equ	SC2_SPRITATTR+3*4
SPRI_T2_SPR0	equ	SC2_SPRITATTR+4*4
SPRI_T2_SPR1	equ	SC2_SPRITATTR+5*4
SPRI_T2_SPR2	equ	SC2_SPRITATTR+6*4
SPRI_T2_SPR3	equ	SC2_SPRITATTR+7*4
SPRI_T1_VOL	equ	SC2_SPRITATTR+8*4
SPRI_T2_VOL	equ	SC2_SPRITATTR+9*4
SPRI_ENV0	equ	SC2_SPRITATTR+10*4
SPRI_ENV1	equ	SC2_SPRITATTR+11*4
SPRI_FREQ	equ	SC2_SPRITATTR+12*4
SPRI_RITMO	equ	SC2_SPRITATTR+13*4
SPRI_REP1	equ	SC2_SPRITATTR+14*4
SPRI_GRA1	equ	SC2_SPRITATTR+15*4
SPRI_REP2	equ	SC2_SPRITATTR+16*4
SPRI_GRA2	equ	SC2_SPRITATTR+17*4
SPRI_ACOM	equ	SC2_SPRITATTR+18*4
SPRI_RUIDO	equ	SC2_SPRITATTR+19*4
SPRI_SALVAR	equ	SC2_SPRITATTR+20*4
SPRI_CARGAR	equ	SC2_SPRITATTR+21*4
SPRI_BANCO	equ	SC2_SPRITATTR+22*4
	;
	; DEFINICIONES PATRONES SPRITES
	;
PAT_MANOD0	equ	0*4
PAT_MANOD1	equ	1*4
PAT_MANOD2	equ	2*4
PAT_MANOD3	equ	3*4
PAT_MANOI0	equ	4*4
PAT_MANOI1	equ	5*4
PAT_MANOI2	equ	6*4
PAT_MANOI3	equ	7*4
PAT_VOL	equ	8*4
PAT_BANCO	equ	9*4
PAT_SI	equ	10*4
PAT_NO	equ	11*4
PAT_BLANCO	equ	12*4
PAT_PUNTERO1	equ	13*4
PAT_PUNTERO2	equ	14*4
PAT_ONDA0	equ	15*4
PAT_ONDA1	equ	16*4
PAT_ONDA2	equ	17*4
PAT_ONDA3	equ	18*4
PAT_ONDA4	equ	19*4
PAT_ONDA5	equ	20*4
PAT_ONDA6	equ	21*4
PAT_ONDA7	equ	22*4
PAT_ONDA8	equ	23*4
PAT_ONDA9	equ	24*4
PAT_ONDA10	equ	25*4
	;
	; ATRIBUTOS DE SPRITES
	;
spriteattr	db	#cf,#00,PAT_MANOD0,#0d	; mano derecha
	db	#cf,#00,PAT_MANOD1,#0d
	db	#cf,#00,PAT_MANOD2,#0d
	db	#cf,#00,PAT_MANOD3,#0d
	db	#cf,#00,PAT_MANOI0,#0d	; mano izquierda
	db	#cf,#00,PAT_MANOI1,#0d
	db	#cf,#00,PAT_MANOI2,#0d
	db	#cf,#00,PAT_MANOI3,#0d
	;
	db	#5a,#af,PAT_VOL,#01	; volumen canal A
	db	#64,#af,PAT_VOL,#01	; volumen canal B
	db	#5f,#c8,PAT_ONDA4,#01	; patron de onda
	db	#5f,#d8,PAT_ONDA4,#01	; patron de onda
	db	#7d,#af,PAT_VOL,#01	; frecuencia patron
	;
	db	#78,#e6,PAT_BLANCO,#01	; envolvente
	db	#8c,#e6,PAT_BLANCO,#01	; repeticion 1
	db	#a0,#e6,PAT_BLANCO,#01	; grabacion 1
	db	#14,#e6,PAT_BLANCO,#01	; repeticion 2
	db	#28,#e6,PAT_BLANCO,#01	; grabacion 2
	db	#3c,#e6,PAT_BLANCO,#01	; acompañamiento
	db	#b4,#e6,PAT_BLANCO,#01	; ruido
	db	#a0,#46,PAT_BLANCO,#01	; grabacion archivo
	db	#b4,#46,PAT_BLANCO,#01	; lectura archivo
	;
	db	#98,#ad,PAT_BANCO,#01	; seleccion banco
	;
	; PATRONES DE SPRITES 
	;
spritepatt	
	; PATRON 0: mano derecha 1
	db	#03,#04,#04,#07,#07,#07,#07,#07
	db	#07,#07,#07,#07,#0f,#0f,#0f,#37
	db	#00,#80,#80,#80,#80,#80,#80,#80
	db	#80,#98,#bd,#ff,#ff,#ff,#ff,#ff
	; PATRON 1: mano derecha 2
	db	#77,#f7,#ef,#ef,#ff,#7f,#3f,#0f
	db	#07,#07,#03,#03,#01,#01,#01,#00
	db	#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
	db	#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
	; PATRON 2: mano derecha 3
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#c6,#ef,#ff,#ff,#ff,#ff,#ff
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#80,#80,#80,#80
	; PATRON 3: mano derecha 4
	db	#ff,#ff,#ff,#ff,#ff,#ff,#fe,#fe
	db	#fc,#fc,#fc,#fc,#fc,#fc,#fc,#f8
	db	#80,#80,#80,#80,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	; PATRON 4: mano izquierda 1
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#01,#01,#01,#01
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#63,#f7,#ff,#ff,#ff,#ff,#ff
	; PATRON 5: mano izquierda 2
	db	#01,#01,#01,#01,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#ff,#ff,#ff,#ff,#ff,#ff,#7f,#7f
	db	#3f,#3f,#3f,#3f,#3f,#3f,#3f,#1f
	; PATRON 6: mano izquierda 3
	db	#00,#01,#01,#01,#01,#01,#01,#01
	db	#01,#19,#bd,#ff,#ff,#ff,#ff,#ff
	db	#c0,#20,#20,#e0,#e0,#e0,#e0,#e0
	db	#e0,#e0,#e0,#e0,#f0,#f0,#f0,#ec
	; PATRON 7: mano izquierda 4
	db	#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
	db	#ff,#ff,#ff,#ff,#ff,#ff,#ff,#fe
	db	#ee,#ef,#f7,#f7,#ff,#fe,#fc,#00
	db	#e0,#e0,#c0,#c0,#80,#80,#80,#00
	; PATRON 8: boton de volumen
	db	#e0,#e0,#e0,#e0,#e0,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	; PATRON 9: boton de frecuencia 
	db	#e0,#e0,#e0,#e0,#e0,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	; PATRON 10: SI
	db	#19,#25,#21,#19,#05,#25,#19,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	; PATRON 11: NO
	db	#89,#ca,#aa,#aa,#aa,#9a,#89,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#80,#40,#40,#40,#40,#40,#80,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	; PATRON 12: en blanco
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	; PATRON 13: borde del puntero de raton
	db	#C0,#A0,#90,#88,#84,#82,#81,#80
	db	#80,#83,#92,#A9,#C9,#04,#04,#07
	db	#00,#00,#00,#00,#00,#00,#00,#80
	db	#40,#C0,#00,#00,#00,#80,#80,#80
	; PATRON 14: relleno del puntero de raton
	db	#00,#E0,#F0,#F8,#FC,#FE,#FF,#FF
	db	#FF,#FF,#FE,#EF,#CF,#07,#07,#00
	db	#00,#00,#00,#00,#00,#00,#00,#80
	db	#C0,#C0,#00,#00,#00,#80,#80,#00
	; PATRON 15: onda corta decreciente
	db	#84,#46,#25,#25,#25,#14,#14,#14
	db	#0c,#00,#00,#00,#00,#00,#00,#00
	db	#21,#31,#29,#29,#29,#a5,#a5,#a5
	db	#63,#00,#00,#00,#00,#00,#00,#00
	; PATRON 16: onda larga decreciente (0)
	db	#80,#C0,#A0,#90,#88,#84,#82,#81
	db	#80,#00,#00,#00,#00,#00,#00,#00
	db	#00,#01,#02,#04,#08,#10,#20,#40
	db	#80,#00,#00,#00,#00,#00,#00,#00
	; PATRON 17: onda larga decreciente (1)
	db	#80,#40,#20,#10,#08,#04,#02,#01
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#00,#01,#02,#04,#08,#10,#20,#40
	db	#80,#00,#00,#00,#00,#00,#00,#00
	; PATRON 18: onda corta creciente
	db	#0c,#14,#14,#14,#25,#25,#25,#46
	db	#84,#00,#00,#00,#00,#00,#00,#00
	db	#63,#a5,#a5,#a5,#29,#29,#29,#31
	db	#21,#00,#00,#00,#00,#00,#00,#00
	; PATRON 19: onda larga creciente
	db	#00,#01,#02,#04,#08,#10,#20,#40
	db	#80,#00,#00,#00,#00,#00,#00,#00
	db	#80,#40,#20,#10,#08,#04,#02,#01
	db	#00,#00,#00,#00,#00,#00,#00,#00	
	; PATRON 20: onda corta diente creciente baja
	db	#0C,#14,#14,#14,#24,#24,#24,#44
	db	#87,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#FF,#00,#00,#00,#00,#00,#00,#00
	; PATRON 21: onda corta diente decreciente baja
	db	#C0,#A0,#A0,#A0,#90,#90,#90,#88
	db	#87,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#FF,#00,#00,#00,#00,#00,#00,#00
	; PATRON 22: onda corta diente decreciente alta
	db	#C3,#A2,#A2,#A2,#92,#92,#92,#8A
	db	#86,#00,#00,#00,#00,#00,#00,#00
	db	#FF,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	; PATRON 23: onda larga diente creciente alta
	db	#00,#01,#02,#04,#08,#10,#20,#40
	db	#80,#00,#00,#00,#00,#00,#00,#00
	db	#FF,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	; PATRON 24: onda plana baja
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#FF,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#FF,#00,#00,#00,#00,#00,#00,#00
	; PATRON 25: onda plana alta
	db	#FF,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	db	#FF,#00,#00,#00,#00,#00,#00,#00
	db	#00,#00,#00,#00,#00,#00,#00,#00
	;
	; PATRONES DE RITMO
	;
	; fomato de tabla:	<notaH,notaL,tiempo>
	; fin del ciclo:	<#ff,#ff,#ff>
	;
sonrithm1	db	#00,#00,#01	; preambulo
	db	#02,#d0,#03,#00,#00,#01
	db	#02,#d0,#03,#00,#00,#01
	db	#02,#e0,#01,#00,#00,#01
	db	#02,#e0,#01,#00,#00,#01
	db	#02,#d0,#03,#00,#00,#01
	db	#ff,#ff,#ff	; fin
	;
sonrithm2	db	#00,#00,#01	; preambulo
	db	#02,#d0,#03,#00,#00,#05
	db	#02,#e0,#01,#00,#00,#01
	db	#02,#e0,#01,#00,#00,#01
	db	#02,#d7,#02,#00,#00,#02
	db	#ff,#ff,#ff	; fin
	;
sonrithm3	db	#00,#00,#01	; preambulo
	db	#01,#d0,#03,#00,#00,#05
	db	#01,#e0,#01,#00,#00,#01
	db	#01,#e0,#01,#00,#00,#01
	db	#01,#d7,#02,#00,#00,#02
	db	#ff,#ff,#ff	; fin
	;
sonrithm4	db	#00,#00,#01	; preambulo
	db	#00,#d0,#03,#00,#00,#05
	db	#00,#e0,#01,#00,#00,#01
	db	#00,#e0,#01,#00,#00,#01
	db	#00,#d7,#02,#00,#00,#02
	db	#ff,#ff,#ff	; fin
	;
sonrithm5	db	#00,#00,#01	; preambulo
	db	#00,#d0,#03,#00,#00,#05
	db	#00,#e0,#01,#00,#00,#01
	db	#00,#e0,#01,#00,#00,#01
	db	#00,#d7,#02,#00,#00,#02
	db	#ff,#ff,#ff	; fin
	;
	; CODIGOS DE NOTAS
	;
notaoff	equ	#00
notaC	equ	#01
notaCs	equ	#02
notaD	equ	#03
notaDs	equ	#04
notaE	equ	#05
notaF	equ	#06
notaFs	equ	#07
notaG	equ	#08
notaGs	equ	#09
notaA	equ	#0a
notaAs	equ	#0b
notaB	equ	#0c	
	;
	; TABLA DE NOTAS (13x16)
	;
tablanotas	dw	#0000,#0000,#0000,#0000,#0000,#0000,#0000,#0000 ; note off
	dw	#0d5d,#06af,#0357,#01ac,#00d6,#006b,#0035,#001b ; C
	dw	#0c9c,#064e,#0327,#0194,#00ca,#0065,#0032,#0019 ; Cs
	dw	#0be7,#05f4,#02fa,#017d,#00be,#005f,#0030,#0018 ; D
	dw	#0b3c,#059e,#02cf,#0168,#0084,#005a,#002d,#0016 ; DS
	dw	#0a9b,#054e,#02a7,#0153,#00aa,#0055,#002a,#0015 ; E
	dw	#0a02,#0501,#0281,#0140,#00a0,#0050,#0028,#0014 ; F
	dw	#0973,#04ba,#025d,#012e,#0097,#004c,#0026,#0013 ; Fs
	dw	#08eb,#0476,#023b,#011d,#008f,#0047,#0024,#0012 ; G
	dw	#088b,#0436,#021b,#010d,#0087,#0043,#0022,#0011 ; Gs
	dw	#07f2,#03f9,#01fd,#00fe,#007f,#0040,#0020,#0010 ; A
	dw	#0780,#03c0,#01e0,#00f0,#0078,#003c,#001e,#000f ; As
	dw	#0714,#038a,#01c5,#00e3,#0071,#0039,#001c,#000e ; B
	;	
	; --------------------------------------------------
	;
	; DATOS DINAMICOS
	;
	; --------------------------------------------------
	;
	; TECLADO SUPERIOR #1
	;
octave1	db	#04	; octava del teclado
curnote1	dw	#0000	; ultima nota reproducida (12 bits)
curkey1	db	#00	; ultima tecla pulsada
keyena1	db	ENABLE	; teclado habilitado?
graena1	db	DISABLE	; grabacion habilitada?
buffndx1	dw	#0000	; indice actual de buffer
buffend1	dw	#0000	; posicion final del buffer
	;
	; TECLADO INFERIOR #2
	;
octave2	db	#01	; octava del teclado
curnote2	dw	#0000	; ultima nota reproducida (12 bits)
curkey2	db	#00	; ultima tecla pulsada
keyena2	db	ENABLE	; teclado habilitado?
graena2	db	DISABLE	; grabacion habilitada?
buffndx2	dw	#0000	; indice actual de buffer
buffend2	dw	#0000	; posicion final del buffer
	;
	; ENVOLVENTE
	;
teclaonda	db	#00	; ultima tecla pulsada
formaonda	db	#09	; patron de forma de onda
frecuencia	db	#09	; frecuencia del patron
	;
	; VOLUMEN
	;
volumen1	db	#0f	; volumen en canal A
volumen2	db	#0f	; volumen en canal B
	;
	; ACOMPAÑAMIENTO
	;
sonena	db	DISABLE	; acompañamiento habilitado?
sonselec	db	#00	; seleccion patron ritmo (0-4)
sonndx	dw	#0000	; indice actual acompañamiento
sonnote	dw	#0000	; valor actual nota (12 bits)
sontime	db	#00	; valor actual tiempo
sonbcknote	dw	#0000	; respaldo de nota canal C
	;
	; --------------------------------------------------
	;
	; DATOS INCRUSTADOS
	;
	; --------------------------------------------------
	;
	; ESPACIO VACIO ANTES DE LOS DISTINTOS BUFFERS
	;
	ds	32, #00
FINAL	
	end
