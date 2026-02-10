## AIE – AI Engine Design

Purpose
-------
This directory contains the AI Engine (AIE) design, including kernels, graphs,
and automation utilities for compilation and simulation within the VOTED flow.

Both x86 functional simulation and VLIW-accurate simulation are supported.

Requirements
------------
- Vitis AI Engine tools
- GNU Make
- Xilinx environment correctly initialized

AIE x86 Flow (Recommended First Step)
------------------------------------
The x86 flow provides a fast functional simulation used to detect
API and logic errors early in the development cycle.

Commands:
```bash
make aie_compile_x86
make aie_simulate_x86
```

This flow does not model the real VLIW architecture.

AIE VLIW Flow
-------------
For an architecture-accurate simulation, use the VLIW flow:

Commands:
```bash
make aie_compile
make aie_simulate
```
This flow:
- generates libadf.a (required for final linking)
- evaluates the kernel using the real AIE VLIW architecture

This step is slower but mandatory before hardware generation.

Adding a New Kernel
-------------------
A new kernel can be added in two ways.

Option A – Template Generator (Recommended)
-------------------------------------------
Generate a kernel template using:

```bash
make gen_kernel
```

Before running the command, edit:
src/template_generator/kernel.cfg

The configuration file specifies:
- kernel name
- ports
- kernel type
- automation parameters

Option B – Manual Kernel
------------------------
You may write the kernel .cpp file manually if full control over
the implementation is required.

Kernel Integration
------------------
All kernels must be integrated into graph.h.

The graph.h file connects:
- kernels
- PLIO interfaces
- input and output streams

Input Data for Simulation
-------------------------
To evaluate a kernel, input data files must be placed in:

./data/

The input file used for PLIO simulation is specified inside graph.h.
