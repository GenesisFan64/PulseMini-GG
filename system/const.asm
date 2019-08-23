; ====================================================================
; ----------------------------------------------------------------
; Settings
; ----------------------------------------------------------------

MSRAM_START	equ	0C000h		; MS RAM Start
MAX_MSERAM	equ	1000h		; Maximum temporal RAM for screen modes
MAX_PRNTLIST	equ	16		; Max print values

varNullVram	equ	1FFh

; ====================================================================
; ----------------------------------------------------------------
; Variables
; ----------------------------------------------------------------

; --------------------------------------------------------
; System
; --------------------------------------------------------

; ------------------------------------------------
; Controller buttons
; ------------------------------------------------

bitJoyStart	equ 7
bitJoy1		equ 4
bitJoy2		equ 5
bitJoyRight	equ 3
bitJoyLeft	equ 2
bitJoyDown	equ 1
bitJoyUp	equ 0

JoyUp		equ 01h
JoyDown 	equ 02h
JoyLeft		equ 04h
JoyRight	equ 08h
Joy1		equ 10h
Joy2		equ 20h

; --------------------------------------------------------
; Sound
; --------------------------------------------------------

; settings
MAX_CHNLS	equ 4
MAX_TRACKS	equ 2

; Track structure
trck_ReqBlk	equ 00h		; word
trck_ReqPatt	equ 02h		; word
trck_ReqIns	equ 04h		; word
trck_ReqTicks	equ 06h
trck_ReqTempo	equ 07h
trck_ReqCurrBlk	equ 08h
trck_ReqSndBnk	equ 09h
trck_ReqFlag	equ 0Ah
trck_ReqChnls	equ 0Bh
trck_PsgNoise	equ 0Ch
trck_TicksRead	equ 0Dh
trck_BlockCurr	equ 0Eh
trck_MasterVol	equ 0Fh
trck_Priority	equ 10h
trck_Active	equ 11h
trck_Blocks	equ 12h		; word
trck_PattBase	equ 14h		; word
trck_Instr	equ 16h		; word
trck_PattRead	equ 18h		; word
trck_RowSteps	equ 1Ah		; word
trck_TicksMain 	equ 1Ch
trck_TempoBits	equ 1Dh
trck_RowWait	equ 1Eh
trck_TicksCurr	equ 1Fh
trck_PsgStereo	equ 20h
trck_Volume	equ 21h

; channel buffers
chnl_Chip	equ 0
chnl_Type	equ 1
chnl_Note	equ 2
chnl_Ins	equ 3
chnl_Vol	equ 4
chnl_EffId	equ 5
chnl_EffArg	equ 6
chnl_InsAddr	equ 7		; word
chnl_Freq	equ 09h		; word
chnl_InsType	equ 0Bh
chnl_InsOpt	equ 0Ch
chnl_PsgPan	equ 0Dh
chnl_PsgVolBase	equ 0Eh
chnl_PsgVolEnv	equ 0Fh
chnl_PsgIndx	equ 10h
chnl_EfVolSlide	equ 11h
chnl_EfNewVol	equ 12h
chnl_EfPortam	equ 13h		; word
chnl_EfNewFreq	equ 15h		; word
chnl_PsgOutFreq	equ 17h		; word

; ====================================================================
; ----------------------------------------------------------------
; Alias
; ----------------------------------------------------------------

Controller_1	equ RAM_InputData
Controller_2	equ RAM_InputData+sizeof_input

VDP_PALETTE	equ 0C000h				; Palette

; ====================================================================
; ----------------------------------------------------------------
; Structures
; ----------------------------------------------------------------

; Controller
		struct 0
on_hold		ds 1
on_press	ds 1
sizeof_input	ds 1
		finish

; ====================================================================
; ----------------------------------------------------------------
; Master System RAM
;
; Note: 0DFFCh-0DFFFh (0FFFCh-0FFFFh)
; is reserved for bankswitch
; ----------------------------------------------------------------

; This looks bad but it works as intended

	; First pass, empty sizes
		struct MSRAM_START		; Set struct at start of our base RAM
	if MOMPASS=1
RAM_MsSound	ds 1
RAM_MsVideo	ds 1
RAM_MsSystem	ds 1
RAM_Local	ds 1
RAM_Global	ds 1
sizeof_mdram	ds 1
	else
	
	; Second pass, sizes are set
RAM_MsSound	ds sizeof_mssnd-RAM_MsSound
RAM_MsVideo	ds sizeof_msvid-RAM_MsVideo
RAM_MsSystem	ds sizeof_mssys-RAM_MsSystem
RAM_Local	ds MAX_MSERAM
RAM_Global	ds sizeof_global-RAM_Global
sizeof_msram	ds 1
	endif					; end this section
	
	; --------------------------------
	; Report RAM usage
	; on pass 7
	if MOMPASS=5
		message "MS RAM ends at: \{sizeof_msram}"
	endif
		finish

; ====================================================================
; ----------------------------------------------------------------
; System RAM
; ----------------------------------------------------------------

		struct RAM_MsSystem
RAM_InputData	ds sizeof_input*2		; 2 controller buffers
RAM_VBlank	ds 3
RAM_HBlank	ds 3
sizeof_mssys	ds 1
		finish

; ====================================================================
; ----------------------------------------------------------------
; Video cache RAM
; ----------------------------------------------------------------

		struct RAM_MsVideo
RAM_VidPrntList	ds MAX_PRNTLIST*3		; VDP address (WORD), type (BYTE)
RAM_VidPrntVram	ds 2				; Current VRAM address for the Print routines
RAM_VdpCache	ds 11
RAM_SprtY	ds 64				; Y list
RAM_SprtX	ds 64*2				; X list + char
RAM_CurrSprY	ds 2
RAM_CurrSprX	ds 2
sizeof_msvid	ds 1
		finish
		
; ====================================================================
; ----------------------------------------------------------------
; Sound buffer RAM
; ----------------------------------------------------------------

			struct RAM_MsSound
SndBuff_Track_1		ds 20h
SndBuff_Track_2		ds 20h
SndBuff_ChnlBuff_1	ds 20h*MAX_CHNLS
SndBuff_ChnlBuff_2	ds 20h*MAX_CHNLS
SndBuff_UsedChnls	ds MAX_CHNLS
SndBuff_UsedChnls_2	ds MAX_CHNLS
curr_NoiseMode		ds 1
curr_SndBank		ds 1
curr_PsgStereo		dw 1			; Game gear only: current and past values
sizeof_mssnd		ds 1
			finish
