/***************************************************************************
* FILE:      flanger.s											*
* CONTENTS:  Flanger routines										*
* COPYRIGHT: MadLab Ltd. 2012-18									*
* AUTHOR:    James Hutchby										*
* UPDATED:   14/06/18											*
***************************************************************************/

.include "p33EP128MC202.inc"
.include "common.inc"


; delay line size in words
.equ DELAY_LINE_SIZE, 500

; frequency limits
.equ FLANGER_MIN_FREQUENCY, LFO_MIN_FREQUENCY
.equ FLANGER_MAX_FREQUENCY, LFO_MAX_FREQUENCY

; amplitude limits
.equ FLANGER_MIN_AMPLITUDE, 0
.equ FLANGER_MAX_AMPLITUDE, DELAY_LINE_SIZE-1


.section .text

;---------------------------------------------------------------------------
; InitFlanger - initialises the flanger
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0 - w2, A, RCOUNT
;---------------------------------------------------------------------------

.global InitFlanger
InitFlanger:

		mov #DelayLine,w0				; initialise modulo addressing
		mov w0,XMODSRT					; using w10
		add #DELAY_LINE_SIZE*2-1,w0
		mov w0,XMODEND
		mov #0x8ff0|10,w0
		mov w0,MODCON

		mov #DelayLine,w0				; initialise pointers
		mov w0,FlangerReadPnt
		mov w0,FlangerWritePnt

		repeat #DELAY_LINE_SIZE-1		; clear delay line
		clr [w0++]

		clr.b w0						; default waveform
		setm.b FlangerWaveform
		rcall SetFlangerWaveform

		mov #FLANGER_MIN_FREQUENCY,w0		; default frequency
		rcall SetFlangerFrequency

		clr w0						; null pulse width
		rcall SetFlangerPulseWidth

		clr w0						; zero amplitude
		rcall SetFlangerAmplitude

		clr w0						; zero base level
		rcall SetFlangerBase

		clr FlangerLevel				; no flanging

		return


;---------------------------------------------------------------------------
; SetFlangerWaveform - sets the waveform of the flanger
;
; Entry:	w0.b = waveform
;
; Exit:	-
;
; Uses:	w0 - w2, A
;---------------------------------------------------------------------------

.global SetFlangerWaveform
SetFlangerWaveform:

		cp.b FlangerWaveform
		bra z,1f

		mov.b wreg,FlangerWaveform		; waveform

		clr FlangerOffset				; reset offset

		rcall CalcFlanger

1:		return


;---------------------------------------------------------------------------
; SetFlangerFrequency - sets the frequency of the flanger
;
; Entry:	w0 = frequency in Hz (unsigned 8.8 fraction)
;
; Exit: 	-
;
; Uses:	w0 - w2, A, RCOUNT
;---------------------------------------------------------------------------

.global SetFlangerFrequency
SetFlangerFrequency:

		mov w0,FlangerFrequency			; frequency

		mov w0,w1						; calculate waveform step
		clr w0
		.rept 8
		lsr w1,w1
		rrc w0,w0
		.endr
		mov #LFO_RATE/2,w2
		add w0,w2,w0
		bra nc,$+4
		inc w1,w1
		mov #LFO_RATE,w2
		repeat #17
		div.ud w0,w2
		mov w0,FlangerStep				; ((frequency * WAVEFORM_SIZE) / LFO_RATE) << 8

		rcall CalcFlanger

		return


;---------------------------------------------------------------------------
; SetFlangerPulseWidth - sets the pulse width of the flanger
;
; Entry:	w0 = pulse width: 0 to 4095
;
; Exit:	-
;
; Uses:	w0
;---------------------------------------------------------------------------

.global SetFlangerPulseWidth
SetFlangerPulseWidth:

		sl w0,#4,w0
		mov w0,FlangerPulseWidth

		return


;---------------------------------------------------------------------------
; SetFlangerAmplitude - sets the amplitude of the flanger
;
; Entry:	w0 = amplitude (unsigned 1.15 fraction)
;
; Exit: 	-
;
; Uses:	w0 - w2, A
;---------------------------------------------------------------------------

.global SetFlangerAmplitude
SetFlangerAmplitude:

		mov #FLANGER_MAX_AMPLITUDE,w1		; scale
		mul.uu w0,w1,w0
		sl w0,w0
		rlc w1,w1

		mov w1,FlangerAmplitude			; amplitude

		rcall CalcFlanger

		return


;---------------------------------------------------------------------------
; SetFlangerBase - sets the base level of the flanger
;
; Entry:	w0 = base level (unsigned 1.15 fraction)
;
; Exit: 	-
;
; Uses:	w0 - w2, A
;---------------------------------------------------------------------------

.global SetFlangerBase
SetFlangerBase:

		mov #FLANGER_MAX_AMPLITUDE,w1		; scale
		mul.uu w0,w1,w0
		sl w0,w0
		rlc w1,w1

		mov w1,FlangerBase				; base level

		rcall CalcFlanger

		return


