/***************************************************************************
* FILE:      lfo.s												*
* CONTENTS:  Low Frequency Oscillator routines						*
* COPYRIGHT: MadLab Ltd. 2012-18									*
* AUTHOR:    James Hutchby										*
* UPDATED:   14/06/18											*
***************************************************************************/

.include "p33EP128MC202.inc"
.include "common.inc"


;---------------------------------------------------------------------------
; InitLFO - initialises an LFO
;
; Entry:	w0 = pointer to LFO structure
;
; Exit: 	w0 unchanged
;
; Uses:	w1, w2, A
;---------------------------------------------------------------------------

.global InitLFO
InitLFO:

		clr.b w1						; default waveform
		setm.b w2
		mov.b w2,[w0+LFOWaveform]
		rcall SetLFOWaveform

		mov #LFO_MIN_FREQUENCY,w1		; default frequency
		rcall SetLFOFrequency

		clr w1						; null pulse width
		rcall SetLFOPulseWidth

		mov #SILENCE,w1				; zero amplitude
		rcall SetLFOAmplitude

		clr w1
		mov w1,[w0+LFOModulation]

		return


;---------------------------------------------------------------------------
; SetLFOWaveform - sets the waveform of an LFO
;
; Entry:	w0 = pointer to LFO structure
;		w1.b = waveform
;
; Exit:	w0 unchanged
;
; Uses:	w1, w2, A
;---------------------------------------------------------------------------

.global SetLFOWaveform
SetLFOWaveform:

		mov.b [w0+LFOWaveform],w2
		cp.b w1,w2
		bra z,1f

		mov.b w1,[w0+LFOWaveform]		; waveform

		clr w1						; reset offset
		mov w1,[w0+LFOOffset]

		rcall CalcLFOModulation			; calculate modulation

1:		return


;---------------------------------------------------------------------------
; SetLFOFrequency - sets the frequency of an LFO
;
; Entry:	w0 = pointer to LFO structure
; 		w1 = frequency in Hz (unsigned 8.8 fraction)
;
; Exit: 	w0 unchanged
;
; Uses:	w1, w2, A, RCOUNT
;---------------------------------------------------------------------------

.global SetLFOFrequency
SetLFOFrequency:

		mov w1,[w0+LFOFrequency]			; frequency

		push w0						; calculate waveform step
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
		mov w0,w1
		pop w0
		mov w1,[w0+LFOStep]				; ((frequency * WAVEFORM_SIZE) / LFO_RATE) << 8

		rcall CalcLFOModulation			; calculate modulation

		return


;---------------------------------------------------------------------------
; SetLFOPulseWidth - sets the pulse width of an LFO
;
; Entry:	w0 = pointer to LFO structure
; 		w1 = pulse width: 0 to 4095
;
; Exit:	w0 unchanged
;
; Uses:	w1
;---------------------------------------------------------------------------

.global SetLFOPulseWidth
SetLFOPulseWidth:

		sl w1,#4,w1
		mov w1,[w0+LFOPulseWidth]

		return


;---------------------------------------------------------------------------
; SetLFOAmplitude - sets the amplitude of an LFO
;
; Entry:	w0 = pointer to LFO structure
; 		w1 = amplitude (unsigned 1.15 fraction)
;
; Exit: 	w0 unchanged
;
; Uses:	w1, w2, A
;---------------------------------------------------------------------------

.global SetLFOAmplitude
SetLFOAmplitude:

		mov w1,[w0+LFOAmplitude]			; amplitude

		rcall CalcLFOModulation			; calculate modulation

		return


;---------------------------------------------------------------------------
; StepLFOs - steps the LFOs for a DCO
;
; Entry:	w0 = pointer to DCO structure
;
; Exit: 	w0 unchanged
;
; Uses:	w1, w2, A
;---------------------------------------------------------------------------

.global StepLFOs
StepLFOs:

		push w0						; advance amplitude LFO offset
		mov #DCOAmpLFO,w1
		add w0,w1,w0
		mov [w0+LFOStep],w1
		mov [w0+LFOOffset],w2
		add w1,w2,w2
;		bra nc,$+4
;		clr w2
		mov w2,[w0+LFOOffset]
		rcall CalcLFOModulation
		pop w0

		push w0						; advance frequency LFO offset
		mov #DCOFreqLFO,w1
		add w0,w1,w0
		mov [w0+LFOStep],w1
		mov [w0+LFOOffset],w2
		add w1,w2,w2
;		bra nc,$+4
;		clr w2
		mov w2,[w0+LFOOffset]
		rcall CalcLFOModulation
		pop w0

		return


;---------------------------------------------------------------------------
; CalcLFOModulation - calculates the (output) modulation of an LFO
;
; Entry:	w0 = pointer to LFO structure
;
; Exit: 	w0 unchanged
;
; Uses:	w1, w2, A
;---------------------------------------------------------------------------

.global CalcLFOModulation
CalcLFOModulation:

		push w0
		push w3

		mov w0,w3

		mov [w3+LFOOffset],w2

		mov #tbloffset(vectors),w0
		mov.b [w3+LFOWaveform],w1
		ze w1,w1
		sl w1,w1
		add w1,w0,w1
		tblrdl [w1],w1
		call w1

		mov [w3+LFOAmplitude],w0			; scale by amplitude
		mul.us w0,w1,w0
		sl w0,w0
		rlc w1,w1
		btsc w0,#15					; round
		inc w1,w1

;**		mov [w3+LFOStep],w0
;**		cp0 w0
;**		bra nz,$+4
;**		clr w1

		mov w1,[w3+LFOModulation]		; cache result

		pop w3
		pop w0

		return


sine:
		push.d w4
		push CORCON

		bset CORCON,#IF				; integer mode

		mov #psvoffset(SineDelta),w1		; pointer to sine waveform

		lsr w2,#8,w5					; get waveform sample and delta
		sl w5,#2,w5
		lac [w1+w5],#4,A
		inc2 w5,w5
		mov [w1+w5],w5

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
		add w2,w2,w1
		bra nov,$+4
		com w1,w1

		return

sawtooth1:
		mov w2,w1						; rising

		return

sawtooth2:
		neg w2,w1						; falling

		return

pulse:
		mov [w3+LFOPulseWidth],w1
		cp w2,w1
		mov #0x7fff,w1
		bra ltu,$+4
		mov #0x8000,w1

		return

noise:
		rcall GetRandom

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


.end
