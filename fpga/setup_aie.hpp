#ifndef SETUP_AIE_HPP
#define SETUP_AIE_HPP



#include "../common/common.h"
#include <cstdint>
#include <hls_stream.h>
#include <ap_int.h>

extern "C" {
    void setup_aie(int32_t size, int32_t* input, hls::stream<ap_int<sizeof(int32_t) * 8 * 4>>& s);
}

#endif // SETUP_AIE_HPP