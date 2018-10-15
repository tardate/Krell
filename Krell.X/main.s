/***************************************************************************
* FILE:      main.s												*
* CONTENTS:  Noise-X/Krell mainline routines							*
* COPYRIGHT: MadLab Ltd. 2012-2018									*
* AUTHOR:    James Hutchby										*
* UPDATED:   14/07/18											*
***************************************************************************/

.include "p33EP128MC202.inc"
.include "common.inc"


.if NOISE_X
config __FICD, ICS_PGD3 & JTAGEN_OFF
.endif
.if KRELL
config __FICD, ICS_PGD2 & JTAGEN_OFF
.endif
config __FPOR, ALTI2C1_OFF & ALTI2C2_OFF
.ifdef __DEBUG
config __FWDT, PLLKEN_ON & FWDTEN_OFF
.else
config __FWDT, WDTPOST_PS128 & WDTPRE_PR128 & PLLKEN_ON & WINDIS_OFF & FWDTEN_ON
.endif
config __FOSC, POSCMD_NONE & OSCIOFNC_ON & IOL1WAY_OFF & FCKSM_CSECMD
config __FOSCSEL, FNOSC_FRC & PWMLOCK_OFF & IESO_OFF
config __FGS, GWRP_OFF & GCP_OFF

config __FUID0, 0xB120


;---------------------------------------------------------------------------
; notes
;---------------------------------------------------------------------------

; power-on self-test: all LEDs flash twice

; 8 octaves, 30Hz to ~8kHz

; Mode #0:
;  VR1 - DCO #0 waveform
;  VR2 - DCO #0 pitch LFO waveform
;  VR3 - DCO #0 pitch LFO frequency
;  VR4 - DCO #0 pitch LFO amplitude
;  VR5 - DCO #0 pitch
;  VR6 - DCO #0 amplitude

; Mode #1:
;  VR1 - DCO #0 amplitude LFO pulse width
;  VR2 - DCO #0 amplitude LFO waveform
;  VR3 - DCO #0 amplitude LFO frequency
;  VR4 - DCO #0 amplitude LFO amplitude
;  VR5 - DCO #0 pulse width
;  VR6 - DCO #0 pitch LFO pulse width

; Mode #2:
;  VR1 - DCO #1 waveform
;  VR2 - DCO #1 pitch LFO waveform
;  VR3 - DCO #1 pitch LFO frequency
;  VR4 - DCO #1 pitch LFO amplitude
;  VR5 - DCO #1 pitch
;  VR6 - DCO #1 amplitude

; Mode #3:
;  VR1 - DCO #1 amplitude LFO pulse width
;  VR2 - DCO #1 amplitude LFO waveform
;  VR3 - DCO #1 amplitude LFO frequency
;  VR4 - DCO #1 amplitude LFO amplitude
;  VR5 - DCO #1 pulse width
;  VR6 - DCO #1 pitch LFO pulse width

; Mode #4:
;  VR1 - DCO #2 waveform
;  VR2 - DCO #2 pitch LFO waveform
;  VR3 - DCO #2 pitch LFO frequency
;  VR4 - DCO #2 pitch LFO amplitude
;  VR5 - DCO #2 pitch
;  VR6 - DCO #2 amplitude

; Mode #5:
;  VR1 - DCO #2 amplitude LFO pulse width
;  VR2 - DCO #2 amplitude LFO waveform
;  VR3 - DCO #2 amplitude LFO frequency
;  VR4 - DCO #2 amplitude LFO amplitude
;  VR5 - DCO #2 pulse width
;  VR6 - DCO #2 pitch LFO pulse width

; Mode #6:
;  VR1 - DCO #3 waveform
;  VR2 - DCO #3 pitch LFO waveform
;  VR3 - DCO #3 pitch LFO frequency
;  VR4 - DCO #3 pitch LFO amplitude
;  VR5 - DCO #3 pitch
;  VR6 - DCO #3 amplitude

; Mode #7:
;  VR1 - DCO #3 amplitude LFO pulse width
;  VR2 - DCO #3 amplitude LFO waveform
;  VR3 - DCO #3 amplitude LFO frequency
;  VR4 - DCO #3 amplitude LFO amplitude
;  VR5 - DCO #3 pulse width
;  VR6 - DCO #3 pitch LFO pulse width

; Mode #8:
;  VR1 - off/ring modulation/frequency modulation on DCOs #0 and #1
;  VR2 - reverb feedback
;  VR3 - off/ring modulation/frequency modulation on DCOs #2 and #3
;  VR4 -
;  VR5 - reverb period
;  VR6 - reverb level

; Mode #9:
;  VR1 - reverb period LFO pulse width
;  VR2 - reverb period LFO waveform
;  VR3 - reverb period LFO frequency
;  VR4 - reverb period LFO amplitude
;  VR5 -
;  VR6 -

; Mode #10:
;  VR1 - master volume
;  VR2 - fuzz (hard clipping)
;  VR3 - additive synthesis
;  VR4 -
;  VR5 - flanger frequency
;  VR6 - flanger amplitude

; Mode #11:
;  VR1 -
;  VR2 -
;  VR3 -
;  VR4 - flanger pulse width
;  VR5 - flanger waveform
;  VR6 - flanger base

; running lights pattern depends on mode

; restarts if pushbuttons #1 and #6 pressed together
; toggles gainx2 if pushbuttons #3 and #4 pressed together (Noise-X)
; saves settings if pushbuttons #1 and #2 pressed together
; loads settings if pushbuttons #5 and #6 pressed together

; cycles demo bank #1 if pushbuttons #1 and #3 pressed together
; cycles demo bank #2 if pushbuttons #4 and #6 pressed together
; cycles demo bank #3 if pushbuttons #2 and #5 pressed together


;---------------------------------------------------------------------------
; port assignments
;---------------------------------------------------------------------------

.if NOISE_X
.equ LED1, 14		; LED #1 (RB14)
.equ LED2, 13		; LED #2 (RB13)
.equ LED3, 12		; LED #3 (RB12)
.equ LED4, 11		; LED #4 (RB11)
.endif
.if KRELL
.equ LED1, 13		; LED #1 (RB13)
.equ LED2, 3		; LED #2 (RA3)
.equ LED3, 11		; LED #3 (RB11)
.equ LED4, 10		; LED #4 (RB10)
.endif

.if NOISE_X
.equ S1, 15 		; pushbutton #1 (RB15)
.equ S2, 2 		; pushbutton #2 (RA2)
.equ S3, 3 		; pushbutton #3 (RA3)
.equ S4, 4 		; pushbutton #4 (RB4)
.equ S5, 4 		; pushbutton #5 (RA4)
.equ S6, 5 		; pushbutton #6 (RB5)
.endif
.if KRELL
.equ S1, 15 		; pushbutton #1 (RB15)
.equ S2, 6 		; pushbutton #2 (RB6)
.equ S3, 9 		; pushbutton #3 (RB9)
.equ S4, 8 		; pushbutton #4 (RB8)
.equ S5, 5 		; pushbutton #5 (RB5)
.equ S6, 7 		; pushbutton #6 (RB7)
.endif

.if KRELL
.equ MSEL, 4		; CLI/MIDI select (RA4)
.endif

