# MIT License
# Copyright (...)

ECHO=@echo

.PHONY: help clean all package

help::
	$(ECHO) ""
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make all TARGET=<hw/hw_emu>"
	$(ECHO) ""
	$(ECHO) "  make clean"
	$(ECHO) "      Command to remove all the generated files."
	$(ECHO) ""

BASE_PLATFORM_FOLDER ?=/home/xilinx/2025.1/Vitis/base_platforms
TARGET := hw

# Path verso i file del Versal Common Image
VERSAL_COMMON := /home/gsorrentino/Desktop/VersalCommon/xilinx-versal-common-v2025.1


AIE_OBJ := ../aie/libadf.a
XOS     := ../fpga/setup_aie_$(TARGET).xo
XOS     += ../fpga/sink_from_aie_$(TARGET).xo
XSA_OBJ := overlay_$(TARGET).xsa
XCLBIN  := overlay_$(TARGET).xclbin

################################################################################
# Build rules
################################################################################

all: package
		
# Linking of kernels + AIE to produce XSA

$(XSA_OBJ): $(XOS) $(AIE_OBJ)
	v++ -l \
		--platform $(BASE_PLATFORM_FOLDER)/xilinx_vek280_base_202510_1/xilinx_vek280_base_202510_1.xpfm \
		-t $(TARGET) \
		-s -g \
		--config xclbin_overlay.cfg \
		-o $(XSA_OBJ) \
		$(XOS) $(AIE_OBJ)


# XCLBIN generation with FULL PACKAGING
# Equivalent to:
# v++ -p -t hw -f platform --package.rootfs=... etc.
package: $(XSA_OBJ)
	v++ -p \
		-t $(TARGET) \
		-f $(BASE_PLATFORM_FOLDER)/xilinx_vek280_base_202510_1/xilinx_vek280_base_202510_1.xpfm \
		--package.rootfs=$(VERSAL_COMMON)/rootfs.ext4 \
		--package.image_format=ext4 \
		--package.boot_mode=sd \
		--package.kernel_image=$(VERSAL_COMMON)/Image \
		--package.out_dir package_output \
		--output $(XCLBIN) \
		--package.sd_file=../sw/host_code.exe \
		--temp_dir package_temp \
		$(XSA_OBJ) \
		$(AIE_OBJ)


################################################################################
# Clean
################################################################################

clean:
	$(RM) -r _x .Xil .ipcache *.ltx *.log *.sh *.jou *.info *.xclbin \
	       *.xo.* *.str *.xsa *.cdo.bin *bif *BIN *.package_summary \
	       *.link_summary *.txt *.bin cfg emulation_data sim \
	       package_temp package_output
