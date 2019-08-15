; ====================================================================
; ----------------------------------------------------------------
; Video
; ----------------------------------------------------------------

; --------------------------------------------------------
; Init Video
; --------------------------------------------------------

Video_Init:
		call	Video_Clear
 
		ld      hl,list_vdpregs		; hl - data array for default register data
		ld	de,RAM_VdpCache		; de - VDP cache on RAM
		ld      c,80h			; c - 80h start at first register
		ld      b,11			; b - 11 registers to set	
.loop:
		ld	a,(hl)			; Grab byte from list
		ld	(de),a
		inc 	de
		out	(vdp_ctrl),a		; First VDP write
		ld	a,c			; Now set the register
		out	(vdp_ctrl),a		; Second VDP write
		inc	c			; Next register to use
		inc 	hl			; Next byte from the list
		djnz    .loop    		; decrement b and jump if b != 0
		ret

; --------------------------------------------------------
; Video_InitPrint
; 
; Call this before using any on-screen text print
; 
; Graphics will be located at in 160h
; (ASCII starts at 140h)
; Uses palette line 0
; --------------------------------------------------------

Video_InitPrint:
		ld	de,140h			; VRAM | Palette 2
		ld	(RAM_VidPrntVram),de
		ld	hl,Art_PrintFont
		ld	de,Art_PrintFont_e-Art_PrintFont
		ld	bc,140h+20h
		call	Video_LoadArt
		
		ld	hl,Pal_PrintFont
		ld	b,16
		ld	d,0
		call	Video_LoadPal		
		ld	hl,Pal_PrintFont
		ld	b,6
		ld	d,16
		jp	Video_LoadPal

; ====================================================================
; ----------------------------------------------------------------
; Video subroutines
; ----------------------------------------------------------------

; ---------------------------------
; Video_Update
; 
; Update registers from cache
; to VDP
; ---------------------------------

Video_Update:
		ld      hl,RAM_VdpCache		; hl - data array for default register data
		ld      c,80h			; c - 80h start at first register
		ld      b,11			; b - 11 registers to set	
.loop:
		ld	a,(hl)			; Grab byte from list
		out	(vdp_ctrl),a		; First VDP write
		ld	a,c			; Now set the register
		out	(vdp_ctrl),a		; Second VDP write
		inc	c			; Next register to use
		inc 	hl			; Next byte from the list
		djnz    .loop    		; decrement b and jump if b != 0
		ret

; --------------------------------------------------------
; Video_Clear
; 
; Clear everything on-screen
;
; Uses:
; hl,bc,de
; --------------------------------------------------------

Video_Clear:
		ld	b,16			; Clear pallete
		in	a,(gg_info)		; Check if we are in Game Gear
		and	1Fh
		jp	nz,.mark_ms
		sla	b			; Length * 2
.mark_ms:
		ld	hl,0C000h
		ld	c,vdp_ctrl
		out	(c),l
		out	(c),h
		xor	a
		ld	c,vdp_data
.pal_clr:
		out	(c),a
		djnz	.pal_clr
	
	; Clear ALL VRAM
		ld	hl,4000h		; Clear screen
		ld	c,vdp_ctrl
		out	(c),l
		out	(c),h
		ld	hl,4000h
		ld	c,vdp_data
.clrscrn:
		xor	a
		out	(c),a
		dec 	hl
		ld	a,h
		or	l
		jp	nz,.clrscrn
		ret
		
; --------------------------------------------------------
; Video_LoadPal
; 
; Load GAME GEAR palette to VDP, auto-converts for
; Master System
;
; NOTE: Color dots will be shown on screen
; 
; Input:
; hl - Palette data
; b - Number of colors
; d - Start position
;
; Uses:
; hl,bc,de
; --------------------------------------------------------