.macro LED1_off
		.if NOISE_X
		bclr LATB,#LED1
		.endif
		.if KRELL
		bclr LATB,#LED1
		.endif
.endm

.macro LED2_off
		.if NOISE_X
		bclr LATB,#LED2
		.endif
		.if KRELL
		bclr LATA,#LED2
		.endif
.endm

.macro LED3_off
		.if NOISE_X
		bclr LATB,#LED3
		.endif
		.if KRELL
		bclr LATB,#LED3
		.endif
.endm

.macro LED4_off
		.if NOISE_X
		bclr LATB,#LED4
		.endif
		.if KRELL
		bclr LATB,#LED4
		.endif
.endm

.macro LED1_on
		.if NOISE_X
		bset LATB,#LED1
		.endif
		.if KRELL
		bset LATB,#LED1
		.endif
.endm

.macro LED2_on
		.if NOISE_X
		bset LATB,#LED2
		.endif
		.if KRELL
		bset LATA,#LED2
		.endif
.endm

.macro LED3_on
		.if NOISE_X
		bset LATB,#LED3
		.endif
		.if KRELL
		bset LATB,#LED3
		.endif
.endm

.macro LED4_on
		.if NOISE_X
		bset LATB,#LED4
		.endif
		.if KRELL
		bset LATB,#LED4
		.endif
.endm


;---------------------------------------------------------------------------
; constants
;---------------------------------------------------------------------------

; poll period in ms
.equ POLL_PERIOD, 4


.macro delay ms
		do #((((CLOCK/2)/0x2000)*(\ms))/1000)-1,0f
		repeat #0x2000-1
		nop
0:		clrwdt
.endm


.section .text

;---------------------------------------------------------------------------
; main entry point
;---------------------------------------------------------------------------

.global __reset
__reset:

		mov #__SP_init,w15				; initialise stack
		mov #__SPLIM_init,w0
		mov w0,_SPLIM
		nop

		mov #__DATA_BASE,w0				; clear memory
		mov #__DATA_LENGTH,w1
		add w0,w1,w1
1:		clr [w0++]
		cp w0,w1
		bra ltu,1b

		clr SysFlags					; initialise variables
		clr Rand

		rcall InitHardware				; initialise hardware

		rcall ResetControls				; reset controls

		rcall InitMixer				; initialise mixer

		rcall InitDAC					; initialise DAC

		rcall InitADC					; initialise ADC

		.if KRELL

		btsc PORTA,#MSEL				; CLI ?
		bset SysFlags,#CLI_ENABLE

		btss PORTA,#MSEL				; MIDI ?
		bset SysFlags,#MIDI_ENABLE

		rcall InitUART					; initialise UART

		btsc SysFlags,#CLI_ENABLE		; initialise CLI
		rcall InitCLI

		btsc SysFlags,#MIDI_ENABLE		; initialise MIDI
		rcall InitMIDI

		.endif

		bset INTCON2,#GIE				; enable interrupts

		rcall FlashLEDs				; double flash LEDs
		rcall FlashLEDs

		rcall InitLEDs					; initialise LEDs

		rcall InitPresets				; initialise presets

		setm.b Mode
		mov.b #0,w0
		rcall SetMode

2:		delay 20						; wait for pushbuttons to be released
		rcall PollButtons
		cp0.b buttons
		bra nz,2b


;---------------------------------------------------------------------------
; start of main loop
;---------------------------------------------------------------------------

main_loop:

		clrwdt

		mov Ticks,w1
1:		clrwdt
		mov Ticks,w0
		sub w0,w1,w0
		cp w0,#POLL_PERIOD
		bra ltu,1b

		mov.b #0,w0					; frequency lock quiescent DCOs
2:		push w0
		rcall GetDCO
		mov [w0+DCOTimer],w1
		cp0 w1
		bra z,$+4
		dec w1,w1
		mov w1,[w0+DCOTimer]
		bra nz,3f
		rcall LockDCO
		bra 4f
3:		rcall UnlockDCO
4:		pop w0
		inc.b w0,w0
		cp.b w0,#NUM_DCOS
		bra ltu,2b


;---------------------------------------------------------------------------
; pushbuttons
;---------------------------------------------------------------------------

		rcall PollButtons				; poll the pushbuttons

		mov.b buttons,wreg				; restart if pushbuttons #1 & #6
		mov.b #0b100001,w1				; pressed together
		cpsne.b w0,w1
		reset

		mov.b buttons,wreg				; toggle gainx2 if pushbuttons #3 & #4
		mov.b #0b001100,w1				; pressed together
		cp.b w0,w1
		bra nz,2f

		btg SysFlags,#GAIN_2X

		mov.b #0,w0
		rcall SetMode

1:		delay 20						; wait for pushbuttons to be released
		rcall PollButtons
		cp0.b buttons
		bra nz,1b

		bra main_loop

2:		mov.b buttons,wreg				; save settings if pushbuttons #1 & #2
		mov.b #0b000011,w1				; pressed together
		cp.b w0,w1
		bra nz,3f

		bclr T3CON,#TON				; double flash LEDs
		rcall FlashLEDs
		rcall FlashLEDs
		bset T3CON,#TON

		rcall SaveSettings

		bra main_loop

3:		mov.b buttons,wreg				; load settings if pushbuttons #5 & #6
		mov.b #0b110000,w1				; pressed together
		cp.b w0,w1
		bra nz,4f

		bclr T3CON,#TON				; double flash LEDs
		rcall FlashLEDs
		rcall FlashLEDs
		bset T3CON,#TON

		mov #0,w0
		rcall SetProgram

		bra main_loop

4:		mov.b buttons,wreg				; load demo bank #1 if pushbuttons #1 & #3
		mov.b #0b000101,w1				; pressed together
		cp.b w0,w1
		bra nz,5f

		bclr T3CON,#TON				; double flash LEDs
		rcall FlashLEDs
		rcall FlashLEDs
		bset T3CON,#TON

		sl.b bank1,wreg
		add.b bank1,wreg
		add.b #1,w0
		rcall SetProgram

		inc.b bank1
		mov.b #NUM_PROGRAMS/3,w0
		cp.b bank1
		bra nz,$+4
		clr.b bank1

		bra main_loop

5:		mov.b buttons,wreg				; load demo bank #2 if pushbuttons #4 & #6
		mov.b #0b101000,w1				; pressed together
		cp.b w0,w1
		bra nz,6f

		bclr T3CON,#TON				; double flash LEDs
		rcall FlashLEDs
		rcall FlashLEDs
		bset T3CON,#TON

		sl.b bank2,wreg
		add.b bank2,wreg
		add.b #2,w0
		rcall SetProgram

		inc.b bank2
		mov.b #NUM_PROGRAMS/3,w0
		cp.b bank2
		bra nz,$+4
		clr.b bank2

		bra main_loop

6:		mov.b buttons,wreg				; load demo bank #3 if pushbuttons #2 & #5
		mov.b #0b010010,w1				; pressed together
		cp.b w0,w1
		bra nz,7f

		bclr T3CON,#TON				; double flash LEDs
		rcall FlashLEDs
		rcall FlashLEDs
		bset T3CON,#TON

		sl.b bank3,wreg
		add.b bank3,wreg
		add.b #3,w0
		rcall SetProgram

		inc.b bank3
		mov.b #NUM_PROGRAMS/3,w0
		cp.b bank3
		bra nz,$+4
		clr.b bank3

		bra main_loop

