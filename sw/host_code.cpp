#include "../common/common.h"
#include "experimental/xrt_kernel.h"
#include "experimental/xrt_uuid.h"
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>
#include <sys/stat.h>
#include <unistd.h>

// args indexes per kernel
#define arg_mm2s_size 0
#define arg_mm2s_inA 1
#define arg_mm2s_inB 2

#define arg_s2mm_output 1
#define arg_s2mm_size 2

std::ostream &bold_on(std::ostream &os);
std::ostream &bold_off(std::ostream &os);

int checkResult(int32_t *inputA, int32_t *inputB, int32_t *output, int size) {
  for (int i = 0; i < size; i++) {
    int val = inputA[i] + inputB[i];
    printf("output[%d] = %d\n", i, output[i]);
    if (val != output[i]) {
      std::cout << "Error at index " << i << ": " << val << " != " << output[i]
                << std::endl;
      return EXIT_FAILURE;
    }
  }
  std::cout << "Test passed!" << std::endl;
  return EXIT_SUCCESS;
}

int main(int argc, char *argv[]) {
  if (argc < 2) {
    std::cerr << "Usage: " << argv[0] << " <XCLBIN_PATH> [--hw_emu] [DEVICE_ID]"
              << std::endl;
    return EXIT_FAILURE;
  }

  std::string xclbin_file = argv[1];

  int device_id = 0;
  if (argc >= 4) {
    device_id = std::stoi(argv[3]);
  }

  char *env_emu = getenv("XCL_EMULATION_MODE");
  if (env_emu && std::string(env_emu) == "hw_emu") {
    std::cout << bold_on << "Program running in hardware emulation mode"
              << bold_off << std::endl;
  } else {
    std::cout << bold_on << "Program running in hardware mode" << bold_off
              << std::endl;
  }

  std::cout << "1. Loading bitstream (" << xclbin_file << ") on device "
            << device_id << "... ";
  xrt::device device = xrt::device(device_id);
  xrt::uuid xclbin_uuid = device.load_xclbin(xclbin_file);
  std::cout << "Done" << std::endl;

  xrt::kernel krnl_mm2s = xrt::kernel(device, xclbin_uuid, "mm2s");
  xrt::kernel krnl_s2mm = xrt::kernel(device, xclbin_uuid, "s2mm");

  xrtMemoryGroup bank_inputA = krnl_mm2s.group_id(arg_mm2s_inA);
  xrtMemoryGroup bank_inputB = krnl_mm2s.group_id(arg_mm2s_inB);
  xrtMemoryGroup bank_output = krnl_s2mm.group_id(arg_s2mm_output);

  const int32_t size = 128;
  int32_t numsA[size];
  int32_t numsB[size];
  for (int i = 0; i < size; i++) {
    numsA[i] = 1;
    numsB[i] = 2;
  }

  xrt::bo buf_inA = xrt::bo(device, size * sizeof(int32_t),
                            xrt::bo::flags::normal, bank_inputA);
  xrt::bo buf_inB = xrt::bo(device, size * sizeof(int32_t),
                            xrt::bo::flags::normal, bank_inputB);
  xrt::bo buf_out = xrt::bo(device, size * sizeof(int32_t),
                            xrt::bo::flags::normal, bank_output);

  xrt::run run_mm2s = xrt::run(krnl_mm2s);
  xrt::run run_s2mm = xrt::run(krnl_s2mm);

  run_mm2s.set_arg(arg_mm2s_size, size);
  run_mm2s.set_arg(arg_mm2s_inA, buf_inA);
  run_mm2s.set_arg(arg_mm2s_inB, buf_inB);

  run_s2mm.set_arg(arg_s2mm_output, buf_out);
  run_s2mm.set_arg(arg_s2mm_size, size);

  buf_inA.write(numsA);
  buf_inB.write(numsB);
  buf_inA.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  buf_inB.sync(XCL_BO_SYNC_BO_TO_DEVICE);

  run_s2mm.start();
  run_mm2s.start();

  run_mm2s.wait();
  run_s2mm.wait();

  buf_out.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  int32_t output_buffer[size];
  buf_out.read(output_buffer);

  return checkResult(numsA, numsB, output_buffer, size);
}

std::ostream &bold_on(std::ostream &os) { return os << "\e[1m"; }
std::ostream &bold_off(std::ostream &os) { return os << "\e[0m"; }