Video_LoadPal:
		ld	c,vdp_data
		in	a,(gg_info)		; Check if we are in Game Gear
		and	1Fh
		jp	nz,.mark_ms

	; Game Gear palette
		sla	b
		sla	d
		ld	a,d
		out	(vdp_ctrl),a
		ld	a,0C0h
		out	(vdp_ctrl),a
		otir				; out (hl) to the port at C, increment hl, decrement b
		ret

	; GG to MS convertion
.mark_ms:
		ld	c,vdp_ctrl
		ld	a,0C0h
		out	(c),d
		out	(c),a
.loopms:
		ld	a,(hl)
		sra	a
		sra	a
		and	11b
		ld	d,a
		ld	a,(hl)
		rra
		rra
		rra
		rra
		and	1100b
		ld	e,a
		inc	hl
		ld	a,(hl)
		rla
		rla
		and	110000b
		or	d
		or	e
		inc	hl

		out	(vdp_data),a
		djnz	.loopms
		ret

; --------------------------------------------------------
; Video_LoadArt
; 
; Load graphics to VRAM
;
; Input:
; hl - Art data
; de - Size
; bc - VRAM (cell)
; --------------------------------------------------------

Video_LoadArt:
		ld	a,b		; Multiply VRAM >> 5
		rrca
		rrca
		rrca
		and	00100000b
		ld	b,a
		ld	a,c
		rrca
		rrca
		rrca
		and	00011111b
		or	b
		or	40h		; VRAM write mode
		ld	b,a
		ld	a,c
		and	00000111b
		rrca
		rrca
		rrca
		ld	c,vdp_ctrl
		out	(c),a		; a - 00xx
		out	(c),b		; b - xx00

	; start
		ld	c,vdp_data
.loop:
		outi
		dec 	de
		ld	a,e
		or	d
		jp	nz,.loop
		ret

; --------------------------------------------------------
; Video_Print
; 
; Print text on screen
; Note: doesn't check for OOB
; 
; Input:
; ix - String data
; bc - X pos | Y pos
; 
; Uses
; de,hl,iy
; --------------------------------------------------------

Video_Print:
		push	bc
		push	de
		push	hl
		push	iy

		ld	iy,RAM_VidPrntList
		ld	hl,3800h
		in	a,(gg_info)
		and	1Fh
		jp	nz,.nocent
		ld	l,0CCh
.nocent:
		ld	de,0
		ld	a,c		; Y pos left
		rrca	
		rrca
		and	07h
		ld	d,a
		ld	a,b		; X pos + Y pos right YYXXXXXXb
		and	1Fh
		add 	a,a
		ld	e,a
		ld	a,c
		and	11b
		rrca
		rrca
		or	e
		ld	e,a
		add 	hl,de

	; X/Y pos goes here
		ld	c,vdp_ctrl
		ld	a,h
		or	40h
		ld	h,a
		out	(c),l
		out	(c),h
		ld	de,0
		ld	b,h
		ld	c,l

	; bc - curr position for values
	; hl - curr position for jump
