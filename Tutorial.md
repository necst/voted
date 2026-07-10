
# Tutorial - How To Use Voted

The following steps are intended to experiment with **Voted** using the pre-designed kernels.
Notably, the default platform for this section is a versal vck5000 2022.2 QDMA. 
However, different platforms can be specified to the make commands.

## **Step 1 — AIE Design**

Go into the **AIE** folder:

```bash
cd aie
```

Then use the commands for compiling and simulating the **AIE x86 flow**:

```bash
make aie_compile_x86
make aie_simulate_x86
```

This provides a *functional simulation*, intended for the early detection of API/logic errors.  

The **AIE x86 flow** does **not** consider the underlying VLIW architecture, but it is significantly faster and strongly suggested as an early step.

### VLIW Evaluation 

For a more accurate test that **considers the actual VLIW architecture**, use:

```bash
make aie_compile
make aie_simulate
```

This flow causes the **AIE compiler** to:

- generate the **libadf.a** file (required for bitstream creation),
- evaluate the code using the real **AIE VLIW architecture** rather than the simplified x86 model.

This VLIW evaluation is slower but essential before final integration and hardware generation.

---

### Adding a New Kernel

To add a new kernel, you can either:

- **A)** Use the template generator and modify it.  
- **B)** Create your `.cpp` file from scratch.

#### A) Using the Template Generator

Generate a kernel template with:

```bash
make gen_kernel
```

Before running the command, remember to modify the **kernel.cfg** file,  
which specifies the parameters used by the automation (kernel name, ports, type, etc.).

#### B) Creating a Kernel From Scratch

You may also write your `.cpp` file manually if you prefer full control. 

---

### Kernel Integration

The devised kernel must be integrated into the `graph.h` file, which connects the various I/O components.

---

### Input File for Kernel Evaluation

To evaluate a kernel, you need an input file placed in the `./data/` folder.

Within the graph.h, you can specify the input file to be used for **PLIO simulation**.

---

## **Step 2: FPGA Design**

Voted assumes HLS kernels are written under the `fpga` folder.

To compile all the provided kernels:

```bash
make compile TARGET=<hw/hw_emu>
```

Note that the `compile` command in the Makefile triggers kernel-specific compilation rules.  
Each kernel rule produces a `.xo` file, which is then used in the linking phase.

Once the kernels are prepared, the VOTED methodology suggests writing a **single unified testbench** that:

1. calls the FPGA kernel that writes the data  
2. uses the provided API to write such data into a PLIO-friendly file  
3. runs the AIE (x86 or VLIW) simulation  
4. collects the simulation output files and adapts them into a stream (using VOTED utils function or custom ones)  
5. uses the generated stream as input for evaluating the HLS kernels  

In this example, the `sink_from_aie` testbench reads the output file produced by AIE, while the `setup_aie` testbench prepares the PLIO output files.

We strongly encourage extending the kernels so that the written HLS kernel **matches the AI Engine PLIO structure** expected by VOTED.

To run the testbench: 

```bash
make run_testbench_<kernelname>
```

## **Step 3: Linking**

At this point, you have completed the design for the AI Engine and FPGA component. 
So, it is time to connect them together.

```bash
cd linking
```

Goal of this section is to create the `.xclbin`  file to be uploaded on the deployment machine. This is 
the only file needed by the accelerator (in conjunction with the host code for calling the accelerator).

```bash
make all TARGET=<hw/hw_emu>
```

Notably, The XSA_OBJ dependency called by this command is not required, 
if the target platform is a non Versal alveo accelerator card.

## **Step 4: Host Code**

To use the accelerator, you need to prepare your host-code. Despite the host-code is independent from the
accelerator (you may use PYNQ if your accelerator supports it), VOTED comes with a C++ XRT based host-code,
validated on both versal system, alveo systems and HBM-based devices with almost no modification. 

To compile:

```bash
make build_sw
```

For hardware emulation only: 

```bash
source ./setup_emu.sh -s on
```

To run the hw/hw_emulation example

```bash
./host_overlay.exe
```