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

#pragma once
#include "my_kernel_1.h"
#include <adf.h>

// GIUSEPPE: How can I know the tile traversal? what is it?

/*
The starting element to traverse within the buffer (offset) is {0,0} and the
traversing parameters describe how the buffer will be accessed (tile_traversal).
The dimension of the traversing in this case is 0th and 1st (dimension). In
dimension 0, the distance in terms of buffer element data type between
consecutive inter-tile traversal is '16'(stride) and the number of tiles to
access in this dimension is '4'(wrap). Similarly in dimension 1, stride is '4'
and wrap is '16'.
*/

adf::tiling_parameters writeInput1_pattern = {
    .buffer_dimension = {128}, // buffer dimension
    .tiling_dimension = {4},   // tiling dimension
    .offset = {0},             // offset
    .tile_traversal = {{.dimension = 0,
                        .stride = 4,
                        .wrap = 128}} // tile traversal
};

// GIUSEPPE: How can I know the tile traversal? what is it?
adf::tiling_parameters readInput1_pattern = {
    .buffer_dimension = {128}, // buffer dimension
    .tiling_dimension = {4},   // tiling dimension
    .offset = {0},             // offset
    .tile_traversal = {{.dimension = 0,
                        .stride = 4,
                        .wrap = 128}} // tile traversal
};
using namespace adf;

class my_graph : public graph {

public:
  // ------Input and Output PLIO declaration------

  // PLIO
  input_plio pl_in_1;
  output_plio pl_out_1;

  // Interface Tile
  input_port inA;
  output_port outA;

  // Memory Tile
  shared_buffer<uint32_t> input_mem_tile;
  shared_buffer<uint32_t> output_mem_tile;

  // Kernel
  kernel my_kernel_1;

  my_graph() {
    // ------kernel creation------
    // The kernel creation takes as input the function name in the .h file of
    // the AIE kernel
    pl_in_1 = input_plio::create("in_plio_1", plio_32_bits,
                                 "data/in_plio_source_1.txt");
    pl_out_1 = output_plio::create("out_plio_1", plio_32_bits,
                                   "data/out_plio_sink_1.txt");
    my_kernel_1 = kernel::create(my_top_function);

    // Giuseppe: how can we adapt this size? it must be the exact size of the
    // input or the maximum one?
    input_mem_tile = shared_buffer<uint32_t>::create({128}, 1, 1);
    output_mem_tile = shared_buffer<uint32_t>::create({128}, 1, 1);

    // Giuseppe: What is this? How can I modify this?
    num_buffers(input_mem_tile) = 2;
    num_buffers(output_mem_tile) = 2;

    // ------ Connect Phase -------

    // Connect PLIO to Interface Tile
    connect(pl_in_1.out[0], inA);

    connect(inA, input_mem_tile.in[0]);
    write_access(input_mem_tile.in[0]) = writeInput1_pattern;
    connect(input_mem_tile.out[0], my_kernel_1.in[0]);
    read_access(input_mem_tile.out[0]) = readInput1_pattern;
    dimensions(input_mem_tile.out[0]) = {128};

    connect(my_kernel_1.out[0], output_mem_tile.in[0]);
    write_access(output_mem_tile.in[0]) = writeInput1_pattern;
    connect(output_mem_tile.out[0], outA);
    read_access(output_mem_tile.out[0]) = readInput1_pattern;
    dimensions(output_mem_tile.out[0]) = {128};

    connect(outA, pl_out_1.in[0]);

    source(my_kernel_1) = "src/my_kernel_1.cpp";
    headers(my_kernel_1) = {"src/my_kernel_1.h",
                            "../common/common.h"}; // you can specify more than
                                                   // one header to include
    runtime<ratio>(my_kernel_1) = 0.9;
    // set ratio - // 90% of the time the kernel will be executed. This means
    // that 1 AIE will be able to execute just 1 Kernel

    // GIUSEPPE: I do believe this can be removed - let's see TODO: Try
    location<kernel>(my_kernel_1) = tile(1, 1);
  };
};
