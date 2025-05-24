// File: PthreadSimXmc.cpp
#include "adf/x86sim/symbolVisibility.h"
namespace x86sim 
{
    void *createXmcSimulator();
}

extern "C" {
X86SIM_EXPORT void *xmcSimInit()
{
    return x86sim::createXmcSimulator();
}
}
