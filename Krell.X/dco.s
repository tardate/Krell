/***************************************************************************
* FILE:      dco.s												*
* CONTENTS:  Digitally Controlled Oscillator routines					*
* COPYRIGHT: MadLab Ltd. 2012-18									*
* AUTHOR:    James Hutchby										*
* UPDATED:   14/06/18											*
***************************************************************************/

.include "p33EP128MC202.inc"
.include "common.inc"


.section .text

;---------------------------------------------------------------------------
; GetDCO - gets a pointer to a DCO
;
; Entry:	w0.b = DCO index: 0 onwards
;
; Exit:	w0 = pointer to DCO structure
;
; Uses:	-
;---------------------------------------------------------------------------

.global GetDCO
GetDCO:

		push w1

		mov #DCOSizeof,w1
		ze w0,w0
		mul.uu w0,w1,w0
		mov #DCOs,w1
		add w0,w1,w0

		pop w1

		return


;---------------------------------------------------------------------------
; InitDCO - initialises a DCO
;
; Entry:	w0 = pointer to DCO structure
;
; Exit:	w0 unchanged
;
; Uses:	w1, w2, A
;---------------------------------------------------------------------------

.global InitDCO
InitDCO:

		clr.b w1						; clear flags
		mov.b w1,[w0+DCOFlags]

		push w0						; initialise amplitude LFO
		mov #DCOAmpLFO,w1
		add w0,w1,w0
		rcall InitLFO
		pop w0

		push w0						; initialise frequency LFO
		mov #DCOFreqLFO,w1
		add w0,w1,w0
		rcall InitLFO
		pop w0

		clr.b w1						; default waveform
		setm.b w2
		mov.b w2,[w0+DCOWaveform]
		rcall SetDCOWaveform

		mov #LO_FREQUENCY,w1			; default frequency
		rcall SetDCOFrequency

		clr w1						; null pulse width
		rcall SetDCOPulseWidth

		mov #SILENCE,w1				; no output
		rcall SetDCOAmplitude

		clr w1						; reset quiescent timer
		mov w1,[w0+DCOTimer]

		return


;---------------------------------------------------------------------------
; SetDCOWaveform - sets the waveform of a DCO
;
; Entry:	w0 = pointer to DCO structure
;		w1.b = waveform
;
; Exit:	w0 unchanged
;
; Uses:	w1, w2
;---------------------------------------------------------------------------

.global SetDCOWaveform
SetDCOWaveform:

		mov.b [w0+DCOWaveform],w2
		cp.b w1,w2
		bra z,1f

		mov.b w1,[w0+DCOWaveform]		; waveform

		rcall LockDCO					; frequency lock

		mov #tbloffset(vectors),w2		; function pointer
		ze w1,w1
		sl w1,w1
		add w1,w2,w1
		tblrdl [w1],w1
		mov w1,[w0+DCOFunctionPnt]

		clr w1						; reset offset
		mov w1,[w0+DCOOffset]

1:		return


;---------------------------------------------------------------------------
; LockDCO - frequency locks a DCO
;
; Entry:	w0 = pointer to DCO structure
;
; Exit:	w0 unchanged
;
; Uses:	-
;---------------------------------------------------------------------------

.global LockDCO
LockDCO:

		push w1

		mov.b [w0+DCOWaveform],w1		; frequency lock waveforms with
		cp.b w1,#WAVEFORM_SINE			; sharp edges
		bra z,1f
		cp.b w1,#WAVEFORM_TRIANGLE
		bra z,1f

		bset.b [w0],#DCO_LOCK_FREQ

		bra 2f

1:		bclr.b [w0],#DCO_LOCK_FREQ

2:		pop w1

		return


;---------------------------------------------------------------------------
; UnlockDCO - frequency unlocks a DCO
;
; Entry:	w0 = pointer to DCO structure
;
; Exit:	w0 unchanged
;
; Uses:	-
;---------------------------------------------------------------------------

.global UnlockDCO
UnlockDCO:

		bclr.b [w0],#DCO_LOCK_FREQ

		return


