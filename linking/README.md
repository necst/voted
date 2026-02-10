## Linking – xclbin Generation

Purpose
-------
This directory connects the AI Engine and FPGA components and generates the final
accelerator binary (.xclbin) to be deployed on the target machine.

The .xclbin is the only accelerator-side file required at runtime (together with
the host application that calls the accelerator).

Requirements
------------
- Vitis (linker tools available)
- Target platform properly installed/available
- AI Engine artifacts available (e.g., libadf.a from the AIE build)
- FPGA kernel objects available (.xo from HLS or RTL packaging)
- GNU Make
- Xilinx environment correctly initialized

Build
-----
From this directory, run:

```bash
make all TARGET=<hw|hw_emu> USE_AIE=<0|1>
```

The TARGET variable selects the build mode:
- hw     : hardware build
- hw_emu : hardware emulation build

Output
------
The linking process produces:
- a final .xclbin file (to be uploaded/deployed on the target machine)

Notes
-----
- The XSA_OBJ dependency used by this flow is not required when targeting
  non-Versal Alveo accelerator cards.
- Ensure that the platform passed to the build matches your deployment target.
- Linking assumes the AIE and FPGA stages have already been completed.
