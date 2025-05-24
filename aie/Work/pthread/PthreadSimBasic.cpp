// File: PthreadSimBasic.cpp
namespace x86sim 
{
    void *createBasicSimulatorInstance();
}

// Instantiate the simulator
static void *sim = x86sim::createBasicSimulatorInstance();