7:		mov.b Mode,wreg
		bclr w0,#0

		btsc.b buttons,#0
		mov.b #1,w0
		btsc.b buttons,#1
		mov.b #3,w0
		btsc.b buttons,#2
		mov.b #5,w0
		btsc.b buttons,#3
		mov.b #7,w0
		btsc.b buttons,#4
		mov.b #9,w0
		btsc.b buttons,#5
		mov.b #11,w0

		rcall SetMode


;---------------------------------------------------------------------------
; presets
;---------------------------------------------------------------------------

		rcall PollPresets

		mov.b Mode,wreg
		ze w0,w0
		mul.uu w0,#6<<1,w0
		mov #controls,w4
		add w4,w0,w4

		mov #presets,w2
		mov #presets_offset,w3

		do #6-1,3f

		mov [w2++],w0
		add w0,[w3++],w0
		bra nn,1f

		neg w0,w0
		add w0,[--w3],w0
		mov w0,[w3++]
		clr w0

1:		mov #0x0fff,w1
		cp w0,w1
		bra leu,2f

		sub w0,w1,w0
		neg w0,w0
		add w0,[--w3],w0
		mov w0,[w3++]
		mov w1,w0

2:		mov w0,[w4++]

3:		nop

		sub w4,#6<<1,w4

.equ PRESET_THRESHOLD, 10

		mov presets+0*2,w1				; VR1
		mov presets_prev+0*2,w2
		sub w1,w2,w2
		btsc w2,#15
		neg w2,w2
		cp w2,#PRESET_THRESHOLD
		bra ltu,1f
		mov presets+0*2,w0
		mov w0,presets_prev+0*2
		rcall do_VR1
1:

		mov presets+1*2,w1				; VR2
		mov presets_prev+1*2,w2
		sub w1,w2,w2
		btsc w2,#15
		neg w2,w2
		cp w2,#PRESET_THRESHOLD
		bra ltu,2f
		mov presets+1*2,w0
		mov w0,presets_prev+1*2
		rcall do_VR2
2:

		mov presets+2*2,w1				; VR3
		mov presets_prev+2*2,w2
		sub w1,w2,w2
		btsc w2,#15
		neg w2,w2
		cp w2,#PRESET_THRESHOLD
		bra ltu,3f
		mov presets+2*2,w0
		mov w0,presets_prev+2*2
		rcall do_VR3
3:

		mov presets+3*2,w1				; VR4
		mov presets_prev+3*2,w2
		sub w1,w2,w2
		btsc w2,#15
		neg w2,w2
		cp w2,#PRESET_THRESHOLD
		bra ltu,4f
		mov presets+3*2,w0
		mov w0,presets_prev+3*2
		rcall do_VR4
4:

		mov presets+4*2,w1				; VR5 (Noise-X left slider)
		mov presets_prev+4*2,w2
		sub w1,w2,w2
		btsc w2,#15
		neg w2,w2
		cp w2,#PRESET_THRESHOLD
		bra ltu,5f
		mov presets+4*2,w0
		mov w0,presets_prev+4*2
		rcall do_VR5
5:

		mov presets+5*2,w1				; VR6 (Noise-X right slider)
		mov presets_prev+5*2,w2
		sub w1,w2,w2
		btsc w2,#15
		neg w2,w2
		cp w2,#PRESET_THRESHOLD
		bra ltu,6f
		mov presets+5*2,w0
		mov w0,presets_prev+5*2
		rcall do_VR6
6:


;---------------------------------------------------------------------------
; CLI/MIDI
;---------------------------------------------------------------------------

		.if KRELL

		btsc SysFlags,#CLI_ENABLE
		rcall DoCLI

		.endif


;---------------------------------------------------------------------------
; end of main loop
;---------------------------------------------------------------------------

		bra main_loop


;---------------------------------------------------------------------------
; preset executives
;---------------------------------------------------------------------------

InitPresets:
		.rept 32
		rcall PollPresets
		repeat #0x1000-1
		clrwdt
		.endr

		mov presets+0*2,w0
		mov w0,presets_prev+0*2
		mov presets+1*2,w0
		mov w0,presets_prev+1*2
		mov presets+2*2,w0
		mov w0,presets_prev+2*2
		mov presets+3*2,w0
		mov w0,presets_prev+3*2
		mov presets+4*2,w0
		mov w0,presets_prev+4*2
		mov presets+5*2,w0
		mov w0,presets_prev+5*2

		return


do_VR1:
		mov.b Mode,wreg
		ze w0,w0
		mul.uu w0,#6,w0
		add w0,#0,w1

		mov [w4+0*2],w0
		rcall stretch

		rcall do_control
		return

do_VR2:
		mov.b Mode,wreg
		ze w0,w0
		mul.uu w0,#6,w0
		add w0,#1,w1

		mov [w4+1*2],w0
		rcall stretch

		rcall do_control
		return

do_VR3:
		mov.b Mode,wreg
		ze w0,w0
		mul.uu w0,#6,w0
		add w0,#2,w1

		mov [w4+2*2],w0
		rcall stretch

		rcall do_control
		return

do_VR4:
		mov.b Mode,wreg
		ze w0,w0
		mul.uu w0,#6,w0
		add w0,#3,w1

		mov [w4+3*2],w0
		rcall stretch

		rcall do_control
		return

do_VR5:
		mov.b Mode,wreg
		ze w0,w0
		mul.uu w0,#6,w0
		add w0,#4,w1

		mov [w4+4*2],w0
		rcall stretch

		rcall do_control
		return

do_VR6:
		mov.b Mode,wreg
		ze w0,w0
		mul.uu w0,#6,w0
		add w0,#5,w1

		mov [w4+5*2],w0
		rcall stretch

		rcall do_control
		return


stretch:

		push w1

		lsr w0,#4,w1					; scale to ensure full range covered
		add w0,w1,w0
		mov #128,w1
		sub w0,w1,w0

		btsc w0,#15					; clip lower
		clr w0

		mov #0x0fff,w1					; clip upper
		cp w0,w1
		bra leu,$+4
		mov w1,w0

		pop w1

		return


;---------------------------------------------------------------------------
; do_control - control changed
;
; Entry:	w0 = control value
;		w1 = control number
;
; Exit: 	-
;
; Uses:	w0 - w1
;---------------------------------------------------------------------------

do_control:

		push.d w2
		push RCOUNT

		push w0
		push w1

		mov #6<<1,w2
		repeat #17
		div.u w1,w2

		cp.b w0,#NUM_DCOS
		bra geu,1f

		rcall GetDCO
		mov w0,w1

1:		pop w2
		pop w0

		mov #tbloffset(vectors),w3
		ze w2,w2
		add w2,w3,w3
		add w2,w3,w3
		tblrdl [w3],w3
		cp0 w3
		bra z,$+4
		call w3

		pop RCOUNT
		pop.d w2

		return

