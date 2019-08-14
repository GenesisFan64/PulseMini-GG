; ================================================================
; ------------------------------------------------------------
; DATA SECTION
; 
; SOUND
; ------------------------------------------------------------

; TYPES:
;  -1 - ignore
;   0 - FM normal
;   1 - FM special
;   2 - FM sample
; $80 - PSG
; $E0 - PSG noise

insFM		equ 0
insFM3		equ 1
insFM6		equ 2
insPSG		equ 80h
insPBass0	equ 0E0h
insPBass1	equ 0E1h
insPBass2	equ 0E2h
insPBass3	equ 0E3h		; Grabs PSG3 frequency
insPNoise0	equ 0E4h
insPNoise1	equ 0E5h
insPNoise2	equ 0E6h
insPNoise3	equ 0E7h		; Grabs PSG3 frequency

instrSlot	macro TYPE,OPT,LABEL
	if TYPE=-1
		db -1,-1,-1,-1
	else
		db TYPE,OPT
		dw LABEL
	endif
		endm

; ----------------------------------------------------
; Sound bank
; ----------------------------------------------------
		
; MusicBlk_Sample:
; 		binclude "game/sound/music/musictrck_blk.bin"		; BLOCKS data
; MusicPat_Sample:
; 		binclude "game/sound/music/musictrck_patt.bin"		; PATTERN data
; Instruments staring from number 01
; MusicIns_Sample:
; 		instrSlot      insFM,0,FmIns_Piano_Small		; FM normal: type,pitch,regdata
; 		instrSlot     insFM3,0,FmIns_Fm3_OpenHat		; FM special (channel 3): type,pitch,regdata+exfreq
; 		instrSlot     insFM3,0,FmIns_Fm3_ClosedHat
; 		instrSlot     insFM6,0,.kick				; FM sample (channel 6): type,pitch,custompointer (see below)
; 		instrSlot     insFM6,0,.snare
; 		instrSlot     insPSG,0,PsgIns_00			; PSG (channels 1-3): type,pitch,envelope data
; 		instrSlot insPBass0,0,PsgIns_00				; PSG Noise (channels 1-3): type,pitch,envelope data
; 		instrSlot insPBass1,0,PsgIns_00
; 		instrSlot insPBass2,0,PsgIns_00
; 		instrSlot insPBass3,0,PsgIns_00				; If using bass/noise type 3, NOISE will grab the frequency from chnl 3
; 		instrSlot insPNoise0,0,PsgIns_00
; 		instrSlot insPNoise1,0,PsgIns_00
; 		instrSlot insPNoise2,0,PsgIns_00
; 		instrSlot insPNoise3,0,PsgIns_00
; if using insFM6 instruments:
; .kick:	instrSmpl 0,WavIns_Kick,WavIns_Kick_e,WavIns_Kick	; sample flags (ex. loop), START, END, LOOP
; .snare:	instrSmpl 0,WavIns_Snare,WavIns_Snare_e,WavIns_Snare

; ------------------------------------
; Track TESTME
; ------------------------------------

MusicBlk_TestMe:
		binclude "game/sound/music/lasttest_blk.bin"		; BLOCKS data
MusicPat_TestMe:
		binclude "game/sound/music/lasttest_patt.bin"		; PATTERN data
MusicIns_TestMe:
		instrSlot -1
		instrSlot -1
		instrSlot -1
		instrSlot -1
		instrSlot -1
		instrSlot     insPSG,0,PsgIns_00
		instrSlot insPBass0,0,PsgIns_00
		instrSlot insPBass1,0,PsgIns_00
		instrSlot insPBass2,0,PsgIns_00
		instrSlot insPBass3,0,PsgIns_00
		instrSlot insPNoise0,0,PsgIns_00
		instrSlot insPNoise1,0,PsgIns_00
		instrSlot insPNoise2,0,PsgIns_00
		instrSlot insPNoise3,0,PsgIns_00

; ------------------------------------
; Track Gigalo
; ------------------------------------

MusicBlk_Gigalo:
		binclude "game/sound/music/gigalo_psg_blk.bin"
MusicPat_Gigalo:
		binclude "game/sound/music/gigalo_psg_patt.bin"
MusicIns_Gigalo:
		instrSlot     insPSG,0,PsgIns_01
		instrSlot insPNoise0,0,PsgIns_01
		instrSlot insPNoise1,0,PsgIns_01
		instrSlot insPNoise2,0,PsgIns_01
