# MIT License

# Copyright (c) 2023 Paolo Salvatore Galfano, Giuseppe Sorrentino

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

ECHO=@echo

.PHONY: help

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) ""
	$(ECHO) "  make compile"
	$(ECHO) "      Command to generate xo kernel file"
	$(ECHO) ""
	$(ECHO) "  make clean"
	$(ECHO) "      Command to remove all the generated files."


PLATFORM ?= xilinx_vck5000_gen4x8_qdma_2_202220_1

TARGET := hw

.phony: clean

################## hardware build 

XOCCFLAGS := --platform $(PLATFORM) -t $(TARGET)  -s -g

compile: setup_aie_$(TARGET).xo sink_from_aie_$(TARGET).xo 

# Use --optimize 3 to enable post-route optimizations. This may improve the bitstream but SIGNIFICANTLY increase compilation time
setup_aie_$(TARGET).xo: ./setup_aie.cpp
	v++ $(XOCCFLAGS) --kernel setup_aie -c -o $@ $<

# Use --optimize 3 to enable post-route optimizations. This may improve the bitstream but SIGNIFICANTLY increase compilation time
sink_from_aie_$(TARGET).xo: ./sink_from_aie.cpp
	v++ $(XOCCFLAGS) --kernel sink_from_aie -c -o $@ $<

# as every C++ program, you may add libraies like: `pkg-config --libs opencv` `pkg-config --cflags opencv`
testbench_sink_from_aie: testbench/testbench_sink_from_aie.cpp
	g++ -std=c++14 -I. -I$(XILINX_HLS)/include -o testbench/$@ $^ -O2  
	
run_testbench_sink_from_aie: testbench_sink_from_aie
	cd testbench && ./testbench_sink_from_aie 

testbench_setupaie: testbench/testbench_setupaie.cpp
	g++ -std=c++14 -I. -I$(XILINX_HLS)/include -o testbench/$@ $^ -O2

run_testbench_setupaie: testbench_setupaie
	cd testbench && ./testbench_setupaie

# Run a full HLS test: csim, csynth, and cosim using Vivado HLS
# Usage: make full_test_hls src=your_file.cpp tb=your_testbench.cpp
# Both files must exist, and the testbench should be located in the 'testbench/' directory

# Removed the old_full_test_hls target as it is no longer needed.

SRC_BASE := $(basename $(notdir $(src)) .cpp)
SRC_FILE := $(notdir $(src))
TB_FILE := $(notdir $(tb))

full_test_hls:
	@echo "Running full_test_hls with source: $(src) and testbench: $(tb)"
	@if [ -z "$(src)" ] || [ -z "$(tb)" ]; then \
		echo "Error: specify src and tb"; exit 1; \
	fi
	@PROJ_ROOT=full_test_$(shell date +%Y%m%d_%H%M%S); \
	BUILD_DIR=$$PROJ_ROOT/build; \
	TESTBENCH_DIR=$$BUILD_DIR/testbench; \
	SRC_FILE=$$(basename $(src)); \
	TB_FILE=$$(basename $(tb)); \
	SRC_BASE=$$(basename $${SRC_FILE} .cpp); \
	echo "SRC_FILE: $$SRC_FILE"; \
	echo "TB_FILE: $$TB_FILE"; \
	echo "SRC_BASE: $$SRC_BASE"; \
	echo "Creating project structure in $$PROJ_ROOT"; \
	mkdir -p $$TESTBENCH_DIR; \
	mkdir -p $$PROJ_ROOT/common; \
	cp ./$$SRC_FILE $$BUILD_DIR/; \
	cp ./$$SRC_BASE.hpp $$BUILD_DIR/; \
	cp testbench/$$TB_FILE $$TESTBENCH_DIR/; \
	cp -r ../common/* $$PROJ_ROOT/common/; \
	echo "Args to vitis_hls:"; \
	echo "vitis_hls -f full_test_hls.tcl -- '$$PROJ_ROOT' '$$SRC_FILE' '$$TB_FILE' '$$SRC_BASE' xcvc1902-vsva2197-2MP-e-S"; \
	vitis_hls -f full_test_hls.tcl -- "$$PROJ_ROOT" "$$SRC_FILE" "$$TB_FILE" "$$SRC_BASE" xcvc1902-vsva2197-2MP-e-S
################## clean up
clean:
	$(RM) -rf *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x .Xil

clean_hls_folder:
	@echo "Removing full_test_* folders with numeric suffix..."
	@find . -maxdepth 1 -type d -name 'full_test_*' | grep -E '^./full_test_[0-9]+(_[0-9]+)?$$' | xargs -r rm -rf
	@echo "Done."