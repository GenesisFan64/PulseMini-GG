; ====================================================================
; ----------------------------------------------------------------
; System
; ----------------------------------------------------------------

; --------------------------------------------------------
; Init System
; --------------------------------------------------------

System_Init:
	;Clear a work ram ($C001 to $DFEF)
		ld      hl,0C000h  		; hl - System RAM
		ld      de,0C001h  		; de - (System RAM + 1)
		ld      bc,01000h  		; bc - Bytes to copy
		ld      (hl),0			; Set $00 at first byte of RAM before copying bytes
		ldir				; read (RAM), write to (RAM+1), increment de, hl and decrement bc

		in	a,(gg_info)		; Read Game Gear extra bits
		and	1Fh			; only grab 5 bits
		jp	nz,.not_gg		; If not Zero, don't set extra gg regs
		ld      a,11111111b   		; all ones
		out     (gg_ext_bitdir),a   	; set i/o port 2h (read/write) to all ones
                out 	(gg_stereo),a		; gg psg stereo full
		xor     a         		; set a to zero
		out     (gg_ext_comm),a   	; set i/o port 1h to zero
		out     (gg_serial),a   	; set i/o port 5h to zero
.not_gg:
		xor     a         		; set a to zero
		ld      (bank_ctrl),a		; set bank control register to all zeros
		ld      (bank_0),a		; set bank reg #0 to all zeros
		inc	a
		ld      (bank_1),a		; set bank reg #1 to 0001
		inc	a
		ld      (bank_2),a		; set bank reg #2 to 0010
		
		ld	a,0C3h
		ld	(RAM_VBlank),a
		ld	(RAM_HBlank),a
		ld	bc,MS_VInt
		ld	de,MS_HInt
		ld	(RAM_VBlank+1),bc
		ld	(RAM_HBlank+1),de
		ret

; ====================================================================
; ----------------------------------------------------------------
; System subroutines
; ----------------------------------------------------------------

; --------------------------------------------------------
; System_VSync
; 
; Wait for VBlank
; --------------------------------------------------------

System_VSync:
		in	a,(vdp_ctrl)		; Read VDP Control
		and	10000000b		; Get VBlank bit
		jp	z,System_VSync		; if Zero, keep waiting
		ret
		
; --------------------------------------------------------
; System_Input
; 
; WARNING: Don't call this outside of VBLANK
; (call System_VSync first)
; 
; Uses:
; hl,bc
; --------------------------------------------------------

System_Input:
 
; ---------------------------
; Read current controllers
; ---------------------------

		ld	hl,RAM_InputData	; hl - Input data stored in RAM

	; Controller 1
		ld	b,0			; b = 0
		in	a,(gg_info)		; Read GG port 00h (START button and region)
		ld	c,a			; Copy result to c
		and	1Fh			; only read right 5 bits
		jp	nz,.no_ggstrt		; if != 0, skip this
		ld	a,c			; move our copy to a
		cpl				; reverse bits
		and	80h			; only read the MSB
		ld	b,a			; b = Start button bit press
.no_ggstrt:
		in      a,(joypad_1)		; Read controller 1 port
		cpl				; Reverse bits
		and	00111111b		; Only grab 0012RLDU 
		or	b			; Merge GG start button if available S012RLDU
		ld	b,a			; Copy input from a to b
 		ld	a,(hl)			; Read OLD holding bits from RAM
 		xor	b			; XOR with NEW holding bits, now a contains pressed bits
		ld	(hl),b			; Save NEW holding press to RAM
		inc	hl			; Next RAM byte
		and	b			; Only allow holding bits to pass on pressed bits
		ld	(hl),a			; Save pressed bits to RAM
		inc 	hl			; Next controller
 
	; Controller 2
		in      a,(joypad_1)		; Read controller 1 port (for Down/Up)
		cpl				; Reverse bits, DU??????
		rlca				; U?????D
		rlca				; ?????DU
		and	11b			; 00000DU
		ld	b,a			; Save copy to b
		in      a,(joypad_2)		; Read controller 2 port (for 2/1/Right/Left)
		cpl				; Reverse bits, ????21RL
		rlca				; ???21RL?
		rlca				; ??21RL??
		and	00111100b		; 0021RL00
		or	b			; Combine results: 0021RLDU
		ld	b,a			; Copy input from a to b
 		ld	a,(hl)			; Read OLD holding bits from RAM
 		xor	b			; XOR with NEW holding bits, now a contains pressed bits
		ld	(hl),b			; Save NEW holding press to RAM
		inc	hl			; Next RAM byte
		and	b			; Only allow holding bits to pass on pressed bits
		ld	(hl),a			; Save pressed bits to RAM
		ret
		
; ====================================================================
; ----------------------------------------------------------------
; System data
; ----------------------------------------------------------------
