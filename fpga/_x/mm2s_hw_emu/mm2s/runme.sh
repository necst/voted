#!/bin/sh

# 
# v++(TM)
# runme.sh: a v++-generated Runs Script for UNIX
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/xilinx/Vitis_HLS/2023.1/bin:/home/xilinx/Vitis/2023.1/bin:/home/xilinx/Vitis/2023.1/bin
else
  PATH=/home/xilinx/Vitis_HLS/2023.1/bin:/home/xilinx/Vitis/2023.1/bin:/home/xilinx/Vitis/2023.1/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/gsorrentino/projects/voted_hdl/voted/fpga/_x/mm2s_hw_emu/mm2s'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vitis_hls -f mm2s.tcl -messageDb vitis_hls.pb