.align 2
vectors:
	.word handle(do_DCO_wave)				; #0 - #5
	.word handle(do_pitch_LFO_wave)
	.word handle(do_pitch_LFO_freq)
	.word handle(do_pitch_LFO_amp)
	.word handle(do_DCO_pitch)
	.word handle(do_DCO_amp)

	.word handle(do_amp_LFO_pulse)			; #6 - #11
	.word handle(do_amp_LFO_wave)
	.word handle(do_amp_LFO_freq)
	.word handle(do_amp_LFO_amp)
	.word handle(do_DCO_pulse)
	.word handle(do_pitch_LFO_pulse)

	.word handle(do_DCO_wave)				; #12 - #17
	.word handle(do_pitch_LFO_wave)
	.word handle(do_pitch_LFO_freq)
	.word handle(do_pitch_LFO_amp)
	.word handle(do_DCO_pitch)
	.word handle(do_DCO_amp)

	.word handle(do_amp_LFO_pulse)			; #18 - #23
	.word handle(do_amp_LFO_wave)
	.word handle(do_amp_LFO_freq)
	.word handle(do_amp_LFO_amp)
	.word handle(do_DCO_pulse)
	.word handle(do_pitch_LFO_pulse)

	.word handle(do_DCO_wave)				; #24 - #29
	.word handle(do_pitch_LFO_wave)
	.word handle(do_pitch_LFO_freq)
	.word handle(do_pitch_LFO_amp)
	.word handle(do_DCO_pitch)
	.word handle(do_DCO_amp)

	.word handle(do_amp_LFO_pulse)			; #30 - #35
	.word handle(do_amp_LFO_wave)
	.word handle(do_amp_LFO_freq)
	.word handle(do_amp_LFO_amp)
	.word handle(do_DCO_pulse)
	.word handle(do_pitch_LFO_pulse)

	.word handle(do_DCO_wave)				; #36 - #41
	.word handle(do_pitch_LFO_wave)
	.word handle(do_pitch_LFO_freq)
	.word handle(do_pitch_LFO_amp)
	.word handle(do_DCO_pitch)
	.word handle(do_DCO_amp)

	.word handle(do_amp_LFO_pulse)			; #42 - #47
	.word handle(do_amp_LFO_wave)
	.word handle(do_amp_LFO_freq)
	.word handle(do_amp_LFO_amp)
	.word handle(do_DCO_pulse)
	.word handle(do_pitch_LFO_pulse)

	.word handle(do_RM_FM_01)				; #48 - #53
	.word handle(do_reverb_feedback)
	.word handle(do_RM_FM_23)
	.word 0
	.word handle(do_reverb_period)
	.word handle(do_reverb_level)

	.word handle(do_reverb_LFO_pulse)			; #54 - #59
	.word handle(do_reverb_LFO_wave)
	.word handle(do_reverb_LFO_freq)
	.word handle(do_reverb_LFO_amp)
	.word 0
	.word 0

	.word handle(do_master_volume)			; #60 - #65
	.word handle(do_fuzz_level)
	.word handle(do_add_synth)
	.word 0
	.word handle(do_flanger_freq)
	.word handle(do_flanger_amp)

	.word 0								; #66 - #71
	.word 0
	.word 0
	.word handle(do_flanger_pulse)
	.word (do_flanger_wave)
	.word handle(do_flanger_base)


; DCO waveform
do_DCO_wave:
		push w1
		mov #(4096/NUM_WAVEFORMS)+1,w2
		repeat #17
		div.u w0,w2
		pop w1
		exch w0,w1
		rcall SetDCOWaveform
		return

; pitch LFO waveform
do_pitch_LFO_wave:
		push w1
		mov #(4096/NUM_WAVEFORMS)+1,w2
		repeat #17
		div.u w0,w2
		pop w1
		exch w0,w1
		mov #DCOFreqLFO,w3
		add w0,w3,w0
		rcall SetLFOWaveform
		return

; pitch LFO frequency
do_pitch_LFO_freq:
		rcall lfo_freq_lin2log
		exch w0,w1
		mov #DCOFreqLFO,w3
		add w0,w3,w0
		rcall SetLFOFrequency
		return

; pitch LFO amplitude
do_pitch_LFO_amp:
		rcall amp_lin2log
		exch w0,w1
		mov #DCOFreqLFO,w3
		add w0,w3,w0
		rcall SetLFOAmplitude
		return

; DCO pitch
do_DCO_pitch:
.equ QUIESCENT, 25
		rcall dco_freq_lin2log
		exch w0,w1
		mov #QUIESCENT,w2
		mov w2,[w0+DCOTimer]
		rcall SetDCOFrequency
		return

; DCO amplitude
do_DCO_amp:
		rcall amp_lin2log
		exch w0,w1
		rcall SetDCOAmplitude
		return

; amplitude LFO pulse width
do_amp_LFO_pulse:
		exch w0,w1
		mov #DCOAmpLFO,w3
		add w0,w3,w0
		rcall SetLFOPulseWidth
		return

; amplitude LFO waveform
do_amp_LFO_wave:
		push w1
		mov #(4096/NUM_WAVEFORMS)+1,w2
		repeat #17
		div.u w0,w2
		pop w1
		exch w0,w1
		mov #DCOAmpLFO,w3
		add w0,w3,w0
		rcall SetLFOWaveform
		return

; amplitude LFO frequency
do_amp_LFO_freq:
		rcall lfo_freq_lin2log
		exch w0,w1
		mov #DCOAmpLFO,w3
		add w0,w3,w0
		rcall SetLFOFrequency
		return

; amplitude LFO amplitude
do_amp_LFO_amp:
		rcall amp_lin2log
		exch w0,w1
		mov #DCOAmpLFO,w3
		add w0,w3,w0
		rcall SetLFOAmplitude
		return

; DCO pulse width
do_DCO_pulse:
		exch w0,w1
		mov #QUIESCENT,w2
		mov w2,[w0+DCOTimer]
		rcall SetDCOPulseWidth
		return

; pitch LFO pulse width
do_pitch_LFO_pulse:
		exch w0,w1
		mov #DCOFreqLFO,w3
		add w0,w3,w0
		rcall SetLFOPulseWidth
		return

; ring modulation/frequency modulation on DCOs #0 and #1
do_RM_FM_01:
		mov #(4096/3)+1,w2
		repeat #17
		div.u w0,w2
		bclr SysFlags,#RING_MODULATION_01
		bclr SysFlags,#FREQ_MODULATION_01
		cp0 w0
		bra z,1f
		cp w0,#1
		bra nz,$+4
		bset SysFlags,#RING_MODULATION_01
		bra z,$+4
		bset SysFlags,#FREQ_MODULATION_01
1:		return

; reverb feedback
do_reverb_feedback:
		bclr SysFlags,#DELAY_FEEDBACK
		btsc w0,#11
		bset SysFlags,#DELAY_FEEDBACK
		return

; ring modulation/frequency modulation on DCOs #2 and #3
do_RM_FM_23:
		mov #(4096/3)+1,w2
		repeat #17
		div.u w0,w2
		bclr SysFlags,#RING_MODULATION_23
		bclr SysFlags,#FREQ_MODULATION_23
		cp0 w0
		bra z,1f
		cp w0,#1
		bra nz,$+4
		bset SysFlags,#RING_MODULATION_23
		bra z,$+4
		bset SysFlags,#FREQ_MODULATION_23
1:		return

