/***************************************************************************
* FILE:      dac.s												*
* CONTENTS:  D/A converter routines								*
* COPYRIGHT: MadLab Ltd. 2012-18									*
* AUTHOR:    James Hutchby										*
* UPDATED:   17/06/18											*
***************************************************************************/

.include "p33EP128MC202.inc"
.include "common.inc"


;---------------------------------------------------------------------------
; port assignments
;---------------------------------------------------------------------------

.equ DAC_LD, 8			; DAC load (RP40/RB8)
.equ DAC_CLK, 7		; DAC clock (RP39/RB7)
.equ DAC_DATA, 6		; DAC data (RP38/RB6)

.equ PWM_OUT, 14		; PWM output (PWM1H/RB14)


.section .text

;---------------------------------------------------------------------------
; InitDAC - initialises the D/A converter
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

.global InitDAC
InitDAC:

		clr Mixer						; clear mixer output

		.if DAC_AUDIO

		bset LATB,#DAC_LD				; initialise ports
		bclr TRISB,#DAC_LD
		bset TRISB,#DAC_CLK
		bset TRISB,#DAC_DATA

		bclr CNPUB,#DAC_LD
		bclr CNPUB,#DAC_CLK
		bclr CNPUB,#DAC_DATA

		bclr IEC2,#SPI2IE				; disable SPI interrupt

		clr SPI2STAT

		mov #0b0000010100111110,w0		; SPI master, word mode, prescale 4:1
		mov w0,SPI2CON1

		clr SPI2CON2

		bset SPI2STAT,#SPIEN			; enable SPI

		.endif

		.if PWM_AUDIO

.equ PWM_BITS, 10

		bset TRISB,#PWM_OUT				; initialise ports

		bclr CNPUB,#PWM_OUT

		bclr CNPUB,#4					; clear fault
		bset CNPDB,#4

		mov #0b0000000000000000,w0		; updates on cycle boundaries
		mov w0,PTCON

		mov #0b000,w0					; no prescalar
		mov w0,PTCON2

		mov #(1<<PWM_BITS)-1,w0
		mov w0,PTPER

		clr SEVTCMP
		clr CHOP
		clr MDC

		mov #0b0000000010000000,w0		; interrupts disabled, dead-time disabled,
		mov w0,PWMCON1					; primary master, edge-aligned

		clr PDC1
		clr PHASE1
		clr DTR1
		clr ALTDTR1
		clr TRGCON1

		mov #0xabcd,w1					; PWM1H output, active-high, complementary
		mov #0x4321,w2
		mov #0b1000000000000000,w0
		mov w1,PWMKEY
		mov w2,PWMKEY
		mov w0,IOCON1

		clr TRIG1

		mov #0xabcd,w1					; current-limit and fault disabled
		mov #0x4321,w2
		mov #0b0000000000000011,w0
		mov w1,PWMKEY
		mov w2,PWMKEY
		mov w0,FCLCON1

		clr LEBCON1
		clr LEBDLY1
		clr AUXCON1

		bclr PWMCON1,#FLTSTAT

		bset PTCON,#PTEN				; PWM on

		bset CNPUB,#4
		bclr CNPDB,#4

		.endif

		mov #0b0000000000000000,w0		; initialise Timer1 - internal clock,
		mov w0,T1CON					; no prescale

		clr TMR1

		mov #(CLOCK/2)/SAMPLE_RATE,w0
		mov w0,PR1

		bset IPC0,#T1IP2				; interrupt priority = 6
		bset IPC0,#T1IP1
		bclr IPC0,#T1IP0

		bclr IFS0,#T1IF				; enable timer interrupt
		bset IEC0,#T1IE

		bset T1CON,#TON				; timer on

		return


;---------------------------------------------------------------------------
; Timer #1 isr
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	B
;---------------------------------------------------------------------------

.global __T1Interrupt
__T1Interrupt:

		push.s
		push ACCAU
		push ACCAH
		push ACCAL
		push RCOUNT

		mov Mixer,w0					; previous mixer output
		.if DAC_AUDIO
		rcall OutputDAC
		.endif
		.if PWM_AUDIO
		rcall OutputPWM
		.endif

		rcall GetMixerOutput			; get next mixer output
		mov w0,Mixer

		bclr IFS0,#T1IF				; clear interrupt

		pop RCOUNT
		pop ACCAL
		pop ACCAH
		pop ACCAU
		pop.s

		retfie


;---------------------------------------------------------------------------
; OutputDAC - D/A converter output
;
; Entry:	w0 = DAC output
;
; Exit: 	-
;
; Uses:	w0, w1
;---------------------------------------------------------------------------

.equ FS_1X, 1650		; DAC full-scale output in mV, gain 1x
.equ FS_2X, 3300		; DAC full-scale output in mV, gain 2x
.equ BASE, 700			; transistor minimum base in mV

.global OutputDAC
OutputDAC:

		.if DAC_AUDIO

		bset LATB,#DAC_LD				; strobe (previous) data

.equ BIAS_1X, (BASE*0x8000)/FS_1X
.equ BIAS_2X, (BASE*0x8000)/FS_2X

		mov #BIAS_1X,w1
		btsc SysFlags,#GAIN_2X
		mov #BIAS_2X,w1
		add w1,w0,w0
		bra nov,$+4
		mov #0x7fff,w0

		btg w0,#15					; signed -> unsigned
		lsr w0,#4,w0

		mov #0b0011<<12,w1				; unbuffered, gain 1x
		btsc SysFlags,#GAIN_2X
		mov #0b0001<<12,w1				; unbuffered, gain 2x
		ior w0,w1,w0

		bclr LATB,#DAC_LD

		mov w0,SPI2BUF					; write SPI data

		.endif

		return


;---------------------------------------------------------------------------
; OutputPWM - PWM output
;
; Entry:	w0 = PWM output
;
; Exit: 	-
;
; Uses:	w0, w1
;---------------------------------------------------------------------------

.global OutputPWM
OutputPWM:

		.if PWM_AUDIO

		btg w0,#15					; signed -> unsigned
		lsr w0,#16-PWM_BITS,w0

		mov w0,PDC1

		.endif

		return


;---------------------------------------------------------------------------
; variables
;---------------------------------------------------------------------------

.section .nbss,bss,near
.align 2

.global Mixer
Mixer:		.space 2			; mixer output


.end
