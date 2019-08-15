; ===========================================================================
; +-----------------------------------------------------------------+
; SEGA MASTER SYSTEM GAME TEMPLATE
; +-----------------------------------------------------------------+

		!org 0				; [AS] Start at 0
		listing purecode		; [AS] Want listing file, but only the final code in expanded macros
		supmode on 			; [AS] Supervisor mode
		page 0				; [AS] Listing page 0
		cpu Z80				; [AS] Current CPU is Z80
		
; ====================================================================
; ----------------------------------------------------------------
; Include variables
; ----------------------------------------------------------------

		include "system/macros.asm"	; Assembler macros
		include "system/const.asm"	; Variables and constants
		include "system/map.asm"	; Memory map
		include "game/global.asm"	; Global variables and RAM

; ====================================================================
; DEFAULT BANK 0
; 0000-3FFFh
; 
; (0000-0400h is unaffected)
; ====================================================================

		di				; Disable interrupts
		im	1			; Interrput mode 1 (standard)
		jp	MS_Init			; Go to MS_Init

; ====================================================================
; ----------------------------------------------------------------
; RST routines will go here (starting at 0008h)
; 
; aligned by 8
; ----------------------------------------------------------------

		align 8

; ====================================================================
; ----------------------------------------------------------------
; VBlank and HBlank
; 
; located at 38h
; ----------------------------------------------------------------

		align 38h
		di
		push	af
		in	a,(vdp_ctrl)
		rlca
		jp	c,.vint
		or	80h
		jp	nz,.vint
		jp	(RAM_HBlank)
.vint:
		jp	(RAM_VBlank)
Int_Exit:
		pop	af
		ei
		ret

; ====================================================================
; ----------------------------------------------------------------
; Master System PAUSE Button interrupt
; 
; at address 0066h
; ----------------------------------------------------------------

		align 66h
		ret

; ====================================================================
; ----------------------------------------------------------------
; Default VBlank
; ----------------------------------------------------------------

MS_VInt:
		push	ix
		push	iy
		push	bc
		push	de
		push	hl
		exx
		push	bc
		push	de
		push	hl
		
		call	System_Input
		call	Sound_Run

		pop	hl
		pop	de
		pop	bc
		exx
		pop	hl
		pop	de
		pop	bc
		pop	iy
		pop	ix
		jp	Int_Exit
		
; ====================================================================
; ----------------------------------------------------------------
; Default HBlank
; ----------------------------------------------------------------

MS_HInt:
		jp	Int_Exit

; ====================================================================
; ----------------------------------------------------------------
; System functions
; ----------------------------------------------------------------

		include "system/sound.asm"	; Sound
		include "system/video.asm"	; Video
		include "system/setup.asm"	; System

; ====================================================================
; ----------------------------------------------------------------
; MS Start
; ----------------------------------------------------------------

		align 400h
MS_Init:
		ld	sp,0DFF0h		; Stacks starts at 0DFF0h, goes backwards
		call	System_Init		; Init System
		call	Sound_Init		; Init Sound
		call	Video_Init		; Init Video

; ================================================================
; ------------------------------------------------------------
; Your code starts here
; ------------------------------------------------------------

		align 400h
CodeBank0:
		include	"game/code.asm"
CodeBank0_e:
	if MOMPASS=1
		message "This CODE bank uses: \{((CodeBank0_e-CodeBank0)&0FFFFh)}"
	endif
	
; ====================================================================
; DEFAULT BANK 1
; 4000-7FFFh
; ====================================================================
		
		align 4000h
DataBank0:
		include	"game/data.asm"
		include	"game/sound/data.asm"
DataBank0_e:
	if MOMPASS=1
		message "This DATA bank uses: \{((DataBank0_e-DataBank0)&0FFFFh)}"
	endif
	
; ============================================================
; Header must be at the end of BANK 1
; ============================================================

		align 7FF0h			; Align up to 7FF0h (almost at the end of BANK 1)
		db "TMR SEGA  "			; TMR SEGA
		dw 0				; Checksum (externally calculated)
		dw 0				; Serial
		db 0				; Version
		db 4Ch				; ROM size: 32k

; ====================================================================
		
ROM_END:	align 8000h
