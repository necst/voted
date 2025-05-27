// File: PthreadSimSwemu.cpp
namespace x86sim 
{
    void *createSwemuSimulatorInstance();
}

// Instantiate the simulator
static void *sim = x86sim::createSwemuSimulatorInstance();