.loop:
		ld	a,(ix)
		inc	ix
		cp	00Ah		; 00Ah - next line?
		jp	z,.next
		cp	05Ch		; 05Ch ("\") special?
		jp	z,.special		
		or	a		; Zero?
		jp	z,.exit
		push	hl
		ld	hl,(RAM_VidPrntVram)
		ld	e,a
		add	hl,de
		ld	a,l
		out	(vdp_data),a
		ld	a,h
		out	(vdp_data),a
		pop	hl
		inc 	bc		; Next pos for values
		inc 	bc
		jr	.loop

; Next line
.next:
		ld	de,40h		; TL add line
		add 	hl,de
		ld	b,h		; Save pos to value beam
		ld	c,l
		ld	a,l		; Reset position with new
		out	(vdp_ctrl),a
		ld	a,h
		out	(vdp_ctrl),a
		jr	.loop
; Special
.special:
		ld	a,(ix)
		inc	ix
		cp	"b"		; Byte?
		jp	z,.breq
		cp	"w"		; Word?
		jp	nz,.loop
; word
		ld	(iy),c		; Set address
		ld	(iy+1),b
		ld	(iy+2),2	; Set request
		inc 	iy		; Next entry
		inc 	iy
		inc 	iy
		inc 	bc		; Four cells
		inc 	bc
		inc 	bc
		inc 	bc
		inc 	bc
		inc 	bc
		inc 	bc
		inc 	bc
		ld	a,c
		out	(vdp_ctrl),a
		ld	a,b
		out	(vdp_ctrl),a
		jr	.loop
; byte
.breq:
		ld	(iy),c		; Set address
		ld	(iy+1),b
		ld	(iy+2),1	; Set request
		inc 	iy		; Next entry
		inc 	iy
		inc 	iy
		inc 	bc		; Two cells
		inc 	bc
		inc 	bc
		inc 	bc
		ld	a,c
		out	(vdp_ctrl),a
		ld	a,b
		out	(vdp_ctrl),a
		jr	.loop
.exit:

; ------------------------------------------------
; Print values
; check MAX_PRNTLIST for maximum values
; 
; vvvv tt
; v - vdp pos
; t - value type
; ------------------------------------------------

		ld	iy,RAM_VidPrntList
.loopval:
		ld	a,(iy)
		ld	b,(iy+1)
		or	a
		jp	z,.endval
		ld	c,a

	; Check byte
		ld	a,(iy+2)
		cp	1
		jp	nz,.nobyte
		ld	l,(ix)
		ld	h,(ix+1)
		call	.put_byte
.nobyte:
		ld	a,(iy+2)
		cp	2
		jp	nz,.noword
		ld	l,(ix)
		ld	h,(ix+1)
		call	.put_byte
		inc 	hl
		call	.put_byte
.noword:

		xor	a		; Clear current entry 
		ld	(iy),a		; and move to next
		ld	(iy+1),a
		ld	(iy+2),a
		inc 	iy
		inc 	iy
		inc 	iy
		jp	.loopval
.endval:	
		pop	iy
		pop	hl
		pop	de
		pop	bc
		ret

; draw nibble
.put_byte:
		ld	a,(hl)
		rrca
		rrca
		rrca
		rrca
		call	.do_nibbl
		ld	a,(hl)
.do_nibbl:
		push	hl
		ld	hl,0
		and 	0Fh
		cp	0Ah
		jp	c,.noadd
		add 	a,7
.noadd:
		ld	l,a
		ld	de,(RAM_VidPrntVram)	; Start at font VRAM
		add 	hl,de
		ld	de,30h			; at char 0
		add 	hl,de
		ld	a,c			; mark vdp pos
		out	(vdp_ctrl),a
		ld	a,b
		out	(vdp_ctrl),a
		inc 	bc			; next layer cell
		inc 	bc
		ld	a,l			; put vram value
		out 	(vdp_data),a
		ld	a,h
		out	(vdp_data),a
		pop	hl
		ret
		
; ====================================================================
; --------------------------------------------------------
; Video data
; --------------------------------------------------------

list_vdpregs:
		db      00000110b       ; ---H---- | H-Hint
		db      11100010b       ; -DV---W- | D-Display ON / V-Vint / W-8x16 sprites
		db      11111111b       ;
		db      11111111b       ;
		db      11111111b       ;
		db      11111111b       ;
		db      00000100b       ; -----S-- | S-Sprite VRAM Add ($100)
		db      00000000b       ;
		db      00000000b       ;
		db      00000000b       ;
		db      00000000b       ;

Art_PrintFont:	binclude "system/data/art_prntfont.bin"
Art_PrintFont_e:
Pal_PrintFont:;	binclude "system/data/pal_prntfont.bin"
		dw 0000h,0EEEh,0CCCh,0AAAh,0888h,0444h,000Eh,0008h
		dw 00EEh,0088h,00E0h,0080h,0E00h,0800h,0000h,0000h
