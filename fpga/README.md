FPGA – HLS Kernels (VOTED)

Purpose
-------
This directory contains FPGA kernels developed using Vitis HLS and the
associated testbenches used to validate data movement and interaction with
the AI Engine within the VOTED framework.

The HLS kernels in this directory implement the data movers used by VOTED:
- mm2s : memory-to-stream (prepares data for the AI Engine)
- s2mm : stream-to-memory (consumes data produced by the AI Engine)

Requirements
------------
- Vitis (v++)
- Vitis HLS (vitis_hls)
- GNU Make
- Xilinx environment correctly initialized
- PLATFORM correctly installed

Configuration Variables
-----------------------
The Makefile is driven by the following variables:

- PLATFORM : target platform (default: xilinx_vck5000_gen4x8_qdma_2_202220_1)
- TARGET   : build target (default: hw)

These variables can be overridden from the command line.

Example:
```bash
make compile PLATFORM=<platform_name> TARGET=hw_emu
```

------------------------------------------------------------
1) Kernel Compilation (.xo generation)
------------------------------------------------------------

Overview
--------
The compile target generates Vitis kernel object files (.xo) for the HLS kernels.
These .xo files are later used during the linking stage.

The following kernels are compiled:
- mm2s
- s2mm

Command
-------
make compile

This command generates:
- mm2s_hw.xo
- s2mm_hw.xo

The compilation is performed using v++ with the following characteristics:
- hardware target (hw by default)
- debug symbols enabled (-g)
- synthesis-only flow (-s)

Notes
-----
- Post-route optimizations (--optimize 3) are intentionally disabled by default
  as they significantly increase compilation time.
- The generated .xo files are platform-dependent.

------------------------------------------------------------
2) HLS Testbenches (C++ simulation)
------------------------------------------------------------

Overview
--------
The Makefile provides multiple C++ testbenches that allow functional validation
of the HLS kernels outside the full Vitis flow.

These testbenches are compiled using a standard C++ compiler and linked against
the HLS kernel sources.

Provided Testbenches
--------------------
- testbench_setupaie : validates mm2s behavior and prepares PLIO-compatible data
- testbench_s2mm     : validates s2mm behavior using AIE-generated outputs
- testbench_e2e      : end-to-end validation using both mm2s and s2mm

Build and Run Commands
---------------------

Build and run the mm2s testbench:
```bash
make run_testbench_mm2s
```

Build and run the s2mm testbench:
```bash
make run_testbench_s2mm
```

Build and run the end-to-end testbench with AIE (mm2s may have been adapted to HDL kernel in this flow.):

```bash
make run_testbench_e2e
```

All testbenches are executed from the testbench/ directory.

------------------------------------------------------------
3) Full HLS Flow (csim, csynth, cosim)
------------------------------------------------------------

Overview
--------
The full_test_hls target runs a complete Vitis HLS flow:
- C simulation (csim)
- C synthesis (csynth)
- C/RTL co-simulation (cosim)

This flow is useful to validate a kernel in isolation before integrating it
into the Vitis compilation flow.

Usage
-----
```bash
make full_test_hls src=<kernel.cpp> tb=<testbench.cpp>
```

Requirements:
- src must be a kernel source file located in the current directory
- tb must be a testbench source file located in testbench/

Example:
```bash
make full_test_hls src=mm2s.cpp tb=testbench_setupaie.cpp
```
Behavior
--------
- A timestamped project directory (full_test_YYYYMMDD_HHMMSS) is created
- Common headers are copied automatically
- The flow is executed via full_test_hls.tcl using vitis_hls

------------------------------------------------------------
4) Cleaning Generated Files
------------------------------------------------------------

Clean compiled artifacts:
make clean

This removes:
- .xo files
- Vitis/Vivado logs
- temporary build artifacts

Remove generated full HLS test folders:
```bash
make clean_hls_folder
```

This removes all full_test_* directories created by full_test_hls.

------------------------------------------------------------
Notes and Best Practices
------------------------------------------------------------
- Always validate kernels with the C++ testbenches before generating .xo files.
- Ensure that mm2s and s2mm data formats match the PLIO structure expected by
  the AI Engine.
- Use TARGET=hw_emu when debugging integration issues with the full system.
