/***************************************************************************
* FILE:      cli.s												*
* CONTENTS:  Command line interpreter routines						*
* COPYRIGHT: MadLab Ltd. 2013-18									*
* AUTHOR:    James Hutchby										*
* UPDATED:   14/07/18											*
***************************************************************************/

.include "p33EP128MC202.inc"
.include "common.inc"


;---------------------------------------------------------------------------
; specification
;---------------------------------------------------------------------------

; serial communications 9600N1
; no handshaking
; no echo
; responds to command line terminated by carriage return
; arguments in ASCII decimal


;---------------------------------------------------------------------------
; commands
;---------------------------------------------------------------------------

; H[elp] - displays command summary

; V[olume] <vol> - sets master volume
; <vol> = 0 (silent) to 16 (maximum) (default = 7)

; G[ain] 1|2 - sets gain x1 or x2 (Noise-X)

; P[rogram] <prog> - sets program
; <prog> = 0 (user) or 1 to 14 (demo)

; C[ontrol] <cntrl> <val> - sets control
; <cntrl> = 0 to 71, <val> = 0 to 4095

; D[isplay] - displays all controls


.equ TX_BUFFER_LEN, 400		; transmit buffer length
.equ RX_BUFFER_LEN, 100		; receive buffer length


.section .text

;---------------------------------------------------------------------------
; InitCLI - initialises CLI
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0 - w2
;---------------------------------------------------------------------------

.global InitCLI
InitCLI:

		clr RX_bytes					; receive buffer empty
		clr.b RX_eol

		mov #TX_buffer,w0				; transmit buffer empty
		mov w0,TX_rd_pnt
		mov w0,TX_wr_pnt
		clr TX_bytes

		mov #psvoffset(signon),w0		; display sign-on message
		rcall print_string

		mov.b #'>',w0					; print prompt
		rcall print_char

		return


;---------------------------------------------------------------------------
; UART receiver isr
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	-
;---------------------------------------------------------------------------

.global CLI_RXInterrupt
CLI_RXInterrupt:

		push.d w0

1:		btsc U1STA,#FERR				; framing error ?
		bra 2f						; branch if yes

		mov U1RXREG,w1					; received byte

		cp.b w1,#'\r'					; carriage return ?
		bra z,3f						; branch if yes

		cp.b w1,#'\n'					; newline ?
		bra z,3f						; branch if yes

		mov #RX_buffer,w0				; store in receive buffer
		add RX_bytes,wreg
		mov.b w1,[w0]

		inc RX_bytes

		mov #RX_BUFFER_LEN,w0			; receive buffer full ?
		cp RX_bytes
		bra z,3f						; branch if yes

		btsc U1STA,#URXDA				; further bytes available ?
		bra 1b						; loop if yes

		bra 4f

2:		mov U1RXREG,w1					; discard byte

		btsc U1STA,#URXDA				; further bytes available ?
		bra 1b						; loop if yes

		bra 4f

3:		mov #RX_buffer,w0				; terminate buffer
		add RX_bytes,wreg
		clr.b [w0]

		setm.b RX_eol					; signal end-of-line

		bclr IEC0,#U1RXIE				; disable interrupts

4:		bclr U1STA,#OERR

		pop.d w0

		return


;---------------------------------------------------------------------------
; UART transmitter isr
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	-
;---------------------------------------------------------------------------

.global CLI_TXInterrupt
CLI_TXInterrupt:

		push.d w0

1:		cp0 TX_bytes					; transmit buffer empty ?
		bra z,2f						; branch if yes

		mov TX_rd_pnt,w0				; get next byte from buffer
		mov.b [w0++],w1
		ze w1,w1

		dec TX_bytes

		mov w1,U1TXREG					; transmit byte

		mov #TX_buffer+TX_BUFFER_LEN,w1	; wrap pointer
		cp w0,w1
		bra ltu,$+4
		mov #TX_buffer,w0

		mov w0,TX_rd_pnt

		btss U1STA,#UTXBF				; further space available ?
		bra 1b						; loop if yes

		bra 3f

2:		bclr IEC0,#U1TXIE				; disable interrupts

3:		pop.d w0

		return


