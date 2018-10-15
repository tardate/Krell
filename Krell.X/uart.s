/***************************************************************************
* FILE:      uart.s												*
* CONTENTS:  UART routines										*
* COPYRIGHT: MadLab Ltd. 2013-18									*
* AUTHOR:    James Hutchby										*
* UPDATED:   14/06/18											*
***************************************************************************/

.include "p33EP128MC202.inc"
.include "common.inc"


;---------------------------------------------------------------------------
; port assignments
;---------------------------------------------------------------------------

.equ UART_RX, 44			; RX (RPI44/RB12)
.equ UART_TX, 36			; TX (RP36/RB4)


.section .text

;---------------------------------------------------------------------------
; InitUART - initialises the UART
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0 - w2
;---------------------------------------------------------------------------

.global InitUART
InitUART:

.equ CLI_BAUD, 9600			; CLI baud rate
.equ MIDI_BAUD, 31250		; MIDI baud rate

		disi #8

		mov #OSCCONL,w0				; unlock peripheral pin select
		mov #0x46,w1
		mov #0x57,w2
		mov.b w1,[w0]
		mov.b w2,[w0]
		bclr.b [w0],#IOLOCK

		mov #UART_RX,w0				; remap U1RX
		mov w0,RPINR18

		mov #0b000001,w0				; remap U1TX
		mov.b wreg,RPOR1L

		disi #8

		mov #OSCCONL,w0				; lock peripheral pin select
		mov #0x46,w1
		mov #0x57,w2
		mov.b w1,[w0]
		mov.b w2,[w0]
		bset.b [w0],#IOLOCK

.equ BRG_CLI, (((CLOCK/2)+2*CLI_BAUD)/(4*CLI_BAUD))-1
.equ BRG_MIDI, (((CLOCK/2)+2*MIDI_BAUD)/(4*MIDI_BAUD))-1

		btsc SysFlags,#CLI_ENABLE		; baud rate
		mov #BRG_CLI,w0
		btsc SysFlags,#MIDI_ENABLE
		mov #BRG_MIDI,w0
		mov w0,U1BRG

		bclr IPC2,#U1RXIP2				; receiver priority = 3
		bset IPC2,#U1RXIP1
		bset IPC2,#U1RXIP0

		bclr IPC3,#U1TXIP2				; transmitter priority = 3
		bset IPC3,#U1TXIP1
		bset IPC3,#U1TXIP0

		mov #0b0000000000000000,w0		; interrupt on each character
		mov w0,U1STA

		mov #0b0000000000001000,w0		; no flow control, 8 data, no parity, 1 stop
		mov w0,U1MODE

		bset U1MODE,#UARTEN				; enable UART
		nop
		bset U1STA,#UTXEN

		bclr IFS0,#U1RXIF				; enable receiver interrupt
		bset IEC0,#U1RXIE

		bclr IFS0,#U1TXIF				; enable transmitter interrupt
		bset IEC0,#U1TXIE

		bclr IEC4,#U1EIE				; disable error interrupt

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

.global __U1RXInterrupt
__U1RXInterrupt:

		btsc SysFlags,#CLI_ENABLE
		rcall CLI_RXInterrupt
		btsc SysFlags,#MIDI_ENABLE
		rcall MIDI_RXInterrupt

		bclr IFS0,#U1RXIF				; clear interrupt

		retfie


;---------------------------------------------------------------------------
; UART transmitter isr
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	-
;---------------------------------------------------------------------------

.global __U1TXInterrupt
__U1TXInterrupt:

		btsc SysFlags,#CLI_ENABLE
		rcall CLI_TXInterrupt

		bclr IFS0,#U1TXIF				; clear interrupt

		retfie


.end