;---------------------------------------------------------------------------
; SetDCOFrequency - sets the frequency of a DCO
;
; Entry:	w0 = pointer to DCO structure
; 		w1 = frequency in Hz
;
; Exit:	w0 unchanged
;
; Uses:	w1, RCOUNT
;---------------------------------------------------------------------------

.global SetDCOFrequency
SetDCOFrequency:

		push w2

		mov #HI_FREQUENCY,w2			; check against Nyquist limit
		cp w1,w2
		bra leu,$+4
		mov w2,w1

		mov w1,[w0+DCOFrequency]			; frequency

		push w0						; calculate waveform step
		clr w0
		.rept 3
		lsr w1,w1
		rrc w0,w0
		.endr
		mov #(SAMPLE_RATE>>3)/2,w2
		add w0,w2,w0
		bra nc,$+4
		inc w1,w1
		mov #SAMPLE_RATE>>3,w2
		repeat #17
		div.ud w0,w2
		mov w0,w1
		pop w0
		mov w1,[w0+DCOStep]				; ((frequency * WAVEFORM_SIZE) / SAMPLE_RATE) << 8

		rcall CalcDCOModStep			; calculate modulated step

		btss SysFlags,#ADDITIVE_SYNTHESIS
		bra 1f

		mov #DCOs,w2					; fundamental ?
		cp w0,w2
		bra nz,1f						; branch if not

		mov [w0+DCOFrequency],w2			; harmonic #1 = 2 x fundamental
		add w2,w2,w1
		push w0
		mov #DCOSizeof*1,w2
		add w0,w2,w0
		rcall SetDCOFrequency
		pop w0

		mov [w0+DCOFrequency],w2			; harmonic #2 = 3 x fundamental
		add w2,w2,w1
		add w2,w1,w1
		push w0
		mov #DCOSizeof*2,w2
		add w0,w2,w0
		rcall SetDCOFrequency
		pop w0

		mov [w0+DCOFrequency],w2			; harmonic #3 = 4 x fundamental
		add w2,w2,w1
		add w1,w1,w1
		push w0
		mov #DCOSizeof*3,w2
		add w0,w2,w0
		rcall SetDCOFrequency
		pop w0

1:		pop w2

		return


;---------------------------------------------------------------------------
; SetDCOPulseWidth - sets the pulse width of a DCO
;
; Entry:	w0 = pointer to DCO structure
; 		w1 = pulse width: 0 to 4095
;
; Exit:	w0 unchanged
;
; Uses:	w1
;---------------------------------------------------------------------------

.global SetDCOPulseWidth
SetDCOPulseWidth:

		sl w1,#4,w1
		mov w1,[w0+DCOPulseWidth]

		return


;---------------------------------------------------------------------------
; CalcDCOModStep - calculates the modulated step of a DCO
;
; Entry:	w0 = pointer to DCO structure
;
; Exit:	w0 unchanged
;
; Uses:	-
;---------------------------------------------------------------------------

.global CalcDCOModStep
CalcDCOModStep:

.equ MIN_STEP, ((LO_FREQUENCY*WAVEFORM_SIZE)<<8)/SAMPLE_RATE
.equ MAX_STEP, ((HI_FREQUENCY*WAVEFORM_SIZE)<<8)/SAMPLE_RATE

		push w1
		push w2

		mov #DCOFreqLFO,w2				; frequency modulation
		add w0,w2,w2
		mov [w2+LFOModulation],w2

		asr w2,#4,w2

		mov [w0+DCOStep],w1				; step

		btsc w2,#15
		bra 1f

		add w2,w1,w1					; +ve
		mov #MAX_STEP,w2
		bra nc,$+4
		mov w2,w1

		cp w1,w2
		bra leu,$+4
		mov w2,w1

		bra 2f

1:		add w2,w1,w1					; -ve
		mov #MIN_STEP,w2
		bra c,$+4
		mov w2,w1

		cp w1,w2
		bra geu,$+4
		mov w2,w1

2:		mov w1,[w0+DCOModStep]			; cache result

		pop w2
		pop w1

		return


;---------------------------------------------------------------------------
; SetDCOAmplitude - sets the amplitude of a DCO
;
; Entry:	w0 = pointer to DCO structure
;		w1 = amplitude (unsigned 1.15 fraction)
;
; Exit:	w0 unchanged
;
; Uses:	w1
;---------------------------------------------------------------------------

