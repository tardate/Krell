/***************************************************************************
* FILE:      reverb.s											*
* CONTENTS:  Reverb routines										*
* COPYRIGHT: MadLab Ltd. 2012-18									*
* AUTHOR:    James Hutchby										*
* UPDATED:   13/07/18											*
***************************************************************************/

.include "p33EP128MC202.inc"
.include "common.inc"


; reverb buffer size in bytes
.equ REVERB_BUFFER_SIZE, 0x3400


.section .text

;---------------------------------------------------------------------------
; InitReverb - initialises reverb
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0 - w2, A, RCOUNT
;---------------------------------------------------------------------------

.global InitReverb
InitReverb:

		mov #ReverbBuffer,w0			; initialise pointers
		mov w0,ReverbReadPnt
		mov w0,ReverbWritePnt
		inc ReverbWritePnt

		clr ReverbLevel				; reverb off

		clr.b ReverbByte				; reset byte flag

		repeat #REVERB_BUFFER_SIZE-1		; clear reverb buffer
		clr.b [w0++]

		mov #ReverbLFO,w0				; initialise period LFO
		rcall InitLFO

		return


;---------------------------------------------------------------------------
; SetReverbPeriod - sets the reverb period
;
; Entry:	w0 = reverb period: 0 to 4095
;
; Exit:	-
;
; Uses:	w0, w1
;---------------------------------------------------------------------------

.global SetReverbPeriod
SetReverbPeriod:

		sl w0,#3,w0
		mov #REVERB_BUFFER_SIZE-1,w1
		mul.uu w0,w1,w0
		sl w0,w0
		rlc w1,w1
		inc w1,w1

		mov ReverbWritePnt,w0
		sub w0,w1,w0
		mov #ReverbBuffer,w1
		cp w0,w1
		mov #REVERB_BUFFER_SIZE,w1
		bra ge,$+4
		add w0,w1,w0
		mov w0,ReverbReadPnt

		return


;---------------------------------------------------------------------------
; SetReverbLevel - sets the reverb level
;
; Entry:	w0 = reverb level: 0 to 4095
;
; Exit:	-
;
; Uses:	w0
;---------------------------------------------------------------------------

.global SetReverbLevel
SetReverbLevel:

		sl w0,#3,w0
		mov w0,ReverbLevel

		return


;---------------------------------------------------------------------------
; DoReverb - reverb
;
; Entry:	w0 = mixer output
;
; Exit: 	w0 = modified output
;
; Uses:	w1 - w5, A
;---------------------------------------------------------------------------

.global DoReverb
DoReverb:

		push CORCON

		bclr CORCON,#IF				; fractional mode

		mov w0,w1

		mov #ReverbBuffer+REVERB_BUFFER_SIZE,w3

		mov ReverbReadPnt,w2

		mov w2,w4
		mov ReverbLFO+LFOModulation,w5
		asr w5,#2,w5
		add w4,w5,w4
		mov #ReverbBuffer,w5
		cp w4,w5
		mov #REVERB_BUFFER_SIZE,w5
		bra geu,$+4
		add w4,w5,w4
		cp w4,w3
		bra ltu,$+4
		sub w4,w5,w4

		mov.b [w4],w4					; delayed output

		cp0.b ReverbByte
		bra nz,1f

		sl w4,#8,w4

		lac w0,#0,A
		mov ReverbLevel,w5
		mac w4*w5,A
		sac.r A,#0,w0

		btsc SysFlags,#DELAY_FEEDBACK
		mov w0,w1

		mov ReverbWritePnt,w2

		asr w1,#8,w1

		mov.b w1,[w2]					; store output in reverb buffer

		bra 2f

1:		inc w2,w2
		cp w2,w3
		bra ltu,$+4
		mov #ReverbBuffer,w2
		mov w2,ReverbReadPnt

		sl w4,#8,w4					; interpolate
		mov.b [w2],w5
		sl w5,#8,w5
		asr w4,w4
		asr w5,w5
		add w4,w5,w4

		lac w0,#0,A
		mov ReverbLevel,w5
		mac w4*w5,A
		sac.r A,#0,w0

		btsc SysFlags,#DELAY_FEEDBACK
		mov w0,w1

		mov ReverbWritePnt,w2

		asr w1,#8,w1					; average
		mov.b [w2],w4
		se w4,w4
		add w1,w4,w1
		asr w1,w1

		mov.b w1,[w2++]				; store output in reverb buffer
		cp w2,w3
		bra ltu,$+4
		mov #ReverbBuffer,w2
		mov w2,ReverbWritePnt

2:		com.b ReverbByte				; toggle byte flag

		pop CORCON

		return


;---------------------------------------------------------------------------
; StepReverbLFO - steps reverb period LFO
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0 - w2, A
;---------------------------------------------------------------------------

.global StepReverbLFO
StepReverbLFO:

		mov #ReverbLFO,w0
		mov [w0+LFOStep],w1
		mov [w0+LFOOffset],w2
		add w1,w2,w2
;		bra nc,$+4
;		clr w2
		mov w2,[w0+LFOOffset]
		rcall CalcLFOModulation

		return


;---------------------------------------------------------------------------
; variables
;---------------------------------------------------------------------------

.section .nbss,bss,near
.align 2

ReverbWritePnt:	.space 2		; buffer write pointer
ReverbReadPnt:		.space 2		; buffer read pointer
ReverbLevel:		.space 2		; reverb level (unsigned 1.15)
ReverbByte:		.space 1		; byte flag


.section .bss,bss
.align 2

; reverb period LFO
.global ReverbLFO
ReverbLFO:		.space LFOSizeof

; reverb buffer (circular buffer)
ReverbBuffer:		.space REVERB_BUFFER_SIZE


.end
