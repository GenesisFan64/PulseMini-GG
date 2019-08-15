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
RAM_CurrPlySlot	ds 1
RAM_CurrTrckId	ds 2
RAM_CurrTrckVol	ds 2
		finish

; ====================================================================
; ----------------------------------------------------------------
; Main
; ----------------------------------------------------------------

		call	Video_InitPrint

		ld	a,0
		ld	ix,str_Test
		ld	bc,0203h
		call	Video_Print
		ld	hl,pal_FontNew
		ld	b,32
		ld	d,0
		call	Video_LoadPal
		
		xor	a
		ld	(RAM_CurrPlySlot),a
		call	.show_values

.loop:
		call	System_VSync
		call	System_Input
		call	Sound_Run

		ld	a,(Controller_1+on_hold)
		ld	b,a
		ld	a,(Controller_1+on_press)
		ld	c,a
		xor	a



		ld	hl,RAM_CurrTrckId
		ld	a,(RAM_CurrPlySlot)
		or	a
		jp	z,.slot1noad
		inc 	hl
.slot1noad:
		ld	d,1
		bit	bitJoyRight,c
		call	nz,.modify_track
		ld	d,-1
		bit	bitJoyLeft,c
		call	nz,.modify_track
		bit	bitJoyUp,c
		call	nz,.modify_slot
		ld	d,1
		bit	bitJoyDown,c
		call	nz,.modify_slot

		bit	bitJoy2,c		; c is lost after this
		call	nz,.play_track
		bit	bitJoy1,c
		call	nz,.stop_track

		ld	a,(Controller_1+on_press)	; update values on any press
		or	a
		call	nz,.show_values
		jp	.loop

; ====================================================================
; ----------------------------------------------------------------
; Subs
; ----------------------------------------------------------------

; hl - RAM_CurrTrckId
.modify_track:
		ld	a,(hl)
		add 	a,d
		and	00000011b			; limit
		ld	(hl),a
		ret

.modify_slot:
		ld	a,(RAM_CurrPlySlot)
		add 	a,d
		and	00000001b			; limit
		ld	(RAM_CurrPlySlot),a
		ret
		
.play_track:
		ld	a,(hl)
		ld	de,0
		add 	a,a
		add 	a,a
		add	a,a
		add	a,a
		ld	e,a
		ld	hl,trackData_test
		add 	hl,de
		ld	b,(hl)
		inc 	hl
		ld	c,(hl)
		inc 	hl
		ld	d,(hl)
		inc 	hl
		ld	e,(hl)
		inc 	hl
		ld	a,(RAM_CurrPlySlot)
		jp	Sound_SetTrack

.stop_track:
		ld	a,(RAM_CurrPlySlot)
		jp	Sound_StopTrack
	
; show values
.show_values:
		ld	de,140h+30h|800h
		ld	a,(RAM_CurrPlySlot)
		or	a
		jp	z,.slot_1
		ld	de,140h+30h
.slot_1:
		ld	bc,0708h
		ld	ix,RAM_CurrTrckId
		call	.this_val
		inc 	ix
		
		ld	de,140h+30h|800h
		ld	a,(RAM_CurrPlySlot)
		or	a
		jp	nz,.slot_2
		ld	de,140h+30h
.slot_2:
		ld	bc,070Ah

; ----------------------------------------
; show current value
.this_val:
		ld	hl,3800h
		in	a,(gg_info)
		and	1Fh
		jp	nz,.nocent
		ld	l,0CCh
.nocent:
		push	de
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
		pop	de

	; X/Y pos goes here
		ld	c,vdp_ctrl
		ld	a,h
		or	40h
		ld	h,a
		out	(c),l
		out	(c),h

		ld	c,vdp_data
		ld	hl,0
		ld	a,(ix)
		rrca
		rrca
		rrca
		rrca
		and	00001111b
		ld	l,a
		add 	hl,de
		out	(c),l
		out	(c),h

		ld	hl,0
		ld	a,(ix)
		and	00001111b
		ld	l,a
		add 	hl,de
		out	(c),l
		out	(c),h
		ret

; ====================================================================
; ----------------------------------------------------------------
; Small data
; ----------------------------------------------------------------

str_Test:	db "PulseMini tester",0Ah
		db "Ver 08/2019",0Ah
		db 0Ah
		db "--- Trk / Vol",0Ah
		db 0Ah
		db "SFX          ",0Ah
		db 0Ah
		db "BGM          ",0

pal_FontNew:
		dw 0000h,0EEEh,0CCCh,0AAAh,0888h,0444h,000Eh,0008h
		dw 00EEh,0088h,00E0h,0080h,0E00h,0800h,0000h,0000h
		dw 0000h,00AEh,008Ch,006Ah,0048h,0024h,000Eh,0008h
		dw 00EEh,0088h,00E0h,0080h,0E00h,0800h,0000h,0000h
		
trackData_test:
		db DataBank0>>14
		db 0
		db 0
		db 3
		dw MusicBlk_TestMe
		dw MusicPat_TestMe
		dw MusicIns_TestMe
		dw 0,0
		dw 0

		db DataBank0>>14
		db 0
		db 0
		db 2
		dw MusicBlk_Gigalo
		dw MusicPat_Gigalo
		dw MusicIns_Gigalo
		dw 0,0
		dw 0
		
		db DataBank0>>14
		db 0
		db 0
		db 3
		dw MusicBlk_TestMe
		dw MusicPat_TestMe
		dw MusicIns_TestMe
		dw 0,0
		dw 0
		
		db DataBank0>>14
		db 0
		db 0
		db 3
		dw MusicBlk_TestMe
		dw MusicPat_TestMe
		dw MusicIns_TestMe
		dw 0,0
		dw 0
