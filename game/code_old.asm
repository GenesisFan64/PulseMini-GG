; ====================================================================
; ----------------------------------------------------------------
; Structs
; ----------------------------------------------------------------

		struct 0
plyr_x		ds 2
plyr_y		ds 2
plyr_frame	ds 1
plyr_ani_timer	ds 1
plyr_ani_cntr 	ds 1
		finish

		struct RAM_Local
RAM_Player	ds 32
RAM_VdpReg1	ds 1
RAM_FrameCntr	ds 2
		finish

; ====================================================================
; ----------------------------------------------------------------
; Main
; ----------------------------------------------------------------

		call	Video_InitPrint
		call	Objects_Init
.loop:
		call	Char_Animation
		call	Object_Show
.waitvint:	in	a,(vdp_ctrl)
		and	80h
		jp	z,.waitvint
		call	VBlnk_UpdChrSpr
		call	Char_Move

		ld	hl,(RAM_FrameCntr)
		inc 	hl
		ld	(RAM_FrameCntr),hl
		ld	ix,str_Test
		ld	bc,0
		call	Video_Print
	
		jp	.loop

; ====================================================================
; ----------------------------------------------------------------
; Subs
; ----------------------------------------------------------------

; --------------------------------------------------------
; Init character
; --------------------------------------------------------

Objects_Init:
		ld	hl,Pal_Chantae
		ld	b,16
		ld	d,16
		call	Video_LoadPal

		ld	hl,RAM_SprtY
		ld	(RAM_CurrSprY),hl
		ld	hl,RAM_SprtX
		ld	(RAM_CurrSprX),hl
		
		ld	iy,RAM_Player
		ld	a,8
		ld	(iy+plyr_ani_timer),a
.wait:
		in	a,(vdp_ctrl)
		and	80h
		jp	z,.wait

; --------------------------------------------------------
; Build sprite
; --------------------------------------------------------

Object_Show:
		ld	hl,MapH_Chantae
		ld	ix,MapD_Chantae
		ld	de,0
		ld	a,(iy+plyr_frame)
		add 	a,a
		add 	a,a
		ld	e,a
		add 	hl,de
		ld	e,(hl)
		inc 	hl
		ld	d,(hl)
		inc 	hl
		ld	a,(hl)
		add 	ix,de
		ld	hl,(RAM_CurrSprY)
		ld	b,a
		exx
		ld	hl,(RAM_CurrSprX)
.loop2:

	; Y set
		exx
		push	hl
		ld	h,(iy+(plyr_y+1))
		ld	l,(iy+(plyr_y))
		ld	a,(ix)
		ld	e,a
		add 	a,a
		sbc 	a,a
		ld	d,a
		add 	hl,de
		ld	a,(RAM_VdpCache+1)
		and 	1
		jp	z,.nodby
		add 	hl,de
.nodby:
		ld	c,l
		ld	de,32
		add 	hl,de
		ld	a,h
		or	a
		jp	z,.notcy
		ld	c,0ECh
.notcy:
		ld	a,c
		pop	hl
		ld	(hl),a
		inc 	hl

		exx
		push	hl
		ld	h,(iy+(plyr_x+1))
		ld	l,(iy+(plyr_x))
		ld	a,(ix+1)
		ld	e,a
		add 	a,a
		sbc 	a,a
		ld	d,a
		add 	hl,de
		ld	a,(RAM_VdpCache+1)
		and 	1
		jp	z,.nodbx
		add 	hl,de
.nodbx:
		ld	c,l
		
		ld	a,h
		or	a
		jp	z,.notcx
		exx
		dec	hl
		ld	a,0ECh
		ld	(hl),a
		inc	hl
		exx
		ld	c,0F0h
.notcx:
		ld	a,c
		pop	hl
		ld	(hl),a
		inc 	hl
		
		ld	a,(ix+2)
		ld	(hl),a
		inc 	hl
		ld	de,3
		add 	ix,de

		djnz	.loop2
		
		ld	(RAM_CurrSprX),hl
		exx
		ld	(RAM_CurrSprY),hl
		exx
		ret

; --------------------------------------------------------
; Move character
; --------------------------------------------------------

Char_Move:
		ld	iy,RAM_Player
		ld	de,1
		
		ld	a,(Controller_1)
		bit 	bitJoyRight,a
		jp	z,.nr
		ld	h,(iy+(plyr_x+1))
		ld	l,(iy+plyr_x)
		add 	hl,de
		ld	(iy+(plyr_x+1)),h
		ld	(iy+plyr_x),l	
