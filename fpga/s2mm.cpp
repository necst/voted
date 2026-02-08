/*
MIT License

Copyright (c) 2023 Paolo Salvatore Galfano, Giuseppe Sorrentino

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights,
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "s2mm.hpp"
#include "../common/common.h"
#include <ap_axi_sdata.h>
#include <ap_int.h>
#include <hls_math.h>

extern "C" {

void s2mm(hls::stream<int32_t> &input_stream, int32_t *output, int size) {

// PRAGMA for stream
#pragma HLS interface axis port = input_stream
#pragma HLS INTERFACE m_axi port = output depth = 100 offset = slave bundle =  \
    gmem1
#pragma HLS INTERFACE s_axilite port = output bundle = control
#pragma HLS interface s_axilite port = size bundle = control
#pragma HLS interface s_axilite port = return bundle = control

  for (int i = 0; i < size; i++) {
    int32_t x = input_stream.read();
    output[i] = x;
  }
}
}
// extern "C"
