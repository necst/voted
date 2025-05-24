#ifndef SINK_FROM_AIE_HPP
#define SINK_FROM_AIE_HPP

#include <cstdint>
#include <hls_stream.h>

extern "C" {
    void sink_from_aie(
        hls::stream<int32_t>& input_stream, 
        int32_t* output, 
        int size);
}

#endif // SINK_FROM_AIE_HPP
