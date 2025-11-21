
F_PROJ_ROOT ?= $(shell bash -c 'export MK_PATH=$(MK_PATH); echo $${MK_PATH%/AI_Engine_Development/*}')

# Sysroot set automatically by environment-setup-cortexa72-cortexa53-amd-linux
SDKTARGETSYSROOT ?= ${SYSROOT}

TARGET := hw_emu

BASE_PLATFORM ?= ${PLATFORM_REPO_PATHS}/xilinx_vek280_base_202510_1/xilinx_vek280_base_202510_1.xpfm

################################################################################
# HOST COMPILATION (C++ → ARM aarch64)
################################################################################

# Must be set by sourcing the Common Image SDK environment
# → aarch64-xilinx-linux-g++ must exist
GCC_FLAGS := -Wall -c -std=c++17 -Wno-int-to-pointer-cast \
             --sysroot=$(SDKTARGETSYSROOT)

GCC_INCLUDES := -I$(SDKTARGETSYSROOT)/usr/include \
                -I$(SDKTARGETSYSROOT)/usr/include/xrt \
                -I$(XILINX_VITIS)/aietools/include \
                -I$(XILINX_VITIS)/include \
                -I../aie \
                -I./

GCC_LIB := -lxrt_coreutil \
           -L${XILINX_XRT}/lib \
           --sysroot=${SDKTARGETSYSROOT}

################################################################################
# PHONY
################################################################################
.ONESHELL:
.PHONY: clean all kernels aie sim xsa package

################################################################################
# VARIABLE CHECKS (CORRECT AND SAFE)
################################################################################

check_defined = \
	$(strip $(foreach v,$1, \
		$(call __check_defined,$(v),$(strip $(value 2)))))

__check_defined = \
	$(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))))
guard-PLATFORM_REPO_PATHS:
	$(call check_defined, PLATFORM_REPO_PATHS, Set your base_platform path.)

guard-ROOTFS:
	$(call check_defined, ROOTFS, Set to: xilinx-versal-common-v2025.1/rootfs.ext4)

guard-IMAGE:
	$(call check_defined, IMAGE, Set to: xilinx-versal-common-v2025.1/Image)

guard-CXX:
	$(call check_defined, CXX, Run environment-setup-cortexa72-cortexa53-amd-linux!)

guard-SDKTARGETSYSROOT:
	$(call check_defined, SDKTARGETSYSROOT, Run environment-setup-cortexa72-cortexa53-amd-linux!)


################################################################################
# HOST COMPILATION FOR ARM
################################################################################

EXECUTABLE = host_code.exe

build_sw: guard-CXX guard-SDKTARGETSYSROOT
	$(CXX) $(GCC_FLAGS) $(GCC_INCLUDES) -o host.o host_code.cpp
	$(CXX) host.o $(GCC_LIB) -std=c++17 -o $(EXECUTABLE)
	@echo "COMPLETE: Host application created."

################################################################################
# EMULATION RUN
################################################################################

run_hw_emu:
ifeq (${TARGET},hw_emu)
	@echo "Launching HW Emulation..."
	cd ../linking/package_output && \
	./launch_hw_emu.sh \
		-aie-sim-options ../../aie/aiesimulator_output/aiesim_options.txt \
		-add-env AIE_COMPILER_WORKDIR=../../aie/Work
else
	@echo "Hardware build, no emulation executed."
endif

################################################################################
# CLEAN
################################################################################

clean:
	rm -rf _x *.o *.jou *.log *.xsa *.xclbin Work
	rm -rf pl_kernels/*.xo aiesimulator_output x86simulator_output
	rm -rf sw/*.o sw/*.exe sw/*.log sw/*.elf sw/*_x sw/*.xpe sw/*.json sw/sd_card*
