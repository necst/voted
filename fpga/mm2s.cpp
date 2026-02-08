/*
MIT License

Copyright (c) 2023 Paolo Salvatore Galfano, Giuseppe Sorrentino

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
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

#include "mm2s.hpp"

constexpr int VEC_SIZE = 4; // 128 bits / 32 bits per elem = 4 elems per vector

extern "C" {

void mm2s(int32_t size, ap_int<128> *inputA, ap_int<128> *inputB,
          hls::stream<ap_int<128>> &outA, hls::stream<ap_int<128>> &outB) {

#pragma HLS interface axis port = outA
#pragma HLS interface axis port = outB
#pragma HLS INTERFACE m_axi port = inputA depth = 100 offset = slave bundle =  \
    gmem1
#pragma HLS INTERFACE m_axi port = inputB depth = 100 offset = slave bundle =  \
    gmem2
#pragma HLS interface s_axilite port = inputA bundle = control
#pragma HLS interface s_axilite port = inputB bundle = control

#pragma HLS interface s_axilite port = size bundle = control
#pragma HLS interface s_axilite port = return bundle = control

  // size = number of 32-bit elements
  for (int i = 0; i < size / VEC_SIZE; i++) {
    ap_int<128> a = inputA[i];
    ap_int<128> b = inputB[i];
    outA.write(a);
    outB.write(b);
  }
}
}
// extern "C"
