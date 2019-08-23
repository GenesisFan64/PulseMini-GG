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
RAM_PlyrCurrIds	ds 2
RAM_PlyrCurrVol	ds 2
RAM_CurrTrack	ds 1
RAM_CurrSelect	ds 1
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
		ld	(RAM_CurrTrack),a
		call	.show_values

.loop:
		call	System_VSync
		call	System_Input
		call	Sound_Run

		ld	a,(Controller_1+on_press)
		ld	c,a
		ld	a,(Controller_1+on_hold)
		ld	b,a
		bit 	bitJoy1,b
		jp	nz,.b_hold

		ld	d,1
		bit	bitJoyDown,c
		call	nz,.modify_track
		bit	bitJoyRight,c
		call	nz,.modify_select
		ld	d,-1
		bit	bitJoyUp,c
		call	nz,.modify_track
		bit	bitJoyLeft,c
		call	nz,.modify_select
		bit	bitJoyStart,c
		call	nz,.stop_track
		jp	.refresh
		
.b_hold:
		ld	hl,RAM_PlyrCurrIds
		ld	a,(RAM_CurrSelect)
		or	a
		jp	z,.idmode
		ld	hl,RAM_PlyrCurrVol
.idmode:
		ld	a,(RAM_CurrTrack)
		or	a
		jp	z,.firsttrck
		inc 	hl
.firsttrck:
		ld	d,1
		bit	bitJoyRight,c
		call	nz,.modify_id
		ld	d,-1
		bit	bitJoyLeft,c
		call	nz,.modify_id
		
; exit this
.refresh:
		ld	hl,RAM_PlyrCurrIds
		ld	a,(RAM_CurrTrack)
		or	a
		jp	z,.idmode2
		inc 	hl
.idmode2:
		bit	bitJoy2,c			; c is lost after this
		call	nz,.play_track
		ld	a,(Controller_1+on_press)	; update values on any press
		or	a
		call	nz,.show_values
		jp	.loop

; ====================================================================
; ----------------------------------------------------------------
; Subs
; ----------------------------------------------------------------

; hl - RAM_PlyrCurrIds

.modify_id:
		ld	a,(hl)
		add 	a,d
; 		and	00000011b
		ld	(hl),a
		ret
.modify_select:
		ld	a,(RAM_CurrSelect)
		add 	a,d
		and	00000001b			; limit
		ld	(RAM_CurrSelect),a
		ret
.modify_track:
		ld	a,(RAM_CurrTrack)
		add 	a,d
		and	00000001b
		ld	(RAM_CurrTrack),a
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
		ld	a,(RAM_CurrTrack)
		call	Sound_SetTrack
		
		ld	de,0
		ld	a,(RAM_CurrTrack)
		ld	e,a
		ld	hl,RAM_PlyrCurrVol
		add 	hl,de
		ld	c,(hl)
		jp	Sound_SetVolume
		
.stop_track:
		ld	a,(RAM_CurrTrack)
		jp	Sound_StopTrack

; show values
.show_values:
		ld	de,140h+30h
		ld	a,(RAM_CurrSelect)
		or	a
		jp	nz,.slot_1
		ld	a,(RAM_CurrTrack)
		or	a
		jp	nz,.slot_1
		ld	de,140h+30h|800h
.slot_1:
		ld	bc,0708h
		ld	ix,RAM_PlyrCurrIds
		call	.this_val
		inc 	ix
		ld	de,140h+30h
		ld	a,(RAM_CurrSelect)
		or	a
		jp	nz,.slot_2
		ld	a,(RAM_CurrTrack)
		or	a
		jp	z,.slot_2
		ld	de,140h+30h|800h
.slot_2:
		ld	bc,070Ah
		call	.this_val
		
		ld	de,140h+30h
		ld	a,(RAM_CurrSelect)
		or	a
		jp	z,.slot_3
		ld	a,(RAM_CurrTrack)
		or	a
		jp	nz,.slot_3
		ld	de,140h+30h|800h
.slot_3:
		ld	bc,0D08h
		ld	ix,RAM_PlyrCurrVol
		call	.this_val
		inc 	ix
		ld	de,140h+30h
		ld	a,(RAM_CurrSelect)
		or	a
		jp	z,.slot_4
		ld	a,(RAM_CurrTrack)
		or	a
		jp	z,.slot_4
		ld	de,140h+30h|800h
.slot_4:
		ld	bc,0D0Ah

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
		cp	0Ah
		jp	c,.no_A1
		add 	a,7
.no_A1:
		ld	l,a
		add 	hl,de
		out	(c),l
		out	(c),h

		ld	hl,0
		ld	a,(ix)
		and	00001111b
		cp	0Ah
		jp	c,.no_A2
		add 	a,7
.no_A2:
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
