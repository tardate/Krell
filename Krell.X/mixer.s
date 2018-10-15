/***************************************************************************
* FILE:      mixer.s											*
* CONTENTS:  Mixer routines										*
* COPYRIGHT: MadLab Ltd. 2012-18									*
* AUTHOR:    James Hutchby										*
* UPDATED:   11/07/18											*
***************************************************************************/

.include "p33EP128MC202.inc"
.include "common.inc"


.section .text

;---------------------------------------------------------------------------
; InitMixer - initialises the mixer
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

.global InitMixer
InitMixer:

		mov #0b0000000000010000,w0		; initialise Timer2 - internal clock,
		mov w0,T2CON					; prescale 1:8

		clr TMR2

		mov #(CLOCK/2)/8/LFO_RATE,w0
		mov w0,PR2

		bset IPC1,#T2IP2				; interrupt priority = 4
		bclr IPC1,#T2IP1
		bclr IPC1,#T2IP0

		bclr IFS0,#T2IF				; enable timer interrupt
		bset IEC0,#T2IE

		bset T2CON,#TON				; timer on

		return


;---------------------------------------------------------------------------
; Timer #2 isr
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	-
;---------------------------------------------------------------------------

.global __T2Interrupt
__T2Interrupt:

		push.d w0
		push.d w2
		push ACCAU
		push ACCAH
		push ACCAL
		push RCOUNT

		mov.b #0,w0					; step all LFOs
1:		push w0
		rcall GetDCO
		rcall StepLFOs
		rcall CalcDCOModStep
		rcall CalcDCOModAmplitude
		pop w0
		inc.b w0,w0
		cp.b w0,#NUM_DCOS
		bra ltu,1b

		rcall StepReverbLFO				; step reverb period LFO

		rcall StepFlanger				; step flanger
		rcall CalcFlanger

		bclr IFS0,#T2IF				; clear interrupt

		pop RCOUNT
		pop ACCAL
		pop ACCAH
		pop ACCAU
		pop.d w2
		pop.d w0

		retfie


;---------------------------------------------------------------------------
; GetMixerOutput - gets the mixer output
;
; Entry:	-
;
; Exit: 	w0 = mixer output
;
; Uses:	w1 - w3, A, B
;---------------------------------------------------------------------------

.global GetMixerOutput
GetMixerOutput:

		push.d w4
		push.d w6
		push CORCON

		bclr CORCON,#IF				; fractional mode

		clr A

dco_01:

		btsc SysFlags,#RING_MODULATION_01	; ring modulation enabled ?
		bra ring_mod_01				; branch if yes

		btsc SysFlags,#FREQ_MODULATION_01	; frequency modulation enabled ?
		bra freq_mod_01				; branch if yes

		mov #0,w0
		rcall GetDCO

		rcall GetNextSample				; get sample
		mov w1,w6

		mov [w0+DCOModAmplitude],w7		; modulated amplitude

		btsc w7,#15					; apply amplification
		add w6,#0,A
		btss w7,#15
		mac w6*w7,A

		mov #1,w0
		rcall GetDCO

		rcall GetNextSample				; get sample
		mov w1,w6

		mov [w0+DCOModAmplitude],w7		; modulated amplitude

		btsc w7,#15					; apply amplification
		add w6,#0,A
		btss w7,#15
		mac w6*w7,A

		bra dco_23

ring_mod_01:

		mov #0,w0
		rcall GetDCO

		rcall GetNextSample				; get sample

		mov [w0+DCOModAmplitude],w2		; modulated amplitude

		btsc w2,#15					; apply amplification
		mov #0x8000,w2
		mul.su w1,w2,w2
		sl w2,w2
		rlc w3,w6
		btsc w2,#15					; round
		inc w6,w6

		mov #1,w0
		rcall GetDCO

		rcall GetNextSample				; get sample

		mov [w0+DCOModAmplitude],w2		; modulated amplitude

		btsc w2,#15					; apply amplification
		mov #0x8000,w2
		mul.su w1,w2,w2
		sl w2,w2
		rlc w3,w7
		btsc w2,#15					; round
		inc w7,w7

		mac w6*w7,A					; ring modulation
		mac w6*w7,A
		mac w6*w7,A
		mac w6*w7,A

		bra dco_23

freq_mod_01:

		mov #0,w0
		rcall GetDCO

		rcall GetNextSample				; get sample

		mov [w0+DCOModAmplitude],w2		; modulated amplitude

		btsc w2,#15					; apply amplification
		mov #0x8000,w2
		mul.su w1,w2,w2
		sl w2,w2
		rlc w3,w6
		btsc w2,#15					; round
		inc w6,w6

		mov #1,w0
		rcall GetDCO

		mov [w0+DCOStep],w1				; modulate step
		add w6,w1,w1
		mov w1,[w0+DCOModStep]

		rcall GetNextSample				; get sample

		mov [w0+DCOModAmplitude],w2		; modulated amplitude

		btsc w2,#15					; apply amplification
		mov #0x8000,w2
		mul.su w1,w2,w2
		sl w2,w2
		rlc w3,w6
		btsc w2,#15					; round
		inc w6,w6

		add w6,#0,A

