; ===========================================================================
; ----------------------------------------------------------------
; MACROS
; ----------------------------------------------------------------

; ====================================================================
; ---------------------------------------------
; Functions
; ---------------------------------------------

; example of function
locate		function b,c,(c&0FFh)|(b<<8&0FF00h)		; Layer,X pos,Y pos for some video routines

; ====================================================================
; ---------------------------------------------
; Macros
; ---------------------------------------------

; -------------------------------------
; Reserve memory space
; -------------------------------------

struct		macro thisinput			; Reserve memory address
GLBL_LASTPC	eval $
GLBL_LASTORG	eval $
		dephase
		phase thisinput
		endm
		
; -------------------------------------
; Finish reserve
; -------------------------------------

finish		macro				; Then finish
		!org GLBL_LASTORG
		phase GLBL_LASTPC
		endm

; -------------------------------------
; ZERO Fill padding
; 
; if AS align doesn't work
; -------------------------------------

rompad		macro address			; Zero fill
diff := address - *
		if diff < 0
			error "too much stuff before org $\{address} ($\{(-diff)} bytes)"
		else
			while diff > 1024
				; AS can only generate 1 kb of code on a single line
				dc.b [1024]0
diff := diff - 1024
			endm
			dc.b [diff]0
		endif
	endm

; ====================================================================
