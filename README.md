# VOTED: Versal-Optimization-Toolkit-for-Education-ed-Heterogeneous-System-Development - FPGA101 Course

## Info & Description
This repository contains the main infrastructure for an AIE-PL project, providing simple automation for testing your code.
Nothing here is provided as "the best way to do". Surely there are other solutions, maybe there are better ones. But still,
this is a useful starting point.

## Main Structure

**aie** - contains the code for AI Engine kernels.  
**fpga** - contains the PL component.  
**common** - contains some useful included constants and headers.  
**linking** - contains the cfg file requiered to connect your components.  
**sw** - contains the software for your application.  

### aie
data - contains the input source for your simulation.  
src - contains the code.  

**Main Commands**

_make aie_compile_x86_ : compile your code for x86 architecture.  
_make aie_simulate_x86_ : simulate your x86 architecture.  
_make aie_compile SHELL_NAME=< qdma|xdma >_ : compile your code for VLIW architecture, as your final hardware for HW ad HW_EMU. 
_make aie_simulate_ : simulate your code for VLIW architecture, as your final hardware.  
_make clean_ : removes all the output file created by the commands listed above.  

### FPGA

testbench : it contains a testbench for each kernel

**Main Commands**

_make compile TARGET=HW/HW_EMU_ _SHELL_NAME=< qdma|xdma >_ : it compiles all your kernel, skipping the ones already compiled.  
_make run_testbench_setup_aie_ : compiles and execute the testbench for the kernel setup_aie.  
_make run_testbench_sink_from_aie_ : compiles and execute the testbench for the kernel setup_aie.  

### linking

Contains the cfg file required to link the components. For the Versal case, you have also to link the AI Engine.

**Main Commands**

_make all TARGET=HW/HW_EMU SHELL_NAME=< qdma|xdma >_  : it builds the hardware or the hardware emu linking your componentsEMU TARGET=HW/HW_EMU
make clean: it removes all files.

### Sw

Once you have devised your accelerator, you need to create the host code for using it. Notice that the presented example is a minimal host code, which may be improved using all the capabilities of C++ code ( classes, abstraction and so on).

**Main Commands**
_make build_sw_ : it compiles the sw

_./setup_emu.sh -s on --shell =< qdma|xdma >_ : enables the hardware emulation

i.e.: make build_sw && ./setup_emu.sh && ./host_overlay.exe : this will compile, prepare the emulation, and run it.

## General useful commands:
If you need to move your bitstream and executable on the target machine, you may want it prepared in a single folder that contains all the required stuff to be moved. In this case, you can use the

_make build_and_pack TARGET=hw/hw_emu SHELL_NAME=< qdma|xdma >_ :  it allows you to pack our build in a single folder. Notice that the hw_emu does not have to be moved on the device, it must be executed on the development machine.


**Related Pubblications**

Sorrentino, G., Galfano, P. S., D'Arnese, E., & Conficconi, D. (2025). Soaring with TRILLI: an HW/SW Heterogeneous Accelerator for Multi-Modal Image Registration. In Proceedings of the 2025 IEEE 33rd Annual International Symposium on Field-Programmable Custom Computing Machines (FCCM). IEEE. https://doi.org/10.5281/zenodo.15211289

Cabai, E., Sorrentino, G., Conficconi, D., & Santambrogio, M. D. (2025). A Hardware/Software Co-Design Approach for Versal-Based K-means Acceleration [Poster]. In Proceedings of the 2024 IEEE International Parallel and Distributed Processing Symposium Workshops (IPDPSW). IEEE.

Mansutti, F., Ettori, D., Sorrentino, G., Santambrogio, M. D., & Conficconi, D. (2025). Towards a Methodology to Leverage Alveo Versal System Usability And Parallelization [Poster]. In Proceedings of the 39th I Reconfigurable Architectures Workshop (RAW 2025).

P. S. Galfano, G. Sorrentino, E. D'Arnese and D. Conficconi, "Co-Designing a 3D Transformation Accelerator for Versal-Based Image Registration," 2024 IEEE 42nd International Conference on Computer Design (ICCD), Milan, Italy, 2024, pp. 219-222, doi: 10.1109/ICCD63220.2024.00041.

## Citation
```
@inproceedings{sorrentino2025voted,
  author    = {Giuseppe Sorrentino and Paolo S. Galfano and Eleonora D'Arnese and Davide Conficconi},
  title     = {VOTED: Versal Optimization Toolkit for Education and Heterogeneous Systems Development},
  booktitle = {Proceedings of the IEEE International Symposium on Circuits and Systems (ISCAS)},
  year      = {2025},
  pages     = {1--5},
  publisher = {IEEE}
}
```
