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

		ld	hl,trackData_test
		ld	b,DataBank0>>14
		ld	c,0
		ld	d,0
		ld	e,2
		ld	a,1
		call	Sound_SetTrack
	
		ld	ix,str_Test
		ld	bc,0101h
		call	Video_Print
		ei

.loop:
; .waitvint:	in	a,(vdp_ctrl)
; 		and	80h
; 		jp	z,.waitvint
; 		call	Sound_Run

		jp	.loop

trackData_test:
		dw MusicBlk_Gigalo
		dw MusicPat_Gigalo
		dw MusicIns_Gigalo

; 		dw MusicBlk_TestMe
; 		dw MusicPat_TestMe
; 		dw MusicIns_TestMe

; ====================================================================
; ----------------------------------------------------------------
; Subs
; ----------------------------------------------------------------

; ====================================================================
; ----------------------------------------------------------------
; Small data
; ----------------------------------------------------------------

str_Test:	db "PulseMini MERCURY",0Ah
		db "Tester",0Ah
		db 0Ah
		db "Ver 08/2019",0Ah
		db 0Ah
		db "--- Trk / Vol",0Ah
		db 0Ah
		db "SFX  ??    ??",0Ah
		db 0Ah
		db "BGM  ??    ??",0Ah
