include config.txt

NON_HALAL_SDK_CC ?= ${PREFIX}-gcc
NON_HALAL_SDK_LD ?= ${PREFIX}-ld
NON_HALAL_SDK_OBJDUMP ?= ${PREFIX}-objdump
NON_HALAL_SDK_OBJCOPY ?= ${PREFIX}-objcopy
NON_HALAL_SDK_SIZE ?= ${PREFIX}-size
NON_HALAL_SDK_NM ?= ${PREFIX}-nm
NON_HALAL_SDK_AR ?= ${PREFIX}-ar

PROJECT_DIR = ${project}
CPU = ${cpu}

BUILD_FLAGS = ${FLAGS}
BUILD_FLAGS += -pedantic-errors \
	-Wall \
	-Wextra \
	-Wpedantic \
	-Wduplicated-branches \
	-Wduplicated-cond \
	-Wfloat-equal \
	-Wlogical-op \
	-Wsign-conversion \
	-Wrestrict \
	-Wno-comment \
	-ffunction-sections
BUILD_FLAGS += -${OPTIMIZATION_LEVEL}
BUILD_FLAGS += -D__STATIC_INLINE="static inline"
BUILD_FLAGS +="-mcpu=cortex-m7"
BUILD_FLAGS += -DSTM32H745xx
BUILD_FLAGS += -DCORE_CM7
BUILD_FLAGS += ${EXTRA_BUILD_FLAGS}
LINKER_FLAGS = --gc-sections
ifneq (${STDLIB_PATH},)
	LINKER_FLAGS += -L ${STDLIB_PATH}
endif
LINKER_FLAGS += ${EXTRA_LINKER_FLAGS}

INCLUDE_DIRS = \
	-include stdint.h \
	-ICore \
	-ICore/stm32h7xx_hal/inc/ \
	-ICore/stm32h7xx_hal/inc/Legacy \
	-ICore/system/include/cmsis
# add project include dirs if config.txt file exists
PRJ_SRC_DIRS = 
ifneq ($(wildcard ${PROJECT_DIR}/config.txt),)
    include ${PROJECT_DIR}/config.txt
    INCLUDE_DIRS += $(addprefix -I${PROJECT_DIR}/, ${PROJECT_INCLUDE_DIRS})
	PRJ_SRC_DIRS += $(addprefix ${PROJECT_DIR}/, ${PROJECT_SOURCES_DIRS})
endif