; reverb period
do_reverb_period:
		rcall SetReverbPeriod
		return

; reverb level
do_reverb_level:
		rcall SetReverbLevel
		return

; reverb LFO pulse width
do_reverb_LFO_pulse:
		mov w0,w1
		mov #ReverbLFO,w0
		rcall SetLFOPulseWidth
		return

; reverb LFO waveform
do_reverb_LFO_wave:
		mov #(4096/NUM_WAVEFORMS)+1,w2
		repeat #17
		div.u w0,w2
		mov w0,w1
		mov #ReverbLFO,w0
		rcall SetLFOWaveform
		return

; reverb LFO frequency
do_reverb_LFO_freq:
		rcall lfo_freq_lin2log
		mov w0,w1
		mov #ReverbLFO,w0
		rcall SetLFOFrequency
		return

; reverb LFO amplitude
do_reverb_LFO_amp:
		rcall amp_lin2log
		mov w0,w1
		mov #ReverbLFO,w0
		rcall SetLFOAmplitude
		return

; master volume
do_master_volume:
		mov #(4096/(MAX_MASTER_VOLUME-MIN_MASTER_VOLUME))+1,w2
		repeat #17
		div.u w0,w2
		mov #MIN_MASTER_VOLUME,w1
		add w0,w1,w0
		mov w0,MasterVolume
		return

; fuzz (hard clipping)
do_fuzz_level:
		rcall SetFuzzLevel
		return

; additive synthesis
do_add_synth:
		bclr SysFlags,#ADDITIVE_SYNTHESIS
		btsc w0,#11
		bset SysFlags,#ADDITIVE_SYNTHESIS
		return

; flanger frequency
do_flanger_freq:
		rcall lfo_freq_lin2log
		rcall SetFlangerFrequency
		return

; flanger amplitude
do_flanger_amp:
		rcall amp_lin2log
		rcall SetFlangerAmplitude
		return

; flanger pulse width
do_flanger_pulse:
		rcall SetFlangerPulseWidth
		return

; flanger waveform
do_flanger_wave:
		mov #(4096/NUM_WAVEFORMS)+1,w2
		repeat #17
		div.u w0,w2
		rcall SetFlangerWaveform
		return

; flanger base
do_flanger_base:
		rcall amp_lin2log
		rcall SetFlangerBase
		return


;---------------------------------------------------------------------------
; SetMode - sets the mode
;
; Entry:	w0.b = mode: 0 to 11
;
; Exit: 	-
;
; Uses:	w0, w1
;---------------------------------------------------------------------------

.global SetMode
SetMode:

		cp.b Mode						; no change ?
		bra z,2f						; branch if yes

		mov.b w0,w1
		xor.b Mode,wreg
		and.b #~1,w0
		mov.b w1,w0
		bra z,1f

		clr.b pattern
		clr.b pattern_tmr

1:		mov.b wreg,Mode

		ze w0,w0
		mul.uu w0,#6<<1,w0
		mov #controls,w1
		add w1,w0,w1

		mov [w1++],w0
		subr presets+0*2,wreg
		mov w0,presets_offset+0*2
		mov [w1++],w0
		subr presets+1*2,wreg
		mov w0,presets_offset+1*2
		mov [w1++],w0
		subr presets+2*2,wreg
		mov w0,presets_offset+2*2
		mov [w1++],w0
		subr presets+3*2,wreg
		mov w0,presets_offset+3*2
		mov [w1++],w0
		subr presets+4*2,wreg
		mov w0,presets_offset+4*2
		mov [w1++],w0
		subr presets+5*2,wreg
		mov w0,presets_offset+5*2

2:		return


;---------------------------------------------------------------------------
; PollButtons - polls the pushbuttons
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

.global PollButtons
PollButtons:

		clr.b w0

		.if NOISE_X
		btss PORTB,#S1
		bset w0,#0
		btss PORTA,#S2
		bset w0,#1
		btss PORTA,#S3
		bset w0,#2
		btss PORTB,#S4
		bset w0,#3
		btss PORTA,#S5
		bset w0,#4
		btss PORTB,#S6
		bset w0,#5
		.endif
		.if KRELL
		btss PORTB,#S1
		bset w0,#0
		btss PORTB,#S2
		bset w0,#1
		btss PORTB,#S3
		bset w0,#2
		btss PORTB,#S4
		bset w0,#3
		btss PORTB,#S5
		bset w0,#4
		btss PORTB,#S6
		bset w0,#5
		.endif

		mov.b wreg,buttons

		return


;---------------------------------------------------------------------------
; amp_lin2log - converts a 12-bit linear value to a logarithmic value
;
; Entry:	w0 = linear value: 0 to 4095
;
; Exit: 	w0 = logarithmic value (unsigned 1.15 fraction)
;
; Uses:	-
;---------------------------------------------------------------------------

amp_lin2log:

		push w1

		mov #psvoffset(lin2log),w1
		lsr w0,#3,w0
		sl w0,w0
		mov [w1+w0],w0
		bclr w0,#15

		pop w1

		return


;---------------------------------------------------------------------------
; dco_freq_lin2log - converts a 12-bit linear value to a logarithmic value
;
; Entry:	w0 = linear value: 0 to 4095
;
; Exit: 	w0 = logarithmic value (Hz)
;
; Uses:	RCOUNT
;---------------------------------------------------------------------------

dco_freq_lin2log:

		push w1
		push w2

		mov #(4096/8),w2
		repeat #17
		div.u w0,w2

		mov #LO_FREQUENCY,w2
		sl w2,w0,w0

		mov #psvoffset(lin2log),w2
		sl w1,w1
		mov [w2+w1],w1

		mul.uu w1,w0,w0
		sl w0,w0
		rlc w1,w1

		mov w1,w0

		pop w2
		pop w1

		return


;---------------------------------------------------------------------------
; lfo_freq_lin2log - converts a 12-bit linear value to a logarithmic value
;
; Entry:	w0 = linear value: 0 to 4095
;
; Exit: 	w0 = logarithmic value (unsigned 8.8 fraction)
;
; Uses:	RCOUNT
;---------------------------------------------------------------------------

lfo_freq_lin2log:

		push w1

		mov #psvoffset(lin2log),w1
		lsr w0,#3,w0
		sl w0,w0
		mov [w1+w0],w0
		bclr w0,#15

		lsr w0,#4,w0

		mov #LFO_MIN_FREQUENCY,w1
		cp w0,w1
		bra geu,$+4
		mov w1,w0

		mov #LFO_MAX_FREQUENCY,w1
		cp w0,w1
		bra leu,$+4
		mov w1,w0

		pop w1

		return


;---------------------------------------------------------------------------
; SetVolume - sets the volume
;
; Entry:	w0 = volume
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

.global SetVolume
SetVolume:

		push w1

		mov w0,MasterVolume

		sub #MIN_MASTER_VOLUME,w0
		mov #4095/(MAX_MASTER_VOLUME-MIN_MASTER_VOLUME),w1
		mul.uu w0,w1,w0
		mov w0,controls+10*(6<<1)+0

		pop w1

		return


;---------------------------------------------------------------------------
; ResetControls - resets all controls
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0 - w2
;---------------------------------------------------------------------------

