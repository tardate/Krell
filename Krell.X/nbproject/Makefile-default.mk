#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-default.mk)" "nbproject/Makefile-local-default.mk"
include nbproject/Makefile-local-default.mk
endif
endif

# Environment
MKDIR=gnumkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=elf
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/Krell.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/Krell.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

ifeq ($(COMPARE_BUILD), true)
COMPARISON_BUILD=
else
COMPARISON_BUILD=
endif

ifdef SUB_IMAGE_ADDRESS

else
SUB_IMAGE_ADDRESS_COMMAND=
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=main.s adc.s dac.s dco.s demos.s flanger.s lfo.s lin2log.s mixer.s reverb.s waveforms.s midi.s cli.s uart.s

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/main.o ${OBJECTDIR}/adc.o ${OBJECTDIR}/dac.o ${OBJECTDIR}/dco.o ${OBJECTDIR}/demos.o ${OBJECTDIR}/flanger.o ${OBJECTDIR}/lfo.o ${OBJECTDIR}/lin2log.o ${OBJECTDIR}/mixer.o ${OBJECTDIR}/reverb.o ${OBJECTDIR}/waveforms.o ${OBJECTDIR}/midi.o ${OBJECTDIR}/cli.o ${OBJECTDIR}/uart.o
POSSIBLE_DEPFILES=${OBJECTDIR}/main.o.d ${OBJECTDIR}/adc.o.d ${OBJECTDIR}/dac.o.d ${OBJECTDIR}/dco.o.d ${OBJECTDIR}/demos.o.d ${OBJECTDIR}/flanger.o.d ${OBJECTDIR}/lfo.o.d ${OBJECTDIR}/lin2log.o.d ${OBJECTDIR}/mixer.o.d ${OBJECTDIR}/reverb.o.d ${OBJECTDIR}/waveforms.o.d ${OBJECTDIR}/midi.o.d ${OBJECTDIR}/cli.o.d ${OBJECTDIR}/uart.o.d

# Object Files
OBJECTFILES=${OBJECTDIR}/main.o ${OBJECTDIR}/adc.o ${OBJECTDIR}/dac.o ${OBJECTDIR}/dco.o ${OBJECTDIR}/demos.o ${OBJECTDIR}/flanger.o ${OBJECTDIR}/lfo.o ${OBJECTDIR}/lin2log.o ${OBJECTDIR}/mixer.o ${OBJECTDIR}/reverb.o ${OBJECTDIR}/waveforms.o ${OBJECTDIR}/midi.o ${OBJECTDIR}/cli.o ${OBJECTDIR}/uart.o

# Source Files
SOURCEFILES=main.s adc.s dac.s dco.s demos.s flanger.s lfo.s lin2log.s mixer.s reverb.s waveforms.s midi.s cli.s uart.s


CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
ifneq ($(INFORMATION_MESSAGE), )
	@echo $(INFORMATION_MESSAGE)
endif
	${MAKE}  -f nbproject/Makefile-default.mk dist/${CND_CONF}/${IMAGE_TYPE}/Krell.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=33EP128MC202
MP_LINKER_FILE_OPTION=--script="..\..\..\Program Files (x86)\Microchip\MPLAB ASM30 Suite\Support\dsPIC33E\gld\p33EP128MC202.gld"
# ------------------------------------------------------------------------------------
# Rules for buildStep: assemble
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/main.o: main.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/main.o.d 
	@${RM} ${OBJECTDIR}/main.o.ok ${OBJECTDIR}/main.o.err 
	@${RM} ${OBJECTDIR}/main.o 
	@${FIXDEPS} "${OBJECTDIR}/main.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  main.s -o ${OBJECTDIR}/main.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/main.o.d" 
	
${OBJECTDIR}/adc.o: adc.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/adc.o.d 
	@${RM} ${OBJECTDIR}/adc.o.ok ${OBJECTDIR}/adc.o.err 
	@${RM} ${OBJECTDIR}/adc.o 
	@${FIXDEPS} "${OBJECTDIR}/adc.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  adc.s -o ${OBJECTDIR}/adc.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/adc.o.d" 
	
