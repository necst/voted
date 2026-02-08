#ifndef SETUP_AIE_HPP
#define SETUP_AIE_HPP

#include "../common/common.h"
#include <ap_int.h>
#include <cstdint>
#include <hls_stream.h>

extern "C" {
void mm2s(int32_t size, ap_int<128> *inputA, ap_int<128> *inputB,
          hls::stream<ap_int<128>> &outA, hls::stream<ap_int<128>> &outB);
}
#endif // SETUP_AIE_HPP