;---------------------------------------------------------------------------
; DoCLI - CLI executive
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0 - w3
;---------------------------------------------------------------------------

.global DoCLI
DoCLI:

		rcall GetCommandLine			; command line available ?
		bra z,1f						; branch if not

		rcall ParseCLI

		mov.b #'>',w0					; print prompt
		rcall print_char

		rcall ResetCommandLine

1:		return


;---------------------------------------------------------------------------
; ParseCLI - parses the command line
;
; Entry:	w0 = pointer to command line
;
; Exit: 	-
;
; Uses:	w0 - w3
;---------------------------------------------------------------------------

ParseCLI:

		push.d w4
		push.d w6

		rcall step_space				; find command

		cp0.b w1						; null command line ?
		bra z,exit					; branch if yes

		cp.b w1,#'H'					; help command ?
		bra z,help_
		cp.b w1,#'h'
		bra z,help_					; branch if yes

		cp.b w1,#'V'					; volume command ?
		bra z,volume_
		cp.b w1,#'v'
		bra z,volume_					; branch if yes

		cp.b w1,#'G'					; gain command ?
		bra z,gain_
		cp.b w1,#'g'
		bra z,gain_					; branch if yes

		cp.b w1,#'P'					; program command ?
		bra z,program_
		cp.b w1,#'p'
		bra z,program_					; branch if yes

		cp.b w1,#'C'					; control command ?
		bra z,control_
		cp.b w1,#'c'
		bra z,control_					; branch if yes

		cp.b w1,#'D'					; display command ?
		bra z,display_
		cp.b w1,#'d'
		bra z,display_					; branch if yes

		mov #psvoffset(error),w0			; display error message
		rcall print_string

exit:	pop.d w6
		pop.d w4

		return


help_:
		mov #psvoffset(help),w0			; display help message
		rcall print_string

		bra exit


volume_:
		rcall step_command				; step over command

		rcall get_arg					; get volume
		bra n,exit

		mov #MAX_MASTER_VOLUME,w2		; check in range
		cp w1,w2
		bra leu,$+4
		mov w2,w1

		mov w1,w0						; set volume
		rcall SetVolume

		mov.b Mode,wreg
		setm.b Mode
		rcall SetMode

		bra exit


gain_:
		rcall step_command				; step over command

		rcall get_arg					; get gain
		bra n,exit

		cp w1,#1
		bra nz,$+4
		bclr SysFlags,#GAIN_2X
		cp w1,#2
		bra nz,$+4
		bset SysFlags,#GAIN_2X

		bra exit


program_:
		rcall step_command				; step over command

		rcall get_arg					; get program number
		bra n,exit

		mov #NUM_PROGRAMS,w2			; check in range
		cp w1,w2
		bra gtu,1f

		mov w1,w0						; set program
		rcall SetProgram

		bra exit

1:		mov #psvoffset(invalid),w0		; display invalid message
		rcall print_string

		bra exit


control_:
		rcall step_command				; step over command

		rcall get_arg					; get control number
		bra n,exit

		mov #NUM_CONTROLS,w2			; check in range
		cp w1,w2
		bra geu,1f

		mov w1,w2

		rcall get_arg					; get control value
		bra n,exit

		mov #0x0fff,w0					; check in range
		and w1,w0,w1

		mov w2,w0						; set control
		exch w0,w1
		rcall SetControl

		mov.b Mode,wreg
		setm.b Mode
		rcall SetMode

		bra exit

1:		mov #psvoffset(invalid),w0		; display invalid message
		rcall print_string

		bra exit


display_:
		clr w0
		mov #6,w1

1:		push w0

		rcall GetControl				; print control value
		rcall print_decimal

		dec w1,w1
		bra z,2f
		mov.b #'\t',w0
		rcall print_char
		bra 3f
2:		mov #6,w1
		mov.b #'\r',w0
		rcall print_char
		mov.b #'\n',w0
		rcall print_char

3:		pop w0
		inc w0,w0

		cp w0,#NUM_CONTROLS
		bra nz,1b

		bra exit