.nr:
		bit 	bitJoyDown,a
		jp	z,.nd
		ld	h,(iy+(plyr_y+1))
		ld	l,(iy+plyr_y)
		add 	hl,de
		ld	(iy+(plyr_y+1)),h
		ld	(iy+plyr_y),l	
.nd:

		ld	de,-1
		bit 	bitJoyLeft,a
		jp	z,.nl
		ld	h,(iy+(plyr_x+1))
		ld	l,(iy+plyr_x)
		add 	hl,de
		ld	(iy+(plyr_x+1)),h
		ld	(iy+plyr_x),l	
.nl:
		bit 	bitJoyUp,a
		jp	z,.nu
		ld	h,(iy+(plyr_y+1))
		ld	l,(iy+plyr_y)
		add 	hl,de
		ld	(iy+(plyr_y+1)),h
		ld	(iy+plyr_y),l	
.nu:

		ld	a,(Controller_1+on_press)
		bit 	bitJoy2,a
		jp	z,.noswp
		ld	a,(RAM_VdpCache+1)
		ld	c,a
		and	11111110b
		ld	b,a
		ld	a,c
		cpl
		and	1
		or	b
		ld	(RAM_VdpCache+1),a
		call	Video_Update
.noswp:
		ret
	
; --------------------------------------------------------
; Animate object
; --------------------------------------------------------

Char_Animation:
	; Count frames
		ld	iy,RAM_Player
		ld	a,(iy+plyr_ani_cntr)
		dec	a
		or	a
		jp	p,.no_draw
		ld	a,8
		ld	(iy+plyr_ani_cntr),a
		ld	a,(iy+plyr_frame)	
		inc 	a
		cp	5
		jp	c,.low
		xor	a
.low:
		ld	(iy+plyr_frame),a
		ret
.no_draw:
		ld	(iy+plyr_ani_cntr),a
		ret

; ====================================================================
; ----------------------------------------------------------------
; Inside VBlank
; ----------------------------------------------------------------

VBlnk_UpdChrSpr:
		call	System_Input
; 		ld	a,(RAM_VdpCache+1)
; 		and 	10111111b
; 		out 	(vdp_ctrl),a
; 		ld	a,81h
; 		out 	(vdp_ctrl),a

	; Draw character
		ld	iy,RAM_Player
		ld	hl,Plc_Chantae		; animation frame
		ld	de,0
		ld	a,(iy+plyr_frame)
		add 	a,a
		ld	e,a
		add 	hl,de
		ld	e,(hl)
		inc 	hl
		ld	d,(hl)
		ld	hl,Art_Chantae
		add 	hl,de
		ld	de,6000h
		ld	c,vdp_ctrl
		out	(c),e
		out	(c),d
		ld	c,vdp_data
	rept 26
		outi
		outi
		outi
		outi	
		outi
		outi
		outi
		outi
		outi
		outi
		outi
		outi	
		outi
		outi
		outi
		outi
		outi
		outi
		outi
		outi	
		outi
		outi
		outi
		outi
		outi
		outi
		outi
		outi	
		outi
		outi
		outi
		outi
	endm

	; Transfer sprites
		ld	hl,RAM_SprtY
		ld	de,7F00h
		ld	c,vdp_ctrl
		out 	(c),e
		out	(c),d
		ld	c,vdp_data
	rept 64
		outi
	endm
		ld	hl,RAM_SprtX
		ld	de,7F80h
		ld	c,vdp_ctrl
		out 	(c),e
		out	(c),d
		ld	c,vdp_data
	rept 64
		outi
		outi
	endm

	; Reset sprite cache
		ld	hl,RAM_SprtY
		ld	a,0E8h
		ld	b,64
.clr1:
		ld	(hl),a
		inc 	hl
		djnz	.clr1
		ld	hl,RAM_SprtY
		ld	(RAM_CurrSprY),hl
		ld	hl,RAM_SprtX
		ld	(RAM_CurrSprX),hl
		
; 		ld	a,(RAM_VdpCache+1)
; 		or 	40h
; 		out 	(vdp_ctrl),a
; 		ld	a,81h
; 		out 	(vdp_ctrl),a
		ret
		
; ====================================================================
; ----------------------------------------------------------------
; Set HBlank
; ----------------------------------------------------------------

; MS_HInt:
		pop	af
		ei				; Re-enable interrupts before exiting
		ret				; Return

; ====================================================================
; ----------------------------------------------------------------
; Small data
; ----------------------------------------------------------------

str_Test:	db "Chantae sprite test",0Ah
		db "Framecount: \\w",0
		dw RAM_FrameCntr

Pal_Chantae	binclude "game/objects/player/pal.bin"
