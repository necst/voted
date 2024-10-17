// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.2 (64-bit)
// Tool Version Limit: 2019.12
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef XSETUP_AIE_H
#define XSETUP_AIE_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xsetup_aie_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
    u16 DeviceId;
    u64 Control_BaseAddress;
} XSetup_aie_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XSetup_aie;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XSetup_aie_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XSetup_aie_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XSetup_aie_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XSetup_aie_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
int XSetup_aie_Initialize(XSetup_aie *InstancePtr, u16 DeviceId);
XSetup_aie_Config* XSetup_aie_LookupConfig(u16 DeviceId);
int XSetup_aie_CfgInitialize(XSetup_aie *InstancePtr, XSetup_aie_Config *ConfigPtr);
#else
int XSetup_aie_Initialize(XSetup_aie *InstancePtr, const char* InstanceName);
int XSetup_aie_Release(XSetup_aie *InstancePtr);
#endif

void XSetup_aie_Start(XSetup_aie *InstancePtr);
u32 XSetup_aie_IsDone(XSetup_aie *InstancePtr);
u32 XSetup_aie_IsIdle(XSetup_aie *InstancePtr);
u32 XSetup_aie_IsReady(XSetup_aie *InstancePtr);
void XSetup_aie_Continue(XSetup_aie *InstancePtr);
void XSetup_aie_EnableAutoRestart(XSetup_aie *InstancePtr);
void XSetup_aie_DisableAutoRestart(XSetup_aie *InstancePtr);

void XSetup_aie_Set_size(XSetup_aie *InstancePtr, u32 Data);
u32 XSetup_aie_Get_size(XSetup_aie *InstancePtr);
void XSetup_aie_Set_input_r(XSetup_aie *InstancePtr, u64 Data);
u64 XSetup_aie_Get_input_r(XSetup_aie *InstancePtr);

void XSetup_aie_InterruptGlobalEnable(XSetup_aie *InstancePtr);
void XSetup_aie_InterruptGlobalDisable(XSetup_aie *InstancePtr);
void XSetup_aie_InterruptEnable(XSetup_aie *InstancePtr, u32 Mask);
void XSetup_aie_InterruptDisable(XSetup_aie *InstancePtr, u32 Mask);
void XSetup_aie_InterruptClear(XSetup_aie *InstancePtr, u32 Mask);
u32 XSetup_aie_InterruptGetEnabled(XSetup_aie *InstancePtr);
u32 XSetup_aie_InterruptGetStatus(XSetup_aie *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