;---------------------------------------------------------------------------
; DoFlanger - flanging
;
; Entry:	w0 = mixer output
;
; Exit: 	w0 = modified output
;
; Uses:	w1 - w4, w10
;---------------------------------------------------------------------------

.global DoFlanger
DoFlanger:

		mov FlangerAmplitude,w1			; enabled ?
		mov FlangerBase,w2
		ior w1,w2,w1
		bra z,2f						; branch if not

		mov FlangerWritePnt,w10			; store output in delay line
		mov w0,[w10++]
		mov w10,FlangerWritePnt

		mov FlangerReadPnt,w10

		mov [w10],w1					; delayed output

		mov FlangerWritePnt,w2			; calculate length of delay
		sub w2,w10,w2
		bra gtu,$+4
		add #DELAY_LINE_SIZE*2,w2
		lsr w2,w2

		mov FlangerLevel,w3				; current flanging level

		cp w2,w3						; increase delay ?
		bra leu,1f					; branch if yes

		mov [w10++],w4					; dummy read
		dec w2,w2

		cp w2,w3						; decrease delay ?
		bra leu,1f					; branch if not

		mov [w10++],w4					; dummy read

1:		mov w10,FlangerReadPnt

		add w0,w1,w0

2:		return


;---------------------------------------------------------------------------
; StepFlanger - steps the flanger
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0, w1
;---------------------------------------------------------------------------

.global StepFlanger
StepFlanger:

		mov FlangerStep,w0				; advance waveform offset
		mov FlangerOffset,w1
		add w0,w1,w0
		mov w0,FlangerOffset

		return


;---------------------------------------------------------------------------
; CalcFlanger - calculates the flanger level
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0 - w2, A
;---------------------------------------------------------------------------

.global CalcFlanger
CalcFlanger:

		mov FlangerOffset,w2

		mov.b FlangerWaveform,wreg
		mov #tbloffset(vectors),w1
		ze w0,w0
		sl w0,w0
		add w0,w1,w0
		tblrdl [w0],w0
		call w0

		asr w1,w1
		mov #0x4000,w2
		add w1,w2,w1

		mov FlangerAmplitude,w2			; scale by amplitude
		mul.uu w2,w1,w0
		sl w0,w0
		rlc w1,w1
		mov w1,w0

		mov FlangerBase,w2				; add base level
		add w0,w2,w0

		mov #FLANGER_MAX_AMPLITUDE,w2		; check against upper limit
		cp w0,w2
		bra leu,$+4
		mov w2,w0

		mov w0,FlangerLevel

		return

sine:
		push.d w4
		push CORCON

		bset CORCON,#IF				; integer mode

;		mov #0x4000,w1
;		sub w2,w1,w2

		mov #psvoffset(SineDelta),w1		; pointer to sine waveform

		lsr w2,#8,w4					; get waveform sample and delta
		sl w4,#2,w4
		lac [w1+w4],#4,A
		inc2 w4,w4
		mov [w1+w4],w5

		sl w2,#8,w4					; linear interpolation between samples
		lsr w4,#4,w4
		mac w4*w5,A					; a + (b - a) * fract / 256

		sac.r A,#-4,w1					; round result

		pop CORCON
		pop.d w4

		return

square:
		mov #0x7fff,w1
		btss w2,#15
		mov #0x8000,w1

		return

triangle:
		mov #0x4000,w1
		sub w2,w1,w2

		add w2,w2,w1
		bra nov,$+4
		com w1,w1

		return

sawtooth1:
		mov w2,w1						; rising

		btg w1,#15

		return

sawtooth2:
		neg w2,w1						; falling

		btg w1,#15

		return

pulse:
		mov FlangerPulseWidth,w1
		cp w2,w1
		mov #0x7fff,w1
		bra ltu,$+4
		mov #0x8000,w1

		return

noise:
		rcall GetRandom
		asr w0,#2,w1

		return

.align 2
vectors:
	.word handle(sine)
	.word handle(square)
	.word handle(triangle)
	.word handle(sawtooth1)
	.word handle(sawtooth2)
	.word handle(pulse)
	.word handle(noise)


;---------------------------------------------------------------------------
; variables
;---------------------------------------------------------------------------

.section .nbss,bss,near
.align 2

FlangerAmplitude:	.space 2			; amplitude
FlangerBase:		.space 2			; base level
FlangerFrequency:	.space 2			; frequency in Hz (unsigned 8.8)
FlangerPulseWidth:	.space 2			; pulse width
FlangerLevel:		.space 2			; current level
FlangerOffset:		.space 2			; waveform offset
FlangerStep:		.space 2			; waveform step
FlangerWritePnt:	.space 2			; delay line write pointer
FlangerReadPnt:	.space 2			; delay line read pointer
FlangerWaveform:	.space 1			; waveform


.section .bss,bss
.align 1024

; flanger delay line (circular buffer)
DelayLine:		.space DELAY_LINE_SIZE*2


.end