.global ResetControls
ResetControls:

		push ACCAU
		push ACCAH
		push ACCAL
		push RCOUNT

		bclr SysFlags,#RING_MODULATION_01
		bclr SysFlags,#RING_MODULATION_23
		bclr SysFlags,#FREQ_MODULATION_01
		bclr SysFlags,#FREQ_MODULATION_23
		bclr SysFlags,#ADDITIVE_SYNTHESIS
		bclr SysFlags,#DELAY_FEEDBACK

		mov.b #0,w0					; initialise DCOs
1:		push w0
		rcall GetDCO
		rcall InitDCO
		pop w0
		inc.b w0,w0
		cp.b w0,#NUM_DCOS
		bra ltu,1b

		rcall InitFlanger				; initialise flanger

		rcall InitReverb				; initialise reverb

		mov #FUZZ_MIN,w0
		mov w0,FuzzLevel

		mov #controls,w0				; reset controls
		repeat #NUM_CONTROLS-1
		clr [w0++]

		mov #1<<11,w0					; master volume
		mov w0,controls+10*(6<<1)+0
		mov #DEF_MASTER_VOLUME,w0
		mov w0,MasterVolume

		pop RCOUNT
		pop ACCAL
		pop ACCAH
		pop ACCAU

		return


;---------------------------------------------------------------------------
; SetControl - sets a control to a value
;
; Entry:	w0 = control value (12 bits)
;		w1 = control number (0 to 71)
;
; Exit: 	-
;
; Uses:	w0 - w1
;---------------------------------------------------------------------------

.global SetControl
SetControl:

		push w2

		mov #controls,w2
		add w2,w1,w2
		add w2,w1,w2
		mov w0,[w2]

		rcall do_control

		pop w2

		return


;---------------------------------------------------------------------------
; GetControl - gets a control value
;
; Entry:	w0 = control number (0 to 71)
;
; Exit: 	w0 = control value (12 bits)
;
; Uses:	-
;---------------------------------------------------------------------------

.global GetControl
GetControl:

		push w1

		mov #controls,w1
		add w1,w0,w1
		add w1,w0,w1
		mov [w1],w0

		pop w1

		return


;---------------------------------------------------------------------------
; SetProgram - sets a program
;
; Entry:	w0 = program number (0 = user, 1 onwards = demo)
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

.global SetProgram
SetProgram:

		push w1
		push.d w2
		push.d w4
		push ACCAU
		push ACCAH
		push ACCAL
		push RCOUNT

		mov #tbloffset(Settings),w4
		cp w0,#0
		bra z,1f

		mov #tbloffset(Demo1),w4
		cp w0,#1
		bra z,1f
		mov #tbloffset(Demo2),w4
		cp w0,#2
		bra z,1f
		mov #tbloffset(Demo3),w4
		cp w0,#3
		bra z,1f
		mov #tbloffset(Demo4),w4
		cp w0,#4
		bra z,1f
		mov #tbloffset(Demo5),w4
		cp w0,#5
		bra z,1f
		mov #tbloffset(Demo6),w4
		cp w0,#6
		bra z,1f
		mov #tbloffset(Demo7),w4
		cp w0,#7
		bra z,1f
		mov #tbloffset(Demo8),w4
		cp w0,#8
		bra z,1f
		mov #tbloffset(Demo9),w4
		cp w0,#9
		bra z,1f
		mov #tbloffset(Demo10),w4
		cp w0,#10
		bra z,1f
		mov #tbloffset(Demo11),w4
		cp w0,#11
		bra z,1f
		mov #tbloffset(Demo12),w4
		cp w0,#12
		bra z,1f
		mov #tbloffset(Demo13),w4
		cp w0,#13
		bra z,1f
		mov #tbloffset(Demo14),w4
		cp w0,#14
		bra z,1f
		bra 2f

1:		rcall LoadSettings

2:		pop RCOUNT
		pop ACCAL
		pop ACCAH
		pop ACCAU
		pop.d w4
		pop.d w2
		pop w1

		return


;---------------------------------------------------------------------------
; SaveSettings - saves settings to program memory
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0 - w5
;---------------------------------------------------------------------------

.global SaveSettings
SaveSettings:

		bclr INTCON2,#GIE				; disable interrupts

		push TBLPAG

		mov #tblpage(Settings),w0
		mov w0,NVMADRU
		mov #tbloffset(Settings),w0
		mov w0,NVMADR

		mov #0b0100000000000011,w0		; memory page erase operation
		mov w0,NVMCON

		clrwdt

		mov #0x55,w0
		mov w0,NVMKEY
		mov #0xaa,w0
		mov w0,NVMKEY

		bset NVMCON,#WR				; erase memory page
		nop
		nop

1:		btsc NVMCON,#WR
		bra 1b

		mov #controls,w5
		mov #NUM_CONTROLS/4,w4

2:		mov #tblpage(WRITE_LATCHES),w3
		movpag w3,TBLPAG
		mov #tbloffset(WRITE_LATCHES),w3

		mov [w5++],w0					; pack into 24 bits
		mov [w5++],w1
		mov #0x0f00,w2
		and w0,w2,w2
		sl w2,#4,w2
		ior w1,w2,w1

		tblwth w0,[w3]					; set latches
		tblwtl w1,[w3++]

		mov [w5++],w0					; pack into 24 bits
		mov [w5++],w1
		mov #0x0f00,w2
		and w0,w2,w2
		sl w2,#4,w2
		ior w1,w2,w1

		tblwth w0,[w3]					; set latches
		tblwtl w1,[w3++]

		mov #0b0100000000000001,w0		; memory double-word program operation
		mov w0,NVMCON

		clrwdt

		mov #0x55,w0
		mov w0,NVMKEY
		mov #0xaa,w0
		mov w0,NVMKEY

		bset NVMCON,#WR				; program double-word
		nop
		nop

3:		btsc NVMCON,#WR
		bra 3b

		inc2 NVMADR
		inc2 NVMADR

		mov NVMADR,w0					; precaution
		mov #tbloffset(Settings),w1
		xor w0,w1,w0
		mov #~(ERASE_PAGE-1),w1
		and w0,w1,w0
		bra nz,4f

		ze w4,w4						; precaution

		dec w4,w4						; loop for all double-words
		bra nz,2b

		mov.b #0,w0
		rcall SetMode

4:		delay 20						; wait for pushbuttons to be released
		rcall PollButtons
		cp0.b buttons
		bra nz,4b

		pop TBLPAG

		rcall InitADC

		bset INTCON2,#GIE				; enable interrupts

		rcall InitPresets

		return


;---------------------------------------------------------------------------
; LoadSettings - loads settings from program memory
;
; Entry:	w4 = settings address
;
; Exit: 	-
;
; Uses:	w0 - w5, A, RCOUNT
;---------------------------------------------------------------------------

.global LoadSettings
LoadSettings:

		bclr INTCON2,#GIE				; disable interrupts

		rcall ResetControls				; reset controls

		mov #controls,w5
		mov #NUM_CONTROLS/2,w3

1:		tblrdh [w4],w0					; unpack from 24 bits
		ze w0,w0
		tblrdl [w4++],w1
		mov w1,w2
		lsr w2,#4,w2
		clr.b w2
		ior w0,w2,w0
		mov #0x0fff,w2
		and w1,w2,w1

		mov w0,[w5++]
		mov w1,[w5++]

		dec w3,w3
		bra nz,1b

		mov.b #0,w0					; initialise DCOs
