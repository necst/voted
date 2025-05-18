/*
MIT License

Copyright (c) 2023 Paolo Salvatore Galfano, Giuseppe Sorrentino

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

[...]
*/

#include <iostream>
#include <fstream>
#include <cstdlib>
#include <unistd.h>
#include <sys/stat.h>
#include <string>
#include "experimental/xrt_kernel.h"
#include "experimental/xrt_uuid.h"
#include "../common/common.h"

#define DEVICE_ID 0

// args indexes per kernel
#define arg_setup_aie_size    0
#define arg_setup_aie_input   1
#define arg_sink_from_aie_output 1
#define arg_sink_from_aie_size   2

std::ostream& bold_on(std::ostream& os);
std::ostream& bold_off(std::ostream& os);

int checkResult(int32_t* input, int32_t* output, int size) {
    for (int i = 0; i < size; i++) {
        if (input[i] != output[i]) {
            std::cout << "Error at index " << i
                      << ": " << input[i]
                      << " != " << output[i] << std::endl;
            return EXIT_FAILURE;
        }
    }
    std::cout << "Test passed!" << std::endl;
    return EXIT_SUCCESS;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <XCLBIN_PATH> [--hw_emu]" << std::endl;
        return EXIT_FAILURE;
    }
    std::string xclbin_file = argv[1];

    char *env_emu = getenv("XCL_EMULATION_MODE");
    if (env_emu && std::string(env_emu) == "hw_emu") {
        std::cout << bold_on << "Program running in hardware emulation mode" << bold_off << std::endl;
    }
    else {
        std::cout << bold_on << "Program running in hardware mode" << bold_off << std::endl;
    }

    // ------------------------------------------------LOADING XCLBIN------------------------------------------    
    std::cout << "1. Loading bitstream (" << xclbin_file << ")... ";
    xrt::device device = xrt::device(DEVICE_ID);
    xrt::uuid xclbin_uuid = device.load_xclbin(xclbin_file);
    std::cout << "Done" << std::endl;
    // ---------------------------------------INITIALIZING THE BOARD------------------------------------------
    xrt::kernel krnl_setup_aie     = xrt::kernel(device, xclbin_uuid, "setup_aie");
    xrt::kernel krnl_sink_from_aie = xrt::kernel(device, xclbin_uuid, "sink_from_aie");

    xrtMemoryGroup bank_input  = krnl_setup_aie.group_id(arg_setup_aie_input);
    xrtMemoryGroup bank_output = krnl_sink_from_aie.group_id(arg_sink_from_aie_output);

    const int32_t size = 32;
    int32_t nums[size];
    for (int i = 0; i < size; i++) nums[i] = i + 1;

    xrt::bo buf_in  = xrt::bo(device, size * sizeof(int32_t), xrt::bo::flags::normal, bank_input);
    xrt::bo buf_out = xrt::bo(device, size * sizeof(int32_t), xrt::bo::flags::normal, bank_output);

    xrt::run run_setup  = xrt::run(krnl_setup_aie);
    xrt::run run_sink   = xrt::run(krnl_sink_from_aie);

    run_setup.set_arg(arg_setup_aie_size,  size);
    run_setup.set_arg(arg_setup_aie_input, buf_in);

    run_sink.set_arg(arg_sink_from_aie_output, buf_out);
    run_sink.set_arg(arg_sink_from_aie_size,   size);

    buf_in.write(nums);
    buf_in.sync(XCL_BO_SYNC_BO_TO_DEVICE);

    run_sink.start();
    run_setup.start();

    run_setup.wait();
    run_sink.wait();

    buf_out.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    int32_t output_buffer[size];
    buf_out.read(output_buffer);

    return checkResult(nums, output_buffer, size);
}

std::ostream& bold_on(std::ostream& os)  { return os << "\e[1m"; }
std::ostream& bold_off(std::ostream& os) { return os << "\e[0m"; }