.PHONY: clear-libs
	if [ -f "Core/*.o" ]; then \
		rm Core/*.o; \
	fi
	if [ -d "Core/stm32h7xx_hal/build" ]; then \
		rm -r Core/stm32h7xx_hal/build; \
	fi
	if [ -f "Core/*.a" ]; then \
		rm Core/*.a; \
	fi

.PHONY: build-libs
build-libs:
	@echo "=====<Compiling startup files>==================="
	if [ -f "Core/*.o" ]; then \
		rm Core/*.o; \
	fi
	@for source in Core/startup/*.S; do \
 		OUT_FILENAME=`echo $$source | awk -F'/' '{print $$NF}'`; \
		echo "${NON_HALAL_SDK_CC} ${BUILD_FLAGS} -c $$source -o Core/$${OUT_FILENAME}.o"; \
 		${NON_HALAL_SDK_CC} ${BUILD_FLAGS} -c $$source -o Core/$${OUT_FILENAME}.o; \
 	done
	@echo "=====<Compiling STM32H7xx HAL>==================="
	if [ -d "Core/stm32h7xx_hal/build" ]; then \
		rm -r Core/stm32h7xx_hal/build; \
	fi
	mkdir Core/stm32h7xx_hal/build
	echo ${INCLUDE_DIRS}
	@for source in Core/stm32h7xx_hal/src/*.c; do \
		OUT_FILENAME=`echo $$source | awk -F'/' '{print $$NF}'`; \
		echo "${NON_HALAL_SDK_CC} ${BUILD_FLAGS} ${INCLUDE_DIRS} -c $$source -o Core/stm32h7xx_hal/build/$${OUT_FILENAME}.o"; \
 		${NON_HALAL_SDK_CC} ${BUILD_FLAGS} -Wno-comment -Wno-unused-parameter -Wno-sign-conversion ${INCLUDE_DIRS} -c $$source -o Core/stm32h7xx_hal/build/$${OUT_FILENAME}.o; \
 	done
	@echo "=====<Making an archive>========================="
	if [ -f "Core/libstm32-non-halal-sdk.a" ]; then \
		rm Core/libstm32-non-halal-sdk.a; \
	fi
	${NON_HALAL_SDK_AR} rcs Core/libstm32-non-halal-sdk.a Core/stm32h7xx_hal/build/*
	@echo "=====<Totals>===================================="
	${NON_HALAL_SDK_SIZE} -t --format=berkeley Core/*.o Core/libstm32-non-halal-sdk.a



.PHONY: clear-project
clear-project:
	if [ -d "${PROJECT_DIR}/build" ]; then \
		rm -r ${PROJECT_DIR}/build; \
	fi
	if [ -f "${PROJECT_DIR}/*.elf" ]; then \
		rm ${PROJECT_DIR}/*.elf; \
	fi
	if [ -f "${PROJECT_DIR}/*.hex" ]; then \
		rm ${PROJECT_DIR}/*.hex; \
	fi
	if [ -f "${PROJECT_DIR}/*.bin" ]; then \
		rm ${PROJECT_DIR}/*.bin; \
	fi
	if [ -f "${PROJECT_DIR}/*.map" ]; then \
		rm ${PROJECT_DIR}/*.map; \
	fi

.PHONY: build-cm7
build-cm7: clear-project
	@echo "=====<Compiling project>========================="
	mkdir ${PROJECT_DIR}/build
#	@if [ -f "${PROJECT_DIR}/*.c" ]; then 
		for source in ${PROJECT_DIR}/*.c; do \
			OUT_FILENAME=`echo $$source | awk -F'/' '{print $$NF}'`; \
			echo "${NON_HALAL_SDK_CC} ${BUILD_FLAGS} ${INCLUDE_DIRS} -c $$source -o ${PROJECT_DIR}/build/$${OUT_FILENAME}.o"; \
			${NON_HALAL_SDK_CC} ${BUILD_FLAGS} ${INCLUDE_DIRS} -c $$source -o ${PROJECT_DIR}/build/$${OUT_FILENAME}.o; \
		done; 
#	fi
	@if [ -f "${PROJECT_DIR}/*.S" ]; then \
		for source in ${PROJECT_DIR}/*.S; do \
			OUT_FILENAME=`echo $$source | awk -F'/' '{print $$NF}'`; \
			echo "${NON_HALAL_SDK_CC} ${BUILD_FLAGS} -c $$source -o ${PROJECT_DIR}/build/$${OUT_FILENAME}.o"; \
			${NON_HALAL_SDK_CC} ${BUILD_FLAGS} -c $$source -o ${PROJECT_DIR}/build/$${OUT_FILENAME}.o; \
		done \
	fi

build-project:
	@echo "=====<Compiling project>========================="
	if [ -d "${PROJECT_DIR}/build" ]; then \
		rm -rf ${PROJECT_DIR}/build; \
	fi
	mkdir ${PROJECT_DIR}/build
	for source in ${PROJECT_DIR}/*.c; do \
		OUT_FILENAME=`echo $$source | awk -F'/' '{print $$NF}'`; \
		${CC} ${BUILD_FLAGS} ${INCLUDE_DIRS} -c $$source -o ${PROJECT_DIR}/build/$${OUT_FILENAME}.o; \
	done
	@if [ -f {PROJECT_DIR}/*.S ]; then \
		for source in ${PROJECT_DIR}/*.S; do \
			OUT_FILENAME=`echo $$source | awk -F'/' '{print $$NF}'`; \
			${CC} ${BUILD_FLAGS} -c $$source -o ${PROJECT_DIR}/build/$${OUT_FILENAME}.o; \
		done \
	fi
	@echo "=====<Linking everything together>==============="
	${LD} -T Core/linker.ld ${LINKER_FLAGS} --format=elf32-littleriscv --output=${PROJECT_DIR}/firmware.elf -Map ${PROJECT_DIR}/firmware.map ${PROJECT_DIR}/build/*.o Core/*.a -lc -lgloss components/*/*.a
	${OBJCOPY} -O ihex ${PROJECT_DIR}/firmware.elf ${PROJECT_DIR}/firmware.hex
	${OBJCOPY} -O binary ${PROJECT_DIR}/firmware.elf ${PROJECT_DIR}/firmware.bin
	${SIZE} -t --format=berkeley ${PROJECT_DIR}/firmware.elf

disasm-project:
	${OBJDUMP} -S ${PROJECT_DIR}/firmware.elf > ${PROJECT_DIR}/firmware.lst