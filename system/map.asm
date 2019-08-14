; ====================================================================
; ----------------------------------------------------------------
; Memory map
; ----------------------------------------------------------------

; Banks are 4000h bytes long
bank_ctrl	equ	0FFFCh
bank_0		equ	0FFFDh		; First 1Kbytes (0000h-0400h) are locked to protect interrupts
bank_1		equ	0FFFEh		;
bank_2		equ	0FFFFh		; If bit 3 is set, Cartridge RAM will be mapped here instead.

; ----------------------------------------------------------------
; Ports
; 
; Remainder: only use these with IN and OUT
; R - Read
; W - Write
; ----------------------------------------------------------------

memory_ctrl	equ	03Eh		; 
joypad_ctrl	equ	03Fh		; R  | 
v_counter	equ	07Eh
psg_ctrl	equ	07Fh		; RW | if WRITE: psg register | if READ: h_counter
vdp_data	equ	0BEh
vdp_ctrl	equ	0BFh
joypad_1	equ	0DCh
joypad_2	equ	0DDh

; ------------------------------------------------
; GAME GEAR ONLY
; on Master System they probably just return -1
; ------------------------------------------------

gg_info		equ	00h		; R  | SRN00000b (S-GG Start button | R-Region | N-NTSC/PAL)
gg_ext_comm	equ	01h		; RW | EXT data if 7-bit mode is set
gg_ext_bitdir	equ	02h		; RW | EXT data directions
gg_serial_out	equ	03h		; RW | Serial data SEND port
gg_serial_in	equ	04h		; R  | Serial data RECIEVE port
gg_serial	equ	05h		; RW | Serial settings
gg_stereo	equ	06h		;  W | PSG Stereo bits, set 0FFh if using Game Gear
