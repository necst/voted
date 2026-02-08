`timescale 1ns/1ps

// Goal: vector addition of two 4-element vectors -- use parameters

module v_add (in1, in2, out);
    
    parameter SIZE = 128; // size of the input and output vectors in bits;
    parameter NUM_ELEMENTS = 4; // number of elements in the vector
    parameter ELEMENT_SIZE = SIZE / NUM_ELEMENTS; // size of each element in bits

    input wire [SIZE-1:0] in1, in2; // 32-bit input vectors
    output wire [SIZE-1:0] out; // 32-bit output vector
    
genvar i; 
// 'genvar' is a special compile/elaboration-time variable.
// It is used ONLY inside 'generate' blocks. The loop is "unrolled"
// by the tool, creating NUM_ELEMENTS copies of the hardware.

generate
  // This generate-for does NOT run over time like a software loop.
  // Instead, at elaboration time it expands into NUM_ELEMENTS separate
  // continuous assignments (one per lane).

  for (i = 0; i < NUM_ELEMENTS; i = i + 1) begin : GEN_ADD
    // For lane i, select the ELEMENT_SIZE-bit slice of in1 and in2,
    // add them together, and drive the corresponding slice of out.
    //
    // Slice mapping (for each i):
    //   out[ (i+1)*ELEMENT_SIZE - 1 : i*ELEMENT_SIZE ] =
    //       in1[ (i+1)*ELEMENT_SIZE - 1 : i*ELEMENT_SIZE ] +
    //       in2[ (i+1)*ELEMENT_SIZE - 1 : i*ELEMENT_SIZE ]
    //
    // Result is lane-wise addition; carry does NOT propagate between lanes
    // (overflow is truncated to ELEMENT_SIZE bits).
    assign out[ELEMENT_SIZE-1 + ELEMENT_SIZE*i : ELEMENT_SIZE*i] =
           in1[ELEMENT_SIZE-1 + ELEMENT_SIZE*i : ELEMENT_SIZE*i] +
           in2[ELEMENT_SIZE-1 + ELEMENT_SIZE*i : ELEMENT_SIZE*i];
  end
endgenerate
endmodule