${OBJECTDIR}/dac.o: dac.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/dac.o.d 
	@${RM} ${OBJECTDIR}/dac.o.ok ${OBJECTDIR}/dac.o.err 
	@${RM} ${OBJECTDIR}/dac.o 
	@${FIXDEPS} "${OBJECTDIR}/dac.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  dac.s -o ${OBJECTDIR}/dac.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/dac.o.d" 
	
${OBJECTDIR}/dco.o: dco.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/dco.o.d 
	@${RM} ${OBJECTDIR}/dco.o.ok ${OBJECTDIR}/dco.o.err 
	@${RM} ${OBJECTDIR}/dco.o 
	@${FIXDEPS} "${OBJECTDIR}/dco.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  dco.s -o ${OBJECTDIR}/dco.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/dco.o.d" 
	
${OBJECTDIR}/demos.o: demos.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/demos.o.d 
	@${RM} ${OBJECTDIR}/demos.o.ok ${OBJECTDIR}/demos.o.err 
	@${RM} ${OBJECTDIR}/demos.o 
	@${FIXDEPS} "${OBJECTDIR}/demos.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  demos.s -o ${OBJECTDIR}/demos.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/demos.o.d" 
	
${OBJECTDIR}/flanger.o: flanger.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/flanger.o.d 
	@${RM} ${OBJECTDIR}/flanger.o.ok ${OBJECTDIR}/flanger.o.err 
	@${RM} ${OBJECTDIR}/flanger.o 
	@${FIXDEPS} "${OBJECTDIR}/flanger.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  flanger.s -o ${OBJECTDIR}/flanger.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/flanger.o.d" 
	
${OBJECTDIR}/lfo.o: lfo.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/lfo.o.d 
	@${RM} ${OBJECTDIR}/lfo.o.ok ${OBJECTDIR}/lfo.o.err 
	@${RM} ${OBJECTDIR}/lfo.o 
	@${FIXDEPS} "${OBJECTDIR}/lfo.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  lfo.s -o ${OBJECTDIR}/lfo.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/lfo.o.d" 
	
${OBJECTDIR}/lin2log.o: lin2log.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/lin2log.o.d 
	@${RM} ${OBJECTDIR}/lin2log.o.ok ${OBJECTDIR}/lin2log.o.err 
	@${RM} ${OBJECTDIR}/lin2log.o 
	@${FIXDEPS} "${OBJECTDIR}/lin2log.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  lin2log.s -o ${OBJECTDIR}/lin2log.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/lin2log.o.d" 
	
${OBJECTDIR}/mixer.o: mixer.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/mixer.o.d 
	@${RM} ${OBJECTDIR}/mixer.o.ok ${OBJECTDIR}/mixer.o.err 
	@${RM} ${OBJECTDIR}/mixer.o 
	@${FIXDEPS} "${OBJECTDIR}/mixer.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  mixer.s -o ${OBJECTDIR}/mixer.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/mixer.o.d" 
	
${OBJECTDIR}/reverb.o: reverb.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/reverb.o.d 
	@${RM} ${OBJECTDIR}/reverb.o.ok ${OBJECTDIR}/reverb.o.err 
	@${RM} ${OBJECTDIR}/reverb.o 
	@${FIXDEPS} "${OBJECTDIR}/reverb.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  reverb.s -o ${OBJECTDIR}/reverb.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/reverb.o.d" 
	
${OBJECTDIR}/waveforms.o: waveforms.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/waveforms.o.d 
	@${RM} ${OBJECTDIR}/waveforms.o.ok ${OBJECTDIR}/waveforms.o.err 
	@${RM} ${OBJECTDIR}/waveforms.o 
	@${FIXDEPS} "${OBJECTDIR}/waveforms.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  waveforms.s -o ${OBJECTDIR}/waveforms.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/waveforms.o.d" 
	
${OBJECTDIR}/midi.o: midi.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/midi.o.d 
	@${RM} ${OBJECTDIR}/midi.o.ok ${OBJECTDIR}/midi.o.err 
	@${RM} ${OBJECTDIR}/midi.o 
	@${FIXDEPS} "${OBJECTDIR}/midi.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  midi.s -o ${OBJECTDIR}/midi.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/midi.o.d" 
	
${OBJECTDIR}/cli.o: cli.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/cli.o.d 
	@${RM} ${OBJECTDIR}/cli.o.ok ${OBJECTDIR}/cli.o.err 
	@${RM} ${OBJECTDIR}/cli.o 
	@${FIXDEPS} "${OBJECTDIR}/cli.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  cli.s -o ${OBJECTDIR}/cli.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/cli.o.d" 
	
${OBJECTDIR}/uart.o: uart.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/uart.o.d 
	@${RM} ${OBJECTDIR}/uart.o.ok ${OBJECTDIR}/uart.o.err 
	@${RM} ${OBJECTDIR}/uart.o 
	@${FIXDEPS} "${OBJECTDIR}/uart.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  uart.s -o ${OBJECTDIR}/uart.o -omf=elf -p=$(MP_PROCESSOR_OPTION) --defsym=__DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 -g  -MD "${OBJECTDIR}/uart.o.d" 
	
else
${OBJECTDIR}/main.o: main.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/main.o.d 
	@${RM} ${OBJECTDIR}/main.o.ok ${OBJECTDIR}/main.o.err 
	@${RM} ${OBJECTDIR}/main.o 
	@${FIXDEPS} "${OBJECTDIR}/main.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  main.s -o ${OBJECTDIR}/main.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/main.o.d" 
	
${OBJECTDIR}/adc.o: adc.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/adc.o.d 
	@${RM} ${OBJECTDIR}/adc.o.ok ${OBJECTDIR}/adc.o.err 
	@${RM} ${OBJECTDIR}/adc.o 
	@${FIXDEPS} "${OBJECTDIR}/adc.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  adc.s -o ${OBJECTDIR}/adc.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/adc.o.d" 
	
${OBJECTDIR}/dac.o: dac.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/dac.o.d 
	@${RM} ${OBJECTDIR}/dac.o.ok ${OBJECTDIR}/dac.o.err 
	@${RM} ${OBJECTDIR}/dac.o 
	@${FIXDEPS} "${OBJECTDIR}/dac.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  dac.s -o ${OBJECTDIR}/dac.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/dac.o.d" 
	
${OBJECTDIR}/dco.o: dco.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/dco.o.d 
	@${RM} ${OBJECTDIR}/dco.o.ok ${OBJECTDIR}/dco.o.err 
	@${RM} ${OBJECTDIR}/dco.o 
	@${FIXDEPS} "${OBJECTDIR}/dco.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  dco.s -o ${OBJECTDIR}/dco.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/dco.o.d" 
	
${OBJECTDIR}/demos.o: demos.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/demos.o.d 
	@${RM} ${OBJECTDIR}/demos.o.ok ${OBJECTDIR}/demos.o.err 
	@${RM} ${OBJECTDIR}/demos.o 
	@${FIXDEPS} "${OBJECTDIR}/demos.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  demos.s -o ${OBJECTDIR}/demos.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/demos.o.d" 
	
${OBJECTDIR}/flanger.o: flanger.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/flanger.o.d 
	@${RM} ${OBJECTDIR}/flanger.o.ok ${OBJECTDIR}/flanger.o.err 
	@${RM} ${OBJECTDIR}/flanger.o 
	@${FIXDEPS} "${OBJECTDIR}/flanger.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  flanger.s -o ${OBJECTDIR}/flanger.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/flanger.o.d" 
	
${OBJECTDIR}/lfo.o: lfo.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/lfo.o.d 
	@${RM} ${OBJECTDIR}/lfo.o.ok ${OBJECTDIR}/lfo.o.err 
	@${RM} ${OBJECTDIR}/lfo.o 
	@${FIXDEPS} "${OBJECTDIR}/lfo.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  lfo.s -o ${OBJECTDIR}/lfo.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/lfo.o.d" 
	
${OBJECTDIR}/lin2log.o: lin2log.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/lin2log.o.d 
	@${RM} ${OBJECTDIR}/lin2log.o.ok ${OBJECTDIR}/lin2log.o.err 
	@${RM} ${OBJECTDIR}/lin2log.o 
	@${FIXDEPS} "${OBJECTDIR}/lin2log.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  lin2log.s -o ${OBJECTDIR}/lin2log.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/lin2log.o.d" 
	
${OBJECTDIR}/mixer.o: mixer.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/mixer.o.d 
	@${RM} ${OBJECTDIR}/mixer.o.ok ${OBJECTDIR}/mixer.o.err 
	@${RM} ${OBJECTDIR}/mixer.o 
	@${FIXDEPS} "${OBJECTDIR}/mixer.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  mixer.s -o ${OBJECTDIR}/mixer.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/mixer.o.d" 
	
${OBJECTDIR}/reverb.o: reverb.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/reverb.o.d 
	@${RM} ${OBJECTDIR}/reverb.o.ok ${OBJECTDIR}/reverb.o.err 
	@${RM} ${OBJECTDIR}/reverb.o 
	@${FIXDEPS} "${OBJECTDIR}/reverb.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  reverb.s -o ${OBJECTDIR}/reverb.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/reverb.o.d" 
	
${OBJECTDIR}/waveforms.o: waveforms.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/waveforms.o.d 
	@${RM} ${OBJECTDIR}/waveforms.o.ok ${OBJECTDIR}/waveforms.o.err 
	@${RM} ${OBJECTDIR}/waveforms.o 
	@${FIXDEPS} "${OBJECTDIR}/waveforms.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  waveforms.s -o ${OBJECTDIR}/waveforms.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/waveforms.o.d" 
	
${OBJECTDIR}/midi.o: midi.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/midi.o.d 
	@${RM} ${OBJECTDIR}/midi.o.ok ${OBJECTDIR}/midi.o.err 
	@${RM} ${OBJECTDIR}/midi.o 
	@${FIXDEPS} "${OBJECTDIR}/midi.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  midi.s -o ${OBJECTDIR}/midi.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/midi.o.d" 
	
${OBJECTDIR}/cli.o: cli.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/cli.o.d 
	@${RM} ${OBJECTDIR}/cli.o.ok ${OBJECTDIR}/cli.o.err 
	@${RM} ${OBJECTDIR}/cli.o 
	@${FIXDEPS} "${OBJECTDIR}/cli.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  cli.s -o ${OBJECTDIR}/cli.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/cli.o.d" 
	
${OBJECTDIR}/uart.o: uart.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/uart.o.d 
	@${RM} ${OBJECTDIR}/uart.o.ok ${OBJECTDIR}/uart.o.err 
	@${RM} ${OBJECTDIR}/uart.o 
	@${FIXDEPS} "${OBJECTDIR}/uart.o.d" $(SILENT) -rsi ${MP_AS_DIR}../  -c ${MP_AS} $(MP_EXTRA_AS_PRE)  uart.s -o ${OBJECTDIR}/uart.o -omf=elf -p=$(MP_PROCESSOR_OPTION)  -MD "${OBJECTDIR}/uart.o.d" 
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: link
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
dist/${CND_CONF}/${IMAGE_TYPE}/Krell.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    ../../../Program\ Files\ (x86)/Microchip/MPLAB\ ASM30\ Suite/Support/dsPIC33E/gld/p33EP128MC202.gld
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_LD} $(MP_EXTRA_LD_PRE)  ${OBJECTFILES_QUOTED_IF_SPACED}   -Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map" -omf=elf $(MP_LINKER_FILE_OPTION) --defsym=__MPLAB_DEBUG=1 --defsym=__MPLAB_DEBUGGER_PK3=1 --defsym=__ICD2RAM=1 -o dist/${CND_CONF}/${IMAGE_TYPE}/Krell.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX} 
else
dist/${CND_CONF}/${IMAGE_TYPE}/Krell.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   ../../../Program\ Files\ (x86)/Microchip/MPLAB\ ASM30\ Suite/Support/dsPIC33E/gld/p33EP128MC202.gld
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_LD} $(MP_EXTRA_LD_PRE)  ${OBJECTFILES_QUOTED_IF_SPACED}   -Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map" -omf=elf $(MP_LINKER_FILE_OPTION) --defsym=__MPLAB_DEBUG=1 -o dist/${CND_CONF}/${IMAGE_TYPE}/Krell.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX} 
	${MP_AS_DIR}\\pic30-bin2hex  dist/${CND_CONF}/${IMAGE_TYPE}/Krell.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX} -omf=elf
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/default
	${RM} -r dist/default

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(shell mplabwildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
