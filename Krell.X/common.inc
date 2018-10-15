/***************************************************************************
* FILE:      common.inc											*
* CONTENTS:  Common definitions									*
* COPYRIGHT: MadLab Ltd. 2012-18									*
* AUTHOR:    James Hutchby										*
* UPDATED:   12/07/18											*
***************************************************************************/


.equ DAC_AUDIO, 0					; non-zero if DAC audio output
.equ PWM_AUDIO, 1					; non-zero if PWM audio output

.equ NOISE_X, 0					; non-zero if Noise-X
.equ KRELL, 1						; non-zero if Krell

.equ CLOCK, 7370000*42/2/2			; system clock frequency in Hz
.equ MIPS, (CLOCK/2)/1000000			; million instructions per second

.equ ERASE_PAGE, 0x800				; erase page size
.equ WRITE_LATCHES, 0xfa0000			; RTSP write latches

.equ SAMPLE_RATE, 40000				; sample rate in samples/second
.equ WAVEFORM_SIZE, 256				; waveform size in words

.equ LO_FREQUENCY, 30				; lowest frequency in Hz
.equ HI_FREQUENCY, 30<<8				; highest frequency in Hz

.equ NUM_MODES, 6*2					; number of modes
.equ NUM_CONTROLS, NUM_MODES*6		; number of controls

.equ NUM_PROGRAMS, 14				; number of demo programs/patches

.equ NUM_DCOS, 4					; number of DCOs

.equ SILENCE, 0x0000				; no output (unsigned 1.15)
.equ MAX_AMPLITUDE, 0x8000			; maximum amplitude (unsigned 1.15)

.equ MIN_MASTER_VOLUME, 0			; minimum master volume
.equ MAX_MASTER_VOLUME, 16			; maximum master volume
.equ DEF_MASTER_VOLUME, 7			; default master volume

.equ FUZZ_MIN, 0x7fff				; minimum fuzz level
.equ FUZZ_MAX, 0x0200				; maximum fuzz level

; waveforms
.equ WAVEFORM_SINE, 0				; sine
.equ WAVEFORM_SQUARE, 1				; square
.equ WAVEFORM_TRIANGLE, 2			; triangle
.equ WAVEFORM_SAWTOOTH1, 3			; rising sawtooth
.equ WAVEFORM_SAWTOOTH2, 4			; falling sawtooth
.equ WAVEFORM_PULSE, 5				; pulse
.equ WAVEFORM_NOISE, 6				; noise

.equ NUM_WAVEFORMS, 7				; number of waveforms

; system flags
.equ RING_MODULATION_01, 0			; set if ring modulation enabled on DCOs #0 and #1
.equ RING_MODULATION_23, 1			; set if ring modulation enabled on DCOs #2 and #3
.equ FREQ_MODULATION_01, 2			; set if frequency modulation enabled on DCOs #0 and #1
.equ FREQ_MODULATION_23, 3			; set if frequency modulation enabled on DCOs #2 and #3
.equ ADDITIVE_SYNTHESIS, 4			; set if additive synthesis enabled
.equ DELAY_FEEDBACK, 5				; set if delay feedback enabled
.equ GAIN_2X, 6					; set if DAC output gain 2x
.equ MIDI_ENABLE, 7					; set if MIDI enabled
.equ CLI_ENABLE, 8					; set if CLI enabled


.macro struct
addr_ = 0
.endm
.macro member name, size = 0
\name = addr_
addr_ = addr_ + \size
.endm


; LFO structure
struct
member LFOWaveform, 1				; waveform
member LFOPad, 1					; pad
member LFOAmplitude, 2				; amplitude (unsigned 1.15)
member LFOFrequency, 2				; frequency in Hz (unsigned 8.8)
member LFOPulseWidth, 2				; pulse width
member LFOOffset, 2					; waveform offset (unsigned 8.8)
member LFOStep, 2					; waveform step (unsigned 8.8)
member LFOModulation, 2				; output modulation (signed 1.15)
member LFOSizeof					; size of structure

; amplitude limits
.equ LFO_MIN_AMPLITUDE, 0
.equ LFO_MAX_AMPLITUDE, 0x8000

; frequency limits
.equ LFO_MIN_FREQUENCY, 0
.equ LFO_MAX_FREQUENCY, 20<<8

; LFO update rate
.equ LFO_RATE, 1000


; DCO structure
struct
member DCOFlags, 1					; flags
member DCOWaveform, 1				; waveform
member DCOFunctionPnt, 2				; function pointer
member DCOAmplitude, 2				; amplitude (unsigned 1.15)
member DCOModAmplitude, 2			; modulated amplitude (unsigned 1.15)
member DCOFrequency, 2				; (fundamental) frequency in Hz
member DCOPulseWidth, 2				; pulse width
member DCOOffset, 2					; waveform offset (unsigned 8.8)
member DCOStep, 2					; waveform step (unsigned 8.8)
member DCOModStep, 2				; modulated step (unsigned 8.8)
member DCOTimer, 2					; quiescent timer
member DCOAmpLFO, LFOSizeof			; amplitude modulation (tremolo) LFO
member DCOFreqLFO, LFOSizeof			; frequency modulation (vibrato) LFO
member DCOSizeof					; size of structure

; flags
.equ DCO_LOCK_FREQ, 0				; set if frequency locked
