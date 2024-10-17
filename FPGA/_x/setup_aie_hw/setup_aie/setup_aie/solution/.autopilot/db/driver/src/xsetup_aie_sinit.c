// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.2 (64-bit)
// Tool Version Limit: 2019.12
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xsetup_aie.h"

extern XSetup_aie_Config XSetup_aie_ConfigTable[];

XSetup_aie_Config *XSetup_aie_LookupConfig(u16 DeviceId) {
	XSetup_aie_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XSETUP_AIE_NUM_INSTANCES; Index++) {
		if (XSetup_aie_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XSetup_aie_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XSetup_aie_Initialize(XSetup_aie *InstancePtr, u16 DeviceId) {
	XSetup_aie_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XSetup_aie_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XSetup_aie_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