.global SetDCOAmplitude
SetDCOAmplitude:

		mov w1,[w0+DCOAmplitude]			; amplitude

		rcall CalcDCOModAmplitude		; calculate modulated amplitude

		return


;---------------------------------------------------------------------------
; CalcDCOModAmplitude - calculates the modulated amplitude of a DCO
;
; Entry:	w0 = pointer to DCO structure
;
; Exit:	w0 unchanged
;
; Uses:	-
;---------------------------------------------------------------------------

.global CalcDCOModAmplitude
CalcDCOModAmplitude:

		push.d w2

		add w0,#DCOAmpLFO,w2			; amplitude modulation
		mov [w2+LFOModulation],w2

		mov [w0+DCOAmplitude],w3			; amplitude

		btg w2,#15					; (1 + modulation) * amplitude
		mul.uu w2,w3,w2
		sl w2,w2
		rlc w3,w3
		btsc w2,#15					; round
		inc w3,w3

		btsc w3,#15
		mov #MAX_AMPLITUDE,w3

		mov w3,[w0+DCOModAmplitude]		; cache result

		pop.d w2

		return


;---------------------------------------------------------------------------
; GetNextSample - gets the next sample
;
; Entry:	w0 = pointer to DCO structure
;
; Exit: 	w0 unchanged
;		w1 = sample
;
; Uses:	w2 - w5, B
;---------------------------------------------------------------------------

.global GetNextSample
GetNextSample:

		mov [w0+DCOOffset],w2

		mov [w0+DCOFunctionPnt],w1
		call w1

		mov #DCOFreqLFO,w4
		add w0,w4,w4
		mov [w4+LFOModulation],w4

		mov [w0+DCOModStep],w3			; advance offset
		add w2,w3,w2

		mov.b [w0+DCOFlags],w3			; quantise frequency if locked
		btss w3,#DCO_LOCK_FREQ
		bclr SR,#C
		mov WREG4
		bra z,$+4
		bclr SR,#C
		bra nc,$+4
		clr w2

1:		mov w2,[w0+DCOOffset]

		return


sine:
		push CORCON

		bset CORCON,#IF				; integer mode

		mov #psvoffset(SineDelta),w1		; pointer to sine waveform

		lsr w2,#8,w5					; get waveform sample and delta
		sl w5,#2,w5
		lac [w1+w5],#4,B
		inc2 w5,w5
		mov [w1+w5],w5

		sl w2,#8,w4					; linear interpolation between samples
		lsr w4,#4,w4
		mac w4*w5,B					; a + (b - a) * fract / 256

		sac.r B,#-4,w1					; round result

		pop CORCON

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
		mov [w0+DCOPulseWidth],w1
		cp w2,w1
		mov #0x7fff,w1
		bra ltu,$+4
		mov #0x8000,w1

		return

noise:
		exch w0,w1
		rcall GetRandom
		exch w0,w1

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
; GetRandom - generates a pseudo random number
;
; Entry:	-
;
; Exit:	w0 = 16-bit random number
;
; Uses:	-
;---------------------------------------------------------------------------

.global GetRandom
GetRandom:

		cp0 Rand
		bra nz,1f

		mov TMR1,w0					; seed generator
		xor #0x00ff,w0
		mov w0,Rand

1:		sl Rand,wreg					; calculate next in sequence
		xor Rand,wreg
		btsc Rand,#12
		btg w0,#15
		btsc Rand,#3
		btg w0,#15					; msb = Q15 ^ Q14 ^ Q12 ^ Q3

		sl w0,w0
		rlc Rand						; << 1 + (Q15 ^ Q14 ^ Q12 ^ Q3)

		mov Rand,w0

		return


;---------------------------------------------------------------------------
; variables
;---------------------------------------------------------------------------

.section .ndata,data,near
.align 2

.global Rand
Rand:	.word 0				; random number

.section .nbss,bss,near
.align 2

; DCO structures
DCOs:	.space NUM_DCOS*DCOSizeof


.end
