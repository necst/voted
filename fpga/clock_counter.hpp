#ifndef CLOCK_COUNTER_HPP
#define CLOCK_COUNTER_HPP

#include "../common/common.h"
#include <cstdint>
#include <hls_stream.h>
#include <ap_int.h>

extern "C" {

void clock_counter(
    hls::stream<ap_uint<8>>& start_s,
    hls::stream<ap_uint<8>>& end_s,
    uint64_t* cycles
);

}

#endif // CLOCK_COUNTER_HPP