2:		push w0
		rcall GetDCO
		rcall InitDCO
		pop w0
		inc.b w0,w0
		cp.b w0,#NUM_DCOS
		bra ltu,2b

		rcall InitFlanger				; initialise flanger

		rcall InitReverb				; initialise reverb

		mov #FUZZ_MIN,w0
		mov w0,FuzzLevel

		mov.b #0,w0
3:		push w0
		mov.b wreg,Mode
		ze w0,w0
		mul.uu w0,#6<<1,w0
		mov #controls,w4
		add w4,w0,w4
		rcall do_VR1
		rcall do_VR2
		rcall do_VR3
		rcall do_VR4
		rcall do_VR5
		rcall do_VR6
		pop w0
		inc.b w0,w0
		cp.b w0,#NUM_MODES
		bra ltu,3b

		mov.b #0,w0
		rcall SetMode

		rcall InitADC

		bset INTCON2,#GIE				; enable interrupts

4:		delay 20						; wait for pushbuttons to be released
		rcall PollButtons
		cp0.b buttons
		bra nz,4b

		rcall InitPresets

		return


;---------------------------------------------------------------------------
; trap handlers
;---------------------------------------------------------------------------

.global __ReservedTrap0
__ReservedTrap0:
		reset

.global __OscillatorFail
__OscillatorFail:
		reset

.global __AddressError
__AddressError:
		reset

.global __StackError
__StackError:
		bra trap

.global __MathError
__MathError:
		reset

.global __DMACError
__DMACError:
		reset

.global __ReservedTrap5
__ReservedTrap5:
		reset

.global __ReservedTrap6
__ReservedTrap6:
		reset

.global __ReservedTrap7
__ReservedTrap7:
		reset

trap:
		.ifdef __DEBUG
		bclr T3CON,#TON
1:		rcall FlashLEDs
		bra 1b
		.endif

		reset


;---------------------------------------------------------------------------
; FlashLEDs - flashes all LEDs
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	DO x 1, RCOUNT
;---------------------------------------------------------------------------

.global FlashLEDs
FlashLEDs:

		LED1_on
		LED2_on
		LED3_on
		LED4_on

		delay 100

		LED1_off
		LED2_off
		LED3_off
		LED4_off

		delay 100

		return


;---------------------------------------------------------------------------
; InitLEDs - initialises running LED patterns
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

InitLEDs:

.equ TICK_FREQ, 1000

		clr.b pattern
		clr.b pattern_tmr

		mov #0b0000000000110000,w0		; initialise Timer3 - internal clock,
		mov w0,T3CON					; prescale 1:256

		clr TMR3

		mov #(CLOCK/2)/256/TICK_FREQ,w0
		mov w0,PR3

		bclr IPC2,#T3IP2				; interrupt priority = 2
		bset IPC2,#T3IP1
		bclr IPC2,#T3IP0

		bclr IFS0,#T3IF				; enable timer interrupt
		bset IEC0,#T3IE

		bset T3CON,#TON				; timer on

		clr Ticks						; initialise ticks counter

		return


;---------------------------------------------------------------------------
; Timer #3 isr
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	-
;---------------------------------------------------------------------------

.global __T3Interrupt
__T3Interrupt:

		push w0

		rcall DoLEDs

		inc Ticks						; ticks counter

		bclr IFS0,#T3IF				; clear interrupt

		pop w0

		retfie


;---------------------------------------------------------------------------
; DoLEDs - displays running LED patterns
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0
;---------------------------------------------------------------------------

DoLEDs:

.equ LED_SPEED, 180

		inc.b pattern_tmr
		mov.b #LED_SPEED,w0
		cp.b pattern_tmr
		bra ltu,1f
		clr.b pattern_tmr

		LED1_off
		LED2_off
		LED3_off
		LED4_off

		mov.b Mode,wreg
		lsr.b w0,w0
		cp.b w0,#0
		bra z,led0
		cp.b w0,#1
		bra z,led1
		cp.b w0,#2
		bra z,led2
		cp.b w0,#3
		bra z,led3
		cp.b w0,#4
		bra z,led4
		cp.b w0,#5
		bra z,led5

		bra 1f

led0:	mov.b pattern,wreg
		cp.b w0,#0
		bra nz,$+4
		LED1_on
		cp.b w0,#1
		bra nz,$+4
		LED2_on
		cp.b w0,#2
		bra nz,$+4
		LED3_on
		cp.b w0,#3
		bra nz,$+4
		LED4_on

		inc.b pattern
		mov.b #4,w0
		cp.b pattern
		bra nz,$+4
		clr.b pattern

		bra 1f

led1:	mov.b pattern,wreg
		cp.b w0,#0
		bra nz,$+4
		LED4_on
		cp.b w0,#1
		bra nz,$+4
		LED3_on
		cp.b w0,#2
		bra nz,$+4
		LED2_on
		cp.b w0,#3
		bra nz,$+4
		LED1_on

		inc.b pattern
		mov.b #4,w0
		cp.b pattern
		bra nz,$+4
		clr.b pattern

		bra 1f

led2:	mov.b pattern,wreg
		cp.b w0,#0
		bra nz,$+4
		LED1_on
		cp.b w0,#1
		bra nz,$+4
		LED2_on
		cp.b w0,#2
		bra nz,$+4
		LED3_on
		cp.b w0,#3
		bra nz,$+4
		LED4_on
		cp.b w0,#4
		bra nz,$+4
		LED3_on
		cp.b w0,#5
		bra nz,$+4
		LED2_on

		inc.b pattern
		mov.b #6,w0
		cp.b pattern
		bra nz,$+4
		clr.b pattern

		bra 1f

led3:	mov.b pattern,wreg
		cp.b w0,#0
		bra nz,$+6
		LED1_on
		LED2_on
		cp.b w0,#1
		bra nz,$+6
		LED2_on
		LED3_on
		cp.b w0,#2
		bra nz,$+6
		LED3_on
		LED4_on
		cp.b w0,#3
		bra nz,$+6
		LED2_on
		LED3_on

		inc.b pattern
		mov.b #4,w0
		cp.b pattern
		bra nz,$+4
		clr.b pattern

		bra 1f

led4:	mov.b pattern,wreg
		cp.b w0,#0
		bra nz,$+6
		LED1_on
		LED2_on
		cp.b w0,#1
		bra nz,$+6
		LED3_on
		LED4_on

		inc.b pattern
		mov.b #2,w0
		cp.b pattern
		bra nz,$+4
		clr.b pattern

		bra 1f

led5:	mov.b pattern,wreg
		cp.b w0,#0
		bra nz,$+6
		LED1_on
		LED4_on
		cp.b w0,#1
		bra nz,$+6
		LED2_on
		LED3_on

		inc.b pattern
		mov.b #2,w0
		cp.b pattern
		bra nz,$+4
		clr.b pattern

1:		return


;---------------------------------------------------------------------------
; InitHardware - global hardware initialisation
;
; Entry:	-
;
; Exit: 	-
;
; Uses:	w0 - w3
;---------------------------------------------------------------------------

