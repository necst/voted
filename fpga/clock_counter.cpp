#include <ap_int.h>
#include <hls_stream.h>
#include <stdint.h>

extern "C" {

void clock_counter(
    hls::stream<ap_uint<8>>& start_s,
    hls::stream<ap_uint<8>>& end_s,
    uint64_t* cycles
) {
#pragma HLS INTERFACE axis port=start_s
#pragma HLS INTERFACE axis port=end_s

#pragma HLS INTERFACE m_axi port=cycles offset=slave bundle=gmem0 depth=1

#pragma HLS INTERFACE s_axilite port=cycles bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control

    ap_uint<8> dummy_start;
    ap_uint<8> dummy_end;

    // Aspetta token di start
    start_s.read(dummy_start);

    uint64_t cnt = 0;

count_loop:
    while (end_s.read_nb(dummy_end) == false) {
#pragma HLS PIPELINE II=1
        cnt++;
    }

    cycles[0] = cnt;
}

}