dco_23:

		btsc SysFlags,#RING_MODULATION_23	; ring modulation enabled ?
		bra ring_mod_23				; branch if yes

		btsc SysFlags,#FREQ_MODULATION_23	; frequency modulation enabled ?
		bra freq_mod_23				; branch if yes

		mov #2,w0
		rcall GetDCO

		rcall GetNextSample				; get sample
		mov w1,w6

		mov [w0+DCOModAmplitude],w7		; modulated amplitude

		btsc w7,#15					; apply amplification
		add w6,#0,A
		btss w7,#15
		mac w6*w7,A

		mov #3,w0
		rcall GetDCO

		rcall GetNextSample				; get sample
		mov w1,w6

		mov [w0+DCOModAmplitude],w7		; modulated amplitude

		btsc w7,#15					; apply amplification
		add w6,#0,A
		btss w7,#15
		mac w6*w7,A

		bra get_output

ring_mod_23:

		mov #2,w0
		rcall GetDCO

		rcall GetNextSample				; get sample

		mov [w0+DCOModAmplitude],w2		; modulated amplitude

		btsc w2,#15					; apply amplification
		mov #0x8000,w2
		mul.su w1,w2,w2
		sl w2,w2
		rlc w3,w6
		btsc w2,#15					; round
		inc w6,w6

		mov #3,w0
		rcall GetDCO

		rcall GetNextSample				; get sample

		mov [w0+DCOModAmplitude],w2		; modulated amplitude

		btsc w2,#15					; apply amplification
		mov #0x8000,w2
		mul.su w1,w2,w2
		sl w2,w2
		rlc w3,w7
		btsc w2,#15					; round
		inc w7,w7

		mac w6*w7,A					; ring modulation
		mac w6*w7,A
		mac w6*w7,A
		mac w6*w7,A

		bra get_output

freq_mod_23:

		mov #2,w0
		rcall GetDCO

		rcall GetNextSample				; get sample

		mov [w0+DCOModAmplitude],w2		; modulated amplitude

		btsc w2,#15					; apply amplification
		mov #0x8000,w2
		mul.su w1,w2,w2
		sl w2,w2
		rlc w3,w6
		btsc w2,#15					; round
		inc w6,w6

		mov #3,w0
		rcall GetDCO

		mov [w0+DCOStep],w1				; modulate step
		add w6,w1,w1
		mov w1,[w0+DCOModStep]

		rcall GetNextSample				; get sample

		mov [w0+DCOModAmplitude],w2		; modulated amplitude

		btsc w2,#15					; apply amplification
		mov #0x8000,w2
		mul.su w1,w2,w2
		sl w2,w2
		rlc w3,w6
		btsc w2,#15					; round
		inc w6,w6

		add w6,#0,A

get_output:

		sac.r A,#4,w6					; master volume control
 		mov #psvoffset(VolumeTable),w7
		mov MasterVolume,w0
		mov #MIN_MASTER_VOLUME,w1
		sub w0,w1,w0
		sl w0,w0
		mov [w7+w0],w7
		bset CORCON,#IF
		mpy w6*w7,A
		sac.r A,#-8,w0

		rcall DoFlanger

		rcall DoReverb

		rcall DoFuzz

		pop CORCON
		pop.d w6
		pop.d w4

		return


;---------------------------------------------------------------------------
; SetFuzzLevel - sets the fuzz level
;
; Entry:	w0 = fuzz level: 0 to 4095
;
; Exit:	-
;
; Uses:	w0, w1
;---------------------------------------------------------------------------

.global SetFuzzLevel
SetFuzzLevel:

		sl w0,#3,w0					; scale
		mov #FUZZ_MIN-FUZZ_MAX,w1
		mul.uu w0,w1,w0
		sl w0,w0
		rlc w1,w1
		mov #FUZZ_MIN,w0
		sub w0,w1,w0
		mov w0,FuzzLevel

		return


;---------------------------------------------------------------------------
; DoFuzz - fuzz
;
; Entry:	w0 = mixer output
;
; Exit: 	w0 = modified output
;
; Uses:	w1
;---------------------------------------------------------------------------

.global DoFuzz
DoFuzz:

		mov w0,w1

		mov FuzzLevel,wreg				; clip +ve
		cp w1,w0
		bra lt,$+4
		mov w0,w1

		neg FuzzLevel,wreg				; clip -ve
		cp w1,w0
		bra gt,$+4
		mov w0,w1

		mov w1,w0

		return


;---------------------------------------------------------------------------
; master volume table (2^(8+volume/4))
;---------------------------------------------------------------------------

.section .const, psv
.align 64

.if DAC_AUDIO
.equ scale, 1
.endif
.if PWM_AUDIO
.equ scale, 2
.endif

VolumeTable:
	.word 0x0100*scale
	.word 0x0130*scale
	.word 0x016A*scale
	.word 0x01AE*scale
	.word 0x0200*scale
	.word 0x0260*scale
	.word 0x02D4*scale
	.word 0x035D*scale
	.word 0x0400*scale
	.word 0x04C1*scale
	.word 0x05A8*scale
	.word 0x06BA*scale
	.word 0x0800*scale
	.word 0x0983*scale
	.word 0x0B50*scale
	.word 0x0D74*scale
	.word 0x1000*scale


;---------------------------------------------------------------------------
; variables
;---------------------------------------------------------------------------

.section .ndata,data,near
.align 2

.global FuzzLevel
FuzzLevel:	.word FUZZ_MIN			; fuzz level


.end
