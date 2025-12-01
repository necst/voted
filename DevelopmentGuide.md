# Development – How To Use Voted

The following steps describe how to experiment with Voted using the pre-designed kernels.
The default platform for this workflow is a Versal VCK5000 2022.2 QDMA, although different platforms can be specified in the `make` commands.

---

## ⚙️ Setup

To follow these instructions, you must source both XRT and Vitis for the desired version.
This repository has been verified using:

- Vitis 2022.1, 2022.2, 2023.1 for Versal-based devices
- Up to 2024.2 for non-Versal devices

For each Vitis version, use its corresponding XRT version.

For convenience, you may run:

```bash
source ./setup_all.sh
```

---

## 🧠 Step 1 — AIE Design

Enter the AIE directory:

```bash
cd aie
```

### AIE x86 Flow

Compile and simulate using the x86 functional model:

```bash
make aie_compile_x86
make aie_simulate_x86
```

This provides a functional simulation for early API or logic error detection.  
The x86 model does not implement the VLIW architecture but is significantly faster and ideal for initial testing.

### VLIW Evaluation

To simulate using the actual AIE VLIW architecture:

```bash
make aie_compile
make aie_simulate
```

This stage:

- Generates `libadf.a` (required for bitstream generation)
- Evaluates the code using the real VLIW architecture

Although slower, this step is essential before final integration.

---

### 🧩 Adding a New Kernel

You may add a new kernel in two ways:

#### A) Using the Template Generator

```bash
make gen_kernel
```

Before running this command, edit the `kernel.cfg` file (kernel name, ports, type, etc.).

#### B) Creating a Kernel Manually

Simply create your own `.cpp` file.

---

### Kernel Integration

Your kernel must be connected inside `graph.h`, where all input and output PLIO nodes are defined.

---

### Input File for Kernel Evaluation

Place your input test file inside the `./data/` directory.  
The file used for PLIO simulation is referenced inside `graph.h`.

---

## 🔧 Step 2 — FPGA Design

Voted assumes all HLS kernels reside in the `fpga/` directory.

To compile all kernels:

```bash
make compile TARGET=<hw/hw_emu>
```

This invokes all kernel rules, producing `.xo` files for each kernel.

You may also compile a single kernel manually:

```bash
make <kernel_name>_<TARGET>.xo
```

### Unified Testbench

The VOTED methodology recommends using a unified testbench that:

1. Calls the FPGA kernel that produces data  
2. Uses the provided API to write data into a PLIO-compliant format  
3. Runs AIE simulation (x86 or VLIW)  
4. Converts simulation outputs into a stream (using VOTED utilities or custom scripts)  
5. Feeds the generated stream into the HLS kernels for testing  

Example utilities:  
- `sink_from_aie` reads AIE output  
- `setup_aie` prepares PLIO output files  

We recommend ensuring that your HLS kernels match the expected AI Engine PLIO structure.

Run the testbench:

```bash
make run_testbench_<kernelname>
```

---

## 🛠 Step 3 — Linking

After completing AIE and FPGA implementation, link the system.

Enter the linking directory:

```bash
cd linking
```

Configuration options in `xclbin_overlay.cfg` include:

- `nk`: kernel name, number of instances, and optional alias  
- `slr`: SLR assignment  
- `memory`: memory bank mapping (HBM, DDR, MC_NOC0, etc.)  
- `stream_connect`: stream connections between kernels and AIE PLIO  
- Additional Vivado properties  

Build the `.xclbin` file:

```bash
make all TARGET=<hw/hw_emu>
```

Note: `XSA_OBJ` is not required on non-Versal Alveo accelerator cards.

---

## 💻 Step 4 — Host Code

To use the accelerator, prepare the host application.  
VOTED includes a C++ XRT-based host program validated on:

- Versal platforms  
- Alveo cards  
- HBM-based accelerators  

### Build the Host Application

```bash
make build_sw
```

### Enable Hardware Emulation

```bash
source ./setup_emu.sh -s on
```

### Run the hw/hw_emu example

To run the hardware or hardware emulation, you just have to run the executable on the deploying machine (or in the development machine with the hw emulation environmnet enabled).

```bash
./host_overlay.exe
```