;---------------------------------------------------------------------------
; get_arg - gets a numeric argument
;
; Entry:	w0 = pointer to command line
;
; Exit: 	w0 advanced over argument
;		w1 = argument, or -1 if not present
;		N flag cleared if okay, set if not present
;
; Uses:	-
;---------------------------------------------------------------------------

get_arg:

		push.d w2

		rcall step_space				; step to argument

		setm w2

		mov.b #'0',w3					; 0 - 9 ?
		cp.b w1,w3
		bra ltu,2f
		mov.b #'9',w3
		cp.b w1,w3
		bra gtu,2f					; branch if not

		clr w2

1:		mov.b #'0',w3					; 0 - 9 ?
		cp.b w1,w3
		bra ltu,2f
		mov.b #'9',w3
		cp.b w1,w3
		bra gtu,2f					; branch if not

		mul.uu w2,#10,w2				; add digit
		sub.b #'0',w1
		ze w1,w1
		add w2,w1,w2

		mov.b [++w0],w1				; get next character

		bra 1b

2:		mov w2,w1

		cp0 w1

		pop.d w2

		return


;---------------------------------------------------------------------------
; step_command - steps over a command
;
; Entry:	w0 = pointer to command line
;
; Exit: 	w0 advanced over command
;
; Uses:	-
;---------------------------------------------------------------------------

step_command:

		push w1
		push w2

1:		mov.b [w0++],w1				; get next character

		mov.b #'A',w2					; A - Z ?
		cp.b w1,w2
		bra ltu,2f
		mov.b #'Z',w2
		cp.b w1,w2
		bra leu,1b					; branch if yes

2:		mov.b #'a',w2					; a - z ?
		cp.b w1,w2
		bra ltu,3f
		mov.b #'z',w2
		cp.b w1,w2
		bra leu,1b					; branch if yes

3:		dec w0,w0

		pop w2
		pop w1

		return


;---------------------------------------------------------------------------
; step_space - steps over spaces
;
; Entry:	w0 = pointer to command line
;
; Exit: 	w0 advanced over spaces
;		w1.b = first non-space character
;
; Uses:	-
;---------------------------------------------------------------------------

step_space:

		push w2

1:		mov.b [w0++],w1				; get next character

		mov.b #' ',w2					; space ?
		cp.b w1,w2
		bra z,1b						; branch if yes

		mov.b #'\t',w2					; tab ?
		cp.b w1,w2
		bra z,1b						; branch if yes

		dec w0,w0

		pop w2

		return


;---------------------------------------------------------------------------
; GetCommandLine - returns a pointer to the command line if ready
;
; Entry:	-
;
; Exit: 	w0 = pointer to command line, or 0 if not ready
;		Z flag set if not ready
;
; Uses:	-
;---------------------------------------------------------------------------

GetCommandLine:

		push w1
		push w2

		cp0.b RX_eol					; end of line received ?
		bra z,4f						; branch if not

		mov #RX_buffer,w0				; process backspaces
		mov w0,w2

1:		mov.b [w0++],w1

		cp0.b w1
		bra z,3f

		cp.b w1,#'\b'
		bra nz,2f

		mov #RX_buffer,w1
		cp w2,w1
		bra z,$+4
		dec w2,w2

		bra 1b

2:		mov.b w1,[w2++]

		bra 1b

3:		clr.b [w2]

		mov #RX_buffer,w0				; pointer to command line

		bra 5f

4:		clr w0						; signal not ready

5:		cp0 w0

		pop w2
		pop w1

		return


;---------------------------------------------------------------------------
; ResetCommandLine - resets the command line
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	-
;---------------------------------------------------------------------------

ResetCommandLine:

		clr RX_bytes

		clr.b RX_eol

		bclr IFS0,#U1RXIF
		btsc U1STA,#URXDA
		bset IFS0,#U1RXIF

		bset IEC0,#U1RXIE				; enable interrupts

		return


;---------------------------------------------------------------------------
; print_decimal - prints a number in decimal
;
; Entry:	w0 = number
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

print_decimal:

		push w1
		push.d w2

		mov w0,w2

.macro digit n
		mov #\n,w3
		rcall prt_int
.endm

		clr w1
		digit 1000
		digit 100
		digit 10
		setm w1
		digit 1

		pop.d w2
		pop w1

		return

prt_int:
		mov.b #-1,w0
1:		inc.b w0,w0
		sub w2,w3,w2
		bra c,1b
		add w2,w3,w2

		cp0.b w0
		bra z,$+4
		setm w1
		cp0 w1
		bra z,2f
		add.b #'0',w0
		rcall print_char

2:		return


;---------------------------------------------------------------------------
; print_string - prints a string
;
; Entry:	w0 = pointer to string (zero terminated)
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

print_string:

		push w1
		push w2

		mov w0,w1

1:		mov #TX_BUFFER_LEN,w0			; transmit buffer full ?
		cp TX_bytes
		bra geu,2f					; branch if yes

		mov.b [w1++],w0				; next character

		cp0.b w0						; end of string ?
		bra z,2f						; branch if yes

		mov TX_wr_pnt,w2				; store in buffer
		mov.b w0,[w2++]

		mov #TX_buffer+TX_BUFFER_LEN,w0	; wrap pointer
		cp w2,w0
		bra ltu,$+4
		mov #TX_buffer,w2

		mov w2,TX_wr_pnt

		inc TX_bytes

		bra 1b

2:		bclr IFS0,#U1TXIF
		btss U1STA,#UTXBF
		bset IFS0,#U1TXIF

		bset IEC0,#U1TXIE				; enable interrupts

		pop w2
		pop w1

		return


;---------------------------------------------------------------------------
; print_char - prints a character
;
; Entry:	w0.b = character
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

print_char:

		push w1
		push w2

		mov.b w0,w1

		mov #TX_BUFFER_LEN,w0			; transmit buffer full ?
		cp TX_bytes
		bra geu,1f					; branch if yes

		mov TX_wr_pnt,w2				; store in buffer
		mov.b w1,[w2++]

		mov #TX_buffer+TX_BUFFER_LEN,w0	; wrap pointer
		cp w2,w0
		bra ltu,$+4
		mov #TX_buffer,w2

		mov w2,TX_wr_pnt

		inc TX_bytes

1:		bclr IFS0,#U1TXIF
		btss U1STA,#UTXBF
		bset IFS0,#U1TXIF

		bset IEC0,#U1TXIE				; enable interrupts

		pop w2
		pop w1

		return


;---------------------------------------------------------------------------
; strings
;---------------------------------------------------------------------------

.section .const, psv

signon:
		.if NOISE_X
		.ascii "Noise-X command line\r\n"
		.endif
		.if KRELL
		.ascii "Krell command line\r\n"
		.endif
		.ascii "Written by James Hutchby, MadLab 2012-18\r\n"
		.ascii "Type H for help.\r\n"
		.asciz "\r\n"

help:
		.ascii "H[elp] - displays command summary\r\n"
		.ascii "V[olume] <vol> - sets master volume, <vol> = 0 (silent) to 16 (maximum)\r\n"
		.if NOISE_X
		.ascii "G[ain] 1|2 - sets gain x1 or x2\r\n"
		.endif
		.ascii "P[rogram] <prog> - sets program, <prog> = 0 (user) or 1 to 14 (demo)\r\n"
		.ascii "C[ontrol] <cntrl> <val> - sets control, <cntrl> = 0 to 71, <val> = 0 to 4095\r\n"
		.ascii "D[isplay] - displays all controls\r\n"
		.asciz "\r\n"

error:
		.asciz "Invalid command\r\n"

invalid:
		.asciz "Invalid argument\r\n"


;---------------------------------------------------------------------------
; variables
;---------------------------------------------------------------------------

.section .nbss,bss,near
.align 2

TX_rd_pnt:	.space 2			; transmit buffer read pointer
TX_wr_pnt:	.space 2			; transmit buffer write pointer
RX_bytes:		.space 2			; number of bytes in receive buffer
TX_bytes:		.space 2			; number of bytes in transmit buffer
RX_eol:		.space 1			; set if end-of-line received

.section .bss,bss
.align 1

RX_buffer:	.space RX_BUFFER_LEN+1		; receive buffer (linear)
TX_buffer:	.space TX_BUFFER_LEN		; transmit buffer (circular)


.end
