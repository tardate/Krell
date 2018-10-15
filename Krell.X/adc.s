/***************************************************************************
* FILE:      adc.s												*
* CONTENTS:  A/D converter routines								*
* COPYRIGHT: MadLab Ltd. 2012-18									*
* AUTHOR:    James Hutchby										*
* UPDATED:   13/07/18											*
***************************************************************************/

.include "p33EP128MC202.inc"
.include "common.inc"


;---------------------------------------------------------------------------
; port assignments
;---------------------------------------------------------------------------

.if NOISE_X
.equ VR1, 1			; preset #1 (AN1/RA1)
.equ VR2, 2			; preset #2 (AN2/RB0)
.equ VR3, 3			; preset #3 (AN3/RB1)
.equ VR4, 4			; preset #4 (AN4/RB2)
.equ VR5, 0			; preset #5 (AN0/RA0) (slider)
.equ VR6, 5			; preset #6 (AN5/RB3) (slider)
.endif
.if KRELL
.equ VR1, 1			; preset #1 (AN1/RA1)
.equ VR2, 2			; preset #2 (AN2/RB0)
.equ VR3, 3			; preset #3 (AN3/RB1)
.equ VR4, 4			; preset #4 (AN4/RB2)
.equ VR5, 5			; preset #5 (AN5/RB3)
.equ VR6, 0			; preset #6 (AN0/RA0)
.endif

.if NOISE_X
.equ VR_MASK, 0b0000000111111
.endif
.if KRELL
.equ VR_MASK, 0b0000000111111
.endif

.equ NUM_SAMPLES, 1<<4
.equ DMA_LEN, 6*2*NUM_SAMPLES+6*2


.section .text

;---------------------------------------------------------------------------
; InitADC - initialises the A/D converter
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

.global InitADC
InitADC:

		clr presets+0*2
		clr presets+1*2
		clr presets+2*2
		clr presets+3*2
		clr presets+4*2
		clr presets+5*2

		clr samples					; clear samples counter

		bclr IEC0,#AD1IE				; disable ADC interrupt

		mov #0b0001010011100100,w0		; 12-bit mode, integer output, auto-conversion,
		mov w0,AD1CON1					; sample auto-start

		mov #0b0000010000010100,w0		; internal Vref, scan inputs, interrupt every 6th word,
		mov w0,AD1CON2					; MUX A

		mov #(0b00011111<<8)+(20-1),w0	; system clock, 20 Tcy, 31 Tad auto sample time
		mov w0,AD1CON3

		mov #0b0000000100000000,w0		; enable DMA
		mov w0,AD1CON4

		clr AD1CHS0

		.if NOISE_X					; configure as analogue inputs
		bset TRISA,#1
		bset TRISB,#0
		bset TRISB,#1
		bset TRISB,#2
		bset TRISA,#0
		bset TRISB,#3
		.endif
		.if KRELL
		bset TRISA,#1
		bset TRISB,#0
		bset TRISB,#1
		bset TRISB,#2
		bset TRISB,#3
		bset TRISA,#0
		.endif

		.if NOISE_X
		bset ANSELA,#1
		bset ANSELB,#0
		bset ANSELB,#1
		bset ANSELB,#2
		bset ANSELA,#0
		bset ANSELB,#3
		.endif
		.if KRELL
		bset ANSELA,#1
		bset ANSELB,#0
		bset ANSELB,#1
		bset ANSELB,#2
		bset ANSELB,#3
		bset ANSELA,#0
		.endif

		mov #VR_MASK,w0				; input scan
		mov w0,AD1CSSL

		bclr IEC0,#DMA0IE

		mov #0b0000000000000000,w0		; word transfer, from peripheral, register indirect
		mov w0,DMA0CON					; with post-increment, continuous

		mov #0b0000000000001101,w0		; ADC1 convert done
		mov w0,DMA0REQ

		mov #DMA_RAM+DMA_LEN-6*2,w0		; DMA address
		mov w0,DMA0STAL
		clr DMA0STAH

		mov #ADC1BUF0,w0				; ADC1
		mov w0,DMA0PAD

		mov #6-1,w0					; count
		mov w0,DMA0CNT

		bset IPC1,#DMA0IP2				; interrupt priority = 5
		bclr IPC1,#DMA0IP1
		bset IPC1,#DMA0IP0

		bset DMA0CON,#CHEN				; enable DMA channel

		bclr IFS0,#DMA0IF				; enable DMA interrupt
		bset IEC0,#DMA0IE

		bset AD1CON1,#ADON				; enable A/D module

		return


;---------------------------------------------------------------------------
; DMA #0 isr
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	-
;---------------------------------------------------------------------------

.global __DMA0Interrupt
__DMA0Interrupt:

		push.d w0
		push.d w2

		mov samples,w0
		mul.uu w0,#6*2,w0
		mov #DMA_RAM,w1
		add w1,w0,w1
		mov #DMA_RAM+DMA_LEN-6*2,w0
		.rept 6
		mov [w0++],[w1++]
		.endr

		inc samples
		mov #NUM_SAMPLES-1,w0
		and samples
		cp0 samples
		bra nz,2f

		.equ i, 0						; rank samples and select mid-point
		.rept 6

		mov.b #NUM_SAMPLES/2,w1

1:		mov #0xffff,w0

		.equ j, 0						; find lowest
		.rept NUM_SAMPLES
		mov DMA_RAM+i*2+j*6*2,w2
		cp w0,w2
		bra leu,$+6
		mov w2,w0
		mov #DMA_RAM+i*2+j*6*2,w3
		.equ j, j+1
		.endr

		setm [w3]						; remove it

		dec.b w1,w1
		bra nz,1b

		mov w0,DMA_+i*2

		.equ i, i+1
		.endr

2:		bclr IFS0,#DMA0IF				; clear interrupt

		pop.d w2
		pop.d w0

		retfie


;---------------------------------------------------------------------------
; PollPresets - polls the presets
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0, w1
;---------------------------------------------------------------------------

.global PollPresets
PollPresets:

.macro smooth preset,ram					; moving average
		mov \preset,w0
		add \preset
		add \preset
		mov \ram,w0
		mov #0x0fff,w1
		.if NOISE_X
		xor w0,w1,w0					; invert preset
		.endif
		add \preset
		lsr \preset
		lsr \preset					; 3/4 previous + 1/4 current
.endm

		.if NOISE_X
		smooth presets+4*2,DMA_+0*2
		smooth presets+0*2,DMA_+1*2
		smooth presets+1*2,DMA_+2*2
		smooth presets+2*2,DMA_+3*2
		smooth presets+3*2,DMA_+4*2
		smooth presets+5*2,DMA_+5*2
		.endif
		.if KRELL
		smooth presets+5*2,DMA_+0*2
		smooth presets+0*2,DMA_+1*2
		smooth presets+1*2,DMA_+2*2
		smooth presets+2*2,DMA_+3*2
		smooth presets+3*2,DMA_+4*2
		smooth presets+4*2,DMA_+5*2
		.endif

		return


;---------------------------------------------------------------------------
; variables
;---------------------------------------------------------------------------

.section .nbss,bss,near
.align 2

.global presets
samples:		.space 2			; samples counter
presets:		.space 6*2		; presets
DMA_:		.space 6*2


.section .bss,bss
.align 2

DMA_RAM:		.space DMA_LEN		; DMA RAM


.end
