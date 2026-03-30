## FPGA-HDL – RTL Simulation and RTL Kernel Packaging

Purpose
-------
This directory provides two main capabilities:

1. RTL simulation using XSim (xvlog -> xelab -> xsim)
2. Packaging RTL sources into a Vitis/Vivado kernel (.xo)

The Makefile is intentionally generic and driven by variables, so it can be reused
across different RTL designs and testbenches.

Requirements
------------
- Vivado installed and available in PATH (vivado, xvlog, xelab, xsim)
- GNU Make
- Xilinx environment correctly initialized

Build Directory
---------------
All generated artifacts and logs are produced under:

build/

You can change the build directory by overriding BUILD, e.g.:
make sim BUILD=out ...

------------------------------------------------------------
1) RTL Simulation (XSim Flow)
------------------------------------------------------------

Overview
--------
The simulation flow is split into three steps:

- compile : compile RTL + testbench sources with xvlog
- elab    : elaborate the design and create a snapshot with xelab
- run     : run the snapshot in batch mode with xsim

There is also a high-level target:
- sim     : runs the full flow (compile + elab + run)

Mandatory Variables
-------------------
You must provide the following variables when running the simulation flow:

- TOP_TB : testbench top module name (must match the Verilog module name)
- RTL    : space-separated list of RTL sources (paths relative to project root)
- TB     : space-separated list of testbench sources (paths relative to project root)

Important Notes
---------------
- RTL and TB are space-separated file lists/paths relative to the project root.
- TOP_TB must match the Verilog module name of the testbench top.
- Paths are passed to the build directory by prefixing ../ automatically.

Common Commands
---------------
Run full simulation flow (compile -> elaborate -> run):

make sim TOP_TB=<tb_top> RTL="<rtl_files>" TB="<tb_files>"

Run individual phases (useful for debugging):

```bash
make compile TOP_TB=<tb_top> RTL="<rtl_files>" TB="<tb_files>"
make elab    TOP_TB=<tb_top> RTL="<rtl_files>" TB="<tb_files>"
make run     TOP_TB=<tb_top> RTL="<rtl_files>" TB="<tb_files>"
```

Examples
--------
Example 1 – Simple AND gate simulation:
```bash
make sim TOP_TB=tb_example_and_gate RTL="example_and_gate.v" TB="testbench/tb_example_and_gate.v"
```

Example 2 – Kernel-level simulation with multiple RTL files:
```bash
make sim TOP_TB=tb_krnl_and RTL="example_and_gate.v krnl_and.v" TB="testbench/tb_krnl_and.v"
```

Vector add example: 
```bash
make clean
make sim TOP_TB=tb_krnl_vadd_stream_axis RTL="example_vector_add.v krnl_vadd_stream.v" TB="testbench/tb_krnl_vadd_stream.v"
```

Logs and Outputs
----------------
After running simulation, logs are available under build/:

- build/xvlog.log
- build/xelab.log
- build/xsim.log

A "Simulation finished" message is printed at the end of the sim target.

------------------------------------------------------------
2) RTL Kernel Packaging to .xo (Vitis/Vivado)
------------------------------------------------------------

Overview
--------
This flow packages RTL sources into a Vitis/Vivado-compatible kernel object (.xo)
using Vivado in batch mode and a packaging TCL script.

Basic Command
-------------
```bash
make xo RTL="<rtl_files>"
```

Required Variables
------------------
- RTL : space-separated list of RTL sources to package

Optional Variables
------------------
- KERNEL_NAME : kernel name (default: krnl_and)
- PART        : target FPGA part (default: xcvc1902-vsvd1760-2MP-e-S)
- KERNEL_IF   : kernel interface type (default: axilite)
               accepted values: axilite | axis

Packaging Scripts
-----------------
The Makefile selects the TCL script based on KERNEL_IF:

- KERNEL_IF=axilite -> scripts/pack_xo.tcl
- KERNEL_IF=axis    -> scripts/pack_xo_axis.tcl

Output
------
The packaging flow produces:

- build/<KERNEL_NAME>.xo
- build/<KERNEL_NAME>_ip/   (intermediate IP packaging directory)

Examples
--------
Example 1 – Package an AXI-Lite kernel:

```bash
make xo RTL="example_and_gate.v krnl_and.v" KERNEL_NAME=krnl_and KERNEL_IF=axilite
```

Example 2 – Package an AXIS kernel:

```bash
make xo RTL="example_vector_add.v krnl_vadd_stream.v" KERNEL_NAME=krnl_vadd_stream KERNEL_IF=axis
```

------------------------------------------------------------
3) Cleaning Generated Files
------------------------------------------------------------

Clean Command
-------------
make clean

This removes:
- build/
- _vivado_* directories
- xsim.dir
- .Xil
- Vivado/XSim log and journal files (*.jou, *.log, *.str, etc.)

Troubleshooting
---------------
- If you see "ERROR: TOP_TB is required" (or RTL/TB), you are missing a mandatory variable.
- If xvlog/xelab/xsim are not found, ensure Vivado is installed and the Xilinx environment is sourced.
- If packaging fails, verify:
  - the PART matches your target device
  - the RTL list is complete (includes all dependencies)
  - the selected packaging TCL script matches the intended kernel interface (axilite vs axis)
