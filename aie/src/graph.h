#pragma once
#include "my_kernel_1.h"
#include <adf.h>

// ======================================================
//  Q: "How can I know the tile traversal? What is it?"
// ======================================================
//
// A: Tile traversal defines how the shared buffer is accessed by the DMA.
//    In simple terms, it tells the AIE: "read or write data in blocks of X,
//    with a stride of Y, until Z elements are transferred".
//
//    - buffer_dimension = total elements in the buffer (full shared buffer
//    size)
//    - tiling_dimension = number of elements transferred per tile (tile size)
//    - offset = starting index in the buffer
//    - tile_traversal = describes how the DMA moves from tile to tile
//
//    Here we split a 128-element buffer into 32 tiles of 4 elements each.
//

adf::tiling_parameters tile4_linear = {
    .buffer_dimension = {128}, // total elements stored in shared buffer
    .tiling_dimension = {4},   // each DMA transfer = 4 elements (1 tile)
    .offset = {0},             // start from first element
    .tile_traversal = {{
        .dimension = 0, // 1D buffer (1 dimension)
        .stride = 4,    // next tile begins after N elements -> try 1 and SEE!
        .wrap = 32 // when 32 blocks of 4 elements have been processed, reset!
                   // -> put here 128 and you will see 512 values, most of them
                   // are 0s (as input)
    }}};

// ======================================================
//  Full linear access, no tiling (single DMA burst of 128)
// ======================================================
adf::tiling_parameters linear_full = {
    .buffer_dimension = {128},
    .tiling_dimension = {128}, // full buffer read/write in one shot
    .offset = {0}};

using namespace adf;

class my_graph : public graph {

public:
  // ============
  // PLIO ports
  // ============
  input_plio pl_in_1;   // Input from PS/PL to AIE graph
  output_plio pl_out_1; // Output from AIE graph to PS/PL

  // ==================
  // Interface Tile I/O
  // ==================
  input_port inA;   // input after PLIO
  output_port outA; // output before PLIO

  // ==================
  // Shared Memory Tiles
  // ==================
  // Q: "How can we adapt the size? Must it be exact or max?"
  //
  // A: The allocated shared buffer must be >= the largest dataset
  //    that will be stored in it. It may be larger, but not smaller.
  //
  //    Here we allocate 128 elements, which matches the tiling parameters.
  //
  shared_buffer<int32_t> input_mem_tile;
  shared_buffer<int32_t> output_mem_tile;

  // ============
  // Kernel
  // ============
  kernel my_kernel_1;

  my_graph() {

    // Create PLIO endpoints (simulator reads/writes from .txt files)
    pl_in_1 = input_plio::create("in_plio_1", plio_32_bits,
                                 "data/in_plio_source_1.txt");
    pl_out_1 = output_plio::create("out_plio_1", plio_32_bits,
                                   "data/out_plio_sink_1.txt");

    my_kernel_1 = kernel::create(my_top_function);

    // ==============================================================
    // Allocate shared buffers physically placed inside Memory Tiles
    // ==============================================================

    input_mem_tile = shared_buffer<int32_t>::create({128}, 1, 1);
    output_mem_tile = shared_buffer<int32_t>::create({128}, 1, 1);

    // Q: "What is num_buffers? How can I modify this?"
    //
    // A: This enables double buffering. With 2 buffers, one tile can be
    //    processed by the kernel while the DMA fills the other.
    //    Values: 1 (single buffering) or 2 (ping-pong).
    //
    num_buffers(input_mem_tile) = 2;
    num_buffers(output_mem_tile) = 2;

    // ==============================
    // DATAFLOW CONNECTIONS
    // ==============================

    // PLIO -> Interface Tile
    connect(pl_in_1.out[0], inA);

    // Host input -> memory tile
    connect(inA, input_mem_tile.in[0]);
    write_access(input_mem_tile.in[0]) = linear_full; // full 128-element write

    // Memory tile -> kernel (tiled, 4-element chunks)
    connect(input_mem_tile.out[0], my_kernel_1.in[0]);
    read_access(input_mem_tile.out[0]) = tile4_linear;
    dimensions(my_kernel_1.in[0]) = {4}; // kernel receives vectors of 4 ints

    // Kernel output -> memory tile
    connect(my_kernel_1.out[0], output_mem_tile.in[0]);
    write_access(output_mem_tile.in[0]) = linear_full; // full-size write

    // Memory tile -> PLIO output
    connect(output_mem_tile.out[0], outA);
    dimensions(my_kernel_1.out[0]) = {4};
    read_access(output_mem_tile.out[0]) = linear_full;

    connect(outA, pl_out_1.in[0]);

    // =======================
    // Kernel metadata
    // =======================
    source(my_kernel_1) = "src/my_kernel_1.cpp";
    headers(my_kernel_1) = {"src/my_kernel_1.h", "../common/common.h"};
    runtime<ratio>(my_kernel_1) = 0.9; // AIE core reserved 90% for this kernel

    // Q: "Can we remove the tile location?"
    // A: Yes, unless you need manual placement. Otherwise ADF places it.
    // Note: manually placing files speedups AIE compile process
    location<kernel>(my_kernel_1) = tile(1, 1);
  };
};
