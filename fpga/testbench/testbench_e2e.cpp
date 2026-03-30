/*
MIT License

Copyright (c) 2023 Paolo Salvatore Galfano, Giuseppe Sorrentino
*/

#include "../setup_aie.hpp"
#include "../sink_from_aie.hpp"
#include "utils.hpp"
#include <vector>

#include <ap_axi_sdata.h>
#include <cstdlib> // system
#include <iostream>
#include <string>
#include <sys/stat.h>
#include <unistd.h>

/** AIE project root relative to this testbench executable (run from
 * testbench/). */
static const std::string AIE_ROOT = "../../aie/";

/** Helper: run the AIE x86 simulator via the AIE Makefile. */
static void run_aie_x86_sim() {
  std::string cmd = "make -C " + AIE_ROOT + " aie_simulate_x86";
  std::cout << "\n-> Running AIE: " << cmd << std::endl << std::flush;
  int ret = system(cmd.c_str());
  if (ret != 0) {
    std::cerr << "ERROR: AIE simulation command failed with code " << ret
              << std::endl;
    throw std::exception();
  }
  std::cout << "-> AIE simulation done.\n" << std::endl;
}

/** Helper: ensure output directory exists (best-effort). */
static void mkdir_p(const std::string &dir) {
  std::string cmd = "mkdir -p " + dir;
  (void)system(cmd.c_str());
}

int main(int argc, char *argv[]) {
  // Keep the same default size used in your existing unit testbenches.
  const int size = 128;

  // ------------------------------------------------------------------------------------
  // (1) Generate the AIE input file (same path/content/format as
  // testbench_setupaie)
  // ------------------------------------------------------------------------------------
  std::cout
      << "-> Generating AIE input file (setup_aie -> in_plio_source_1.txt)\n";

  // setup_aie produces a 128-bit stream (4x32-bit lanes)
  hls::stream<ap_int<sizeof(float) * 8 * 4>> setup_stream("setup_stream");

  // NOTE: your setup_aie signature in the simple TB is: setup_aie(size, input,
  // s); If your real setup_aie differs, adapt here accordingly.
  int *input = new int[size];
  for (int i = 0; i < size; i++)
    input[i] = i;

  setup_aie(size, input, setup_stream);

  // Ensure destination folder exists (optional, but avoids silent failures)
  mkdir_p(AIE_ROOT + "data/");

  // Dump as 1 float per line (PLIO_32) exactly like your updated unit TB
  write_stream_to_file_unpack<ap_int<sizeof(float) * 8 * 4>, float>(
      setup_stream, AIE_ROOT + "data/in_plio_source_1.txt", PLIO_32);

  // ------------------------------------------------------------------------------------
  // (2) Run AIE simulation (x86)
  // ------------------------------------------------------------------------------------
  run_aie_x86_sim();

  // ------------------------------------------------------------------------------------
  // (3) Read AIE output file into a stream (skip TLAST tokens)
  // ------------------------------------------------------------------------------------
  std::cout << "-> Reading AIE output file (out_plio_sink_1.txt)\n";

  hls::stream<int32_t> aie_out_stream("aie_out_stream");
  const std::string aie_out_path =
      AIE_ROOT + "x86simulator_output/data/out_plio_sink_1.txt";

  // Skip textual markers like "TLAST" that may be interleaved with numeric
  // tokens.
  read_stream_from_file_skip_tlast<int32_t>(aie_out_stream, aie_out_path);

  const int n_read = (int)aie_out_stream.size();
  std::cout << "-> Parsed " << n_read << " numeric tokens from AIE output\n";

  if (n_read == 0) {
    std::cerr << "ERROR: AIE output stream is empty. Check that AIE simulation "
                 "produced data."
              << std::endl;
    return 1;
  }

  // ------------------------------------------------------------------------------------
  // (4) Run sink_from_aie on the produced stream and print results
  // ------------------------------------------------------------------------------------
  std::cout << "-> Running sink_from_aie and printing results\n";

  // Allocate output buffer big enough for what we will consume
  int32_t *buffer = new int32_t[n_read];

  sink_from_aie(aie_out_stream, buffer, n_read);

  std::cout << "Output values:\n";
  for (int i = 0; i < n_read; i++) {
    std::cout << buffer[i] << std::endl;
  }

  // ------------------------------------------------------------------------------------
  // (5) Validate: AIE kernel - read input from file and check output with input
  // +2
  // ------------------------------------------------------------------------------------
  std::cout << "\n-> Validating output\n";

  int mismatches = 0;

  for (int idx = 0; idx < size; idx++) {
    int32_t expected = static_cast<int32_t>(input[idx]) + 2;
    if (buffer[idx] != expected) {
      if (mismatches < 20) {
        std::cerr << "Mismatch @ " << idx << ": in=" << input[idx]
                  << " expected=" << expected << " got=" << buffer[idx] << "\n";
      }
      mismatches++;
    }
    idx++;
  }

  if (mismatches == 0) {
    std::cout << "PASS: all " << n_read << " outputs match\n";
  } else {
    std::cerr << "FAIL: " << mismatches << " mismatches out of " << n_read
              << " checked elements.\n";
    delete[] buffer;
    delete[] input;
    return 1;
  }

  delete[] buffer;
  delete[] input;

  std::cout << "\n--- E2E TESTBENCH COMPLETED ---\n";
  return 0;
}