InitHardware:

		mov #42-2,w0					; PLL multiplier (M) = 42
		mov w0,PLLFBD
		mov #~(0b11<<6),w0				; PLL postscaler (N2) = 2
		and CLKDIV
		mov #~(0b11111<<0),w0			; PLL prescaler (N1) = 2
		and CLKDIV

.equ FRCPLL, 0b001

		disi #16

		mov.b #FRCPLL,w0

		mov #OSCCONH,w1				; unlock high byte
		mov #0x78,w2
		mov #0x9a,w3
		mov.b w2,[w1]
		mov.b w3,[w1]

		mov.b w0,[w1]					; select internal FRC with PLL

		mov.b #1<<OSWEN,w0

		mov #OSCCONL,w1				; unlock low byte
		mov #0x46,w2
		mov #0x57,w3
		mov.b w2,[w1]
		mov.b w3,[w1]

		mov.b w0,[w1]					; clock switch

;		repeat #0x2000-1
;		nop

1:		clrwdt						; wait for clock switch
		mov #0b111<<12,w0
		and OSCCON,wreg
		mov #FRCPLL<<12,w1
		cp w1,w0
		bra nz,1b

2:		clrwdt						; wait for PLL to lock
		btss OSCCON,#LOCK
		bra 2b

		clr ANSELA					; digital pins
		clr ANSELB

		clr ODCA						; disable open-drains
		clr ODCB

		.if NOISE_X					; LEDs
		bclr TRISB,#LED1
		bclr TRISB,#LED2
		bclr TRISB,#LED3
		bclr TRISB,#LED4
		.endif
		.if KRELL
		bclr TRISB,#LED1
		bclr TRISA,#LED2
		bclr TRISB,#LED3
		bclr TRISB,#LED4
		.endif

		.if NOISE_X
		bclr LATB,#LED1
		bclr LATB,#LED2
		bclr LATB,#LED3
		bclr LATB,#LED4
		.endif
		.if KRELL
		bclr LATB,#LED1
		bclr LATA,#LED2
		bclr LATB,#LED3
		bclr LATB,#LED4
		.endif

		.if NOISE_X					; pushbuttons
		bset TRISB,#S1
		bset TRISA,#S2
		bset TRISA,#S3
		bset TRISB,#S4
		bset TRISA,#S5
		bset TRISB,#S6
		.endif
		.if KRELL
		bset TRISB,#S1
		bset TRISB,#S2
		bset TRISB,#S3
		bset TRISB,#S4
		bset TRISB,#S5
		bset TRISB,#S6
		.endif

		.if KRELL
		bset TRISA,#MSEL				; CLI/MIDI select
		.endif

		clr CNPUA						; enable weak pull-ups
		clr CNPUB
		.if NOISE_X
		bset CNPUB,#S1
		bset CNPUA,#S2
		bset CNPUA,#S3
		bset CNPUB,#S4
		bset CNPUA,#S5
		bset CNPUB,#S6
		.endif
		.if KRELL
		bset CNPUB,#S1
		bset CNPUB,#S2
		bset CNPUB,#S3
		bset CNPUB,#S4
		bset CNPUB,#S5
		bset CNPUB,#S6
		bset CNPUA,#MSEL
		.endif

		clr CNPDA						; disable weak pull-downs
		clr CNPDB

		clr CNENA
		clr CNENB

		mov #OSCCONL,w0				; remap peripherals
		mov #0x46,w1
		mov #0x57,w2
		mov.b w1,[w0]
		mov.b w2,[w0]
		bclr OSCCON,#IOLOCK

		.if DAC_AUDIO
		mov #(0b0000000<<8)|0b0100110,w0	; SPI2 data input (RP38)
		mov w0,RPINR22
		mov #(0b001001<<8)|0b001000,w0	; SPI2 clock output (RP39), data output (RP38)
		mov w0,RPOR2
		.endif

		mov #OSCCONL,w0				; re-lock
		mov #0x46,w1
		mov #0x57,w2
		mov.b w1,[w0]
		mov.b w2,[w0]
		bset OSCCON,#IOLOCK

		bset CORCON,#ACCSAT				; enable accumulator saturation
		bset CORCON,#SATA
		bset CORCON,#SATB
		bset CORCON,#SATDW				; enable write saturation
		bclr CORCON,#RND				; unbiased rounding
		bclr CORCON,#US0 				; signed multiplications
		bclr CORCON,#US1

		mov #1<<9,w0
		mov w0,DSRPAG
		clr TBLPAG

		setm PMD1						; disable unused peripherals
		bclr PMD1,#AD1MD
;		bclr PMD1,#SPI1MD
		.if DAC_AUDIO
		bclr PMD1,#SPI2MD
		.endif
		bclr PMD1,#U1MD
;		bclr PMD1,#U2MD
;		bclr PMD1,#I2C1MD
		.if PWM_AUDIO
		bclr PMD1,#PWMMD
		.endif
;		bclr PMD1,#QEI1MD
		bclr PMD1,#T1MD
		bclr PMD1,#T2MD
		bclr PMD1,#T3MD
;		bclr PMD1,#T4MD
;		bclr PMD1,#T5MD

		setm PMD2
;		bclr PMD2,#OC1MD
;		bclr PMD2,#OC2MD
;		bclr PMD2,#OC3MD
;		bclr PMD2,#OC4MD
;		bclr PMD2,#IC1MD
;		bclr PMD2,#IC2MD
;		bclr PMD2,#IC3MD
;		bclr PMD2,#IC4MD

		setm PMD3
;		bclr PMD3,#I2C2MD
;		bclr PMD3,#CRCMD
;		bclr PMD3,#CMPMD

		setm PMD4
;		bclr PMD4,#CTMUMD
;		bclr PMD4,#REFOMD

		setm PMD6
		.if PWM_AUDIO
		bclr PMD6,#PWM1MD
		.endif
;		bclr PMD6,#PWM2MD
;		bclr PMD6,#PWM3MD

		setm PMD7
;		bclr PMD7,#PTGMD
		bclr PMD7,#DMA0MD
;		bclr PMD7,#DMA1MD
;		bclr PMD7,#DMA2MD
;		bclr PMD7,#DMA3MD

		return


;---------------------------------------------------------------------------
; saved user settings
;---------------------------------------------------------------------------

.section .text
.align ERASE_PAGE

Settings:
	.fill ERASE_PAGE,1,0


;---------------------------------------------------------------------------
; variables
;---------------------------------------------------------------------------

.section .ndata,data,near
.align 2

.global SysFlags, MasterVolume, Mode
SysFlags:			.word 0					; system flags
MasterVolume:		.word DEF_MASTER_VOLUME		; master volume
Mode:			.byte -1					; current mode: 0 to 11 (lsb = shift)
bank1:			.byte 0					; demo banks
bank2:			.byte 0
bank3:			.byte 0


.section .nbss,bss,near
.align 2

.global Ticks
Ticks:			.space 2					; ticks counter
presets_prev:		.space 6<<1				; previous presets
presets_offset:	.space 6<<1				; preset offsets
controls:			.space NUM_CONTROLS<<1		; control settings
pattern:			.space 1					; running LEDs pattern
pattern_tmr:		.space 1					; pattern timer
buttons:			.space 1					; pushbuttons pressed


.end
