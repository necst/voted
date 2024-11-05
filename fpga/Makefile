# MIT License

# Copyright (c) 2024 Paolo Salvatore Galfano, Giuseppe Sorrentino, Davide Conficconi

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

# SHELL_NAME := null
# PLATFORM := null

# ifeq ($(findstring 2022.1,$(XILINX_HLS)),2022.1)
#     SHELL_NAME = xdma
# else
#     SHELL_NAME = qdma
# endif

# ifeq ($(SHELL_NAME), qdma)
#     PLATFORM := /opt/xilinx/platforms/xilinx_vck5000_gen4x8_qdma_2_202220_1/hw/xilinx_vck5000_gen4x8_qdma_2_202220_1.xsa
# else ifeq ($(SHELL_NAME), xdma)
#     PLATFORM := /opt/xilinx/platforms/xilinx_vck5000_gen4x8_xdma_2_202210_1/hw/xilinx_vck5000_gen4x8_xdma_2_202210_1.xsa
# endif

SHELL_NAME := xdma

PLATFORM := /opt/xilinx/platforms/xilinx_u250_gen3x16_xdma_4_1_202210_1/xilinx_u250_gen3x16_xdma_4_1_202210_1.xpfm

TARGET := hw

.phony: clean

################## hardware build 

XOCCFLAGS := --platform $(PLATFORM) -t $(TARGET)  -s -g

compile: ldl_dsolve_$(TARGET).xo
# compile: setup_aie_$(TARGET).xo sink_from_aie_$(TARGET).xo 

# setup_aie_$(TARGET).xo: ./setup_aie.cpp
# 	v++ $(XOCCFLAGS) --kernel setup_aie -c -o $@ $<

# sink_from_aie_$(TARGET).xo: ./sink_from_aie.cpp
# 	v++ $(XOCCFLAGS) --kernel sink_from_aie -c -o $@ $<

ldl_dsolve_$(TARGET).xo: ./ldl_dsolve.cpp ./ldl_dsolve.hpp
	v++ $(XOCCFLAGS) --kernel ldl_dsolve -c -o $@ $< ldl_dsolve.hpp

# as every C++ program, you may add libraies like: `pkg-config --libs opencv` `pkg-config --cflags opencv`
# testbench_sink_from_aie: testbench/testbench_sink_from_aie.cpp
# 	g++ -std=c++14 -I. -I$(XILINX_HLS)/include -o testbench/$@ $^ -O2  
	
# run_testbench_sink_from_aie: testbench_sink_from_aie
# 	cd testbench && ./testbench_sink_from_aie 

# testbench_setupaie: testbench/testbench_setupaie.cpp
# 	g++ -std=c++14 -I. -I$(XILINX_HLS)/include -o testbench/$@ $^ -O2

# run_testbench_setupaie: testbench_setupaie
# 	cd testbench && ./testbench_setupaie

testbench_ldl_dsolve: testbench/testbench_ldl_dsolve.cpp ./ldl_dsolve.cpp ./ldl_dsolve.hpp
	g++ -I. -I$(XILINX_HLS)/include -o testbench/$@ $^ -O2

run_testbench_ldl_dsolve: testbench_ldl_dsolve
	cd testbench && ./testbench_ldl_dsolve

################## clean up
clean:
	$(RM) -rf *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x .Xil logs
