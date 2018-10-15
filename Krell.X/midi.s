/***************************************************************************
* FILE:      midi.s												*
* CONTENTS:  MIDI routines										*
* COPYRIGHT: MadLab Ltd. 2013-18									*
* AUTHOR:    James Hutchby										*
* UPDATED:   14/07/18											*
***************************************************************************/

.include "p33EP128MC202.inc"
.include "common.inc"


;---------------------------------------------------------------------------
; specification
;---------------------------------------------------------------------------

; responds to control change messages on all MIDI channels
; controller number = 0 to 71, controller value = 0 to 127


;---------------------------------------------------------------------------
; MIDI status bytes
;---------------------------------------------------------------------------

.equ NOTE_OFF, 0b1000<<4				; Note Off event
.equ NOTE_ON, 0b1001<<4				; Note On event
.equ KEY_PRESSURE, 0b1010<<4			; Polyphonic key pressure/after touch
.equ CONTROL_CHANGE, 0b1011<<4		; Control change
.equ PROGRAM_CHANGE, 0b1100<<4		; Program change
.equ CHANNEL_PRESSURE, 0b1101<<4		; Channel pressure/after touch
.equ PITCH_BEND, 0b1110<<4			; Pitch bend change
.equ SYSTEM, 0b1111<<4				; System message

.equ SYSTEM_EXCLUSIVE, 0b11110000		; System Exclusive
.equ SYSTEM_COMMON, 0b11110<<3		; System Common
.equ SYSTEM_REAL_TIME, 0b11111<<3		; System Real Time

.equ SONG_POSITION, 0b11110010		; Song Position Pointer
.equ SONG_SELECT, 0b11110011			; Song Select
.equ TUNE_REQUEST, 0b11110110			; Tune Request
.equ EOX, 0b11110111				; End of System Exclusive

.equ TIMING_CLOCK, 0b11111000			; Timing Clock
.equ START, 0b11111010				; Start
.equ CONTINUE, 0b11111011			; Continue
.equ STOP, 0b11111100				; Stop
.equ ACTIVE_SENSING, 0b11111110		; Active Sensing
.equ SYSTEM_RESET, 0b11111111			; System Reset

.equ ALL_SOUND_OFF, 120				; all sound off
.equ RESET_ALL_CONTROLLERS, 121		; reset all controllers
.equ LOCAL_CONTROL, 122				; local control
.equ ALL_NOTES_OFF, 123				; all notes off
.equ OMNI_MODE_OFF, 124				; Omni Mode off
.equ OMNI_MODE_ON, 125				; Omni Mode on
.equ MONO_MODE_ON, 126				; Mono Mode on
.equ POLY_MODE_ON, 127				; Poly Mode on


.section .text

;---------------------------------------------------------------------------
; InitMIDI - initialises MIDI
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0 - w2
;---------------------------------------------------------------------------

.global InitMIDI
InitMIDI:

		setm.b MIDIChannel				; all channels
;		clr.b MIDIChannel				; Basic Channel #1

		clr.b MsgLength				; no message
		clr.b MsgIgnore				; no bytes to ignore
		clr.b LastLength				; no previous message

		clr.b MIDIMode					; MIDI Mode #1
		clr.b MIDIGroup				; channel group

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

.global MIDI_RXInterrupt
MIDI_RXInterrupt:

		push w0

1:		btsc U1STA,#FERR				; framing error ?
		bra 2f						; branch if yes

		mov U1RXREG,w0					; received byte
		rcall DoMIDI

		btsc U1STA,#URXDA				; further bytes available ?
		bra 1b						; loop if yes

		bra 3f

2:		mov U1RXREG,w0					; discard byte

		cp0.b MsgLength				; receiving message ?
		bra z,3f						; branch if not

		mov.b MsgLength,wreg
		dec.b w0,w0
		mov.b wreg,MsgIgnore

		clr.b MsgLength				; abort message

3:		bclr U1STA,#OERR

		pop w0

		return


;---------------------------------------------------------------------------
; DoMIDI - processes a MIDI byte
;
; Entry:	w0.b = received byte
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

DoMIDI:

.equ MIDI_TIMEOUT, 2		; MIDI timeout in milliseconds

		push w1
		push w2

		mov.b w0,w2

		cp0.b MsgIgnore				; ignore message ?
		bra nz,ignore					; branch if yes

		cp0.b MsgLength				; receiving message ?
		bra nz,5f						; branch if yes

0:		btss w2,#7					; status byte ?
		bra 4f						; branch if not

1:		mov #psvoffset(Messages),w1		; message table

2:		mov.b [w1+1],w0				; mask
		and.b w0,w2,w0
		cp.b w0,[w1]					; status byte match ?
		bra z,3f						; branch if yes

		add #3,w1						; next entry
		bra 2b

3:		mov #MsgBuffer,w0				; store byte
		mov.b w2,[w0++]
		mov w0,MsgPointer

		mov.b [w1+2],w0				; message length
		mov.b wreg,MsgLength

		mov.b #ACTIVE_SENSING,w0			; active sensing ?
		cp.b w0,w2
		bra z,exit					; ignore if yes

		mov.b #SYSTEM_RESET,w0			; system reset ?
		cpsne.b w0,w2
		reset						; restart if yes

		mov.b w2,w0					; system real time ?
		and.b #0xf8,w0
		sub.b #SYSTEM_REAL_TIME,w0
		bra z,exit					; ignore if yes

		mov.b w2,w0					; last message
		mov.b wreg,LastStatus
		mov.b MsgLength,wreg
		mov.b wreg,LastLength

		bra exit

4:		mov.b LastStatus,wreg			; running status

		mov #MsgBuffer,w1				; store byte
		mov.b w0,[w1++]
		mov w1,MsgPointer

		mov.b LastLength,wreg			; message length
		mov.b wreg,MsgLength

		cp0.b MsgLength
		bra z,exit

		bra 7f

5:		mov Ticks,w0					; message timeout ?
		mov MsgTicks,w1
		sub w0,w1,w0
		cp w0,#MIDI_TIMEOUT
		bra geu,abort					; branch if yes

		btss w2,#7					; status byte ?
		bra 7f						; branch if not

		mov.b #ACTIVE_SENSING,w0			; active sensing ?
		cp.b w0,w2
		bra z,exit					; ignore if yes

		mov.b #SYSTEM_RESET,w0			; system reset ?
		cpsne.b w0,w2
		reset						; restart if yes

		mov.b w2,w0					; system real time ?
		and.b #0xf8,w0
		sub.b #SYSTEM_REAL_TIME,w0
		bra z,exit					; ignore if yes

		mov.b #EOX,w0					; end of system exclusive ?
		cp.b w0,w2
		bra z,6f						; branch if yes

		bra 1b

6:		clr.b MsgLength

		bra exit

7:		btsc.b MsgLength,#7				; system exclusive message ?
		bra exit						; branch if yes

		mov MsgPointer,w1				; store byte
		mov.b w2,[w1++]
		mov w1,MsgPointer

		dec.b MsgLength
		bra nz,exit

		btss.b MIDIMode,#1				; Omni Mode on ?
		bra 8f						; branch if yes

		cp0.b MIDIChannel				; all channels ?
		bra n,8f						; branch if yes

		mov.b MsgBuffer+0,wreg			; correct Voice Channel ?
		and.b #0x0f,w0
		cp.b MIDIChannel
		bra nz,exit					; branch if not

8:		mov.b MsgBuffer+0,wreg
		and.b #0xf0,w0

		mov.b #CONTROL_CHANGE,w1			; control change message ?
		cp.b w0,w1
		bra z,control_change			; branch if yes

		mov.b #PROGRAM_CHANGE,w1			; program change message ?
		cp.b w0,w1
		bra z,program_change			; branch if yes

		bra exit

abort:	clr.b MsgLength				; abort message

		bra 0b

ignore:	dec.b MsgIgnore				; ignore byte

		bra exit

control_change:

		mov.b #ALL_SOUND_OFF,w0			; channel mode message ?
		cp.b MsgBuffer+1
		bra ltu,5f					; branch if not

		mov.b #ALL_SOUND_OFF,w0			; all sound off ?
		cp.b MsgBuffer+1
		bra nz,1f						; branch if not

		cp0.b MsgBuffer+2
		bra nz,exit

		rcall ResetControls				; reset all controls

		mov.b Mode,wreg
		setm.b Mode
		rcall SetMode

		bra exit

1:		mov.b #RESET_ALL_CONTROLLERS,w0	; reset all controllers ?
		cp.b MsgBuffer+1
		bra nz,2f						; branch if not

		cp0.b MsgBuffer+2
		bra nz,exit

		rcall ResetControls				; reset all controls

		mov.b Mode,wreg
		setm.b Mode
		rcall SetMode

		bra exit

2:		mov.b #LOCAL_CONTROL,w0			; local control ?
		cp.b MsgBuffer+1
		bra z,exit					; branch if yes

		mov.b #ALL_NOTES_OFF,w0			; all notes off ?
		cp.b MsgBuffer+1
		bra z,exit					; branch if yes

		cp0.b MIDIChannel				; all channels ?
		bra n,3f						; branch if yes

		mov.b MsgBuffer+0,wreg			; correct Basic Channel ?
		and.b #0x0f,w0
		cp.b MIDIChannel
		bra nz,4f						; branch if not

3:		mov.b #OMNI_MODE_OFF,w0			; adjust mode
		cp.b MsgBuffer+1
		bra nz,$+4
		bset.b MIDIMode,#1

		mov.b #OMNI_MODE_ON,w0
		cp.b MsgBuffer+1
		bra nz,$+4
		bclr.b MIDIMode,#1

		mov.b #MONO_MODE_ON,w0
		cp.b MsgBuffer+1
		bra nz,$+4
		bset.b MIDIMode,#0

		mov.b #POLY_MODE_ON,w0
		cp.b MsgBuffer+1
		bra nz,$+4
		bclr.b MIDIMode,#0

		mov.b #MONO_MODE_ON,w0			; Mono Mode on ?
		cp.b MsgBuffer+1
		bra nz,4f						; branch if not

		mov.b MsgBuffer+2,wreg			; number of channels
		mov.b wreg,MIDIGroup

4:		bra exit

5:		mov.b #NUM_CONTROLS,w0			; control ?
		cp.b MsgBuffer+1
		bra geu,exit					; branch if not

		mov.b MsgBuffer+2,wreg			; control value
		ze w0,w0
		sl w0,#5,w1					; 7 bits => 12 bits
		mov.b MsgBuffer+1,wreg			; control number
		ze w0,w0
		exch w0,w1
		rcall SetControl				; set control

		mov.b Mode,wreg
		setm.b Mode
		rcall SetMode

		bra exit

program_change:

		mov.b MsgBuffer+1,wreg			; program number
		ze w0,w0
		cp w0,#NUM_PROGRAMS
		bra gtu,$+4
		rcall SetProgram				; set program

		bra exit

exit:	mov Ticks,w0
		mov w0,MsgTicks

		pop w2
		pop w1

		return


;---------------------------------------------------------------------------
; MIDI message table (status byte, mask, length)
;---------------------------------------------------------------------------

.section .const, psv
.align 64

Messages:
	.byte NOTE_OFF,0xf0,2
	.byte NOTE_ON,0xf0,2
	.byte KEY_PRESSURE,0xf0,2
	.byte CONTROL_CHANGE,0xf0,2
	.byte PROGRAM_CHANGE,0xf0,1
	.byte CHANNEL_PRESSURE,0xf0,1
	.byte PITCH_BEND,0xf0,2
	.byte SYSTEM_EXCLUSIVE,0xff,-1
	.byte SONG_POSITION,0xff,2
	.byte SONG_SELECT,0xff,1
	.byte TUNE_REQUEST,0xff,0
	.byte EOX,0xff,0
	.byte SYSTEM_COMMON,0xf8,0
	.byte TIMING_CLOCK,0xff,0
	.byte START,0xff,0
	.byte CONTINUE,0xff,0
	.byte STOP,0xff,0
	.byte ACTIVE_SENSING,0xff,0
	.byte SYSTEM_RESET,0xff,0
	.byte SYSTEM_REAL_TIME,0xf8,0
	.byte 0,0x00,0


;---------------------------------------------------------------------------
; variables
;---------------------------------------------------------------------------

.section .nbss,bss,near
.align 2

MsgPointer:		.space 2		; message buffer pointer
MsgTicks:			.space 2		; message time
MIDIChannel:		.space 1		; MIDI Basic Channel: 0 to 15, or -1 for all (overrides MIDI mode)
MIDIGroup:		.space 1		; MIDI channel group
MIDIMode:			.space 1		; MIDI Mode (Omni on/Poly, Omni on/Mono, Omni off/Poly, Omni off/Mono)
MsgBuffer:		.space 3		; MIDI message buffer
MsgLength:		.space 1		; message length (number of data bytes)
MsgIgnore:		.space 1		; message bytes to ignore
LastStatus:		.space 1		; last received message status byte
LastLength:		.space 1		; last received message length


.end
