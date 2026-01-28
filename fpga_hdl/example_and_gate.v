`timescale 1ns/1ps

module example_and_gate( in1, in2, out );
    input in1, in2;
    output out;
    wire and_temp; // this creates a wire named and_temp
    assign and_temp = in1 & in2; // assign the and_temp wire to be the AND of in1 and in2
    assign out = and_temp; // assign the output to be the AND of in1 and in2
endmodule

