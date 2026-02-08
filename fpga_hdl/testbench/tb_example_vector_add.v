`timescale 1ns/1ps

module tb_vadd #(
    parameter integer SIZE = 128,
    parameter integer NUM_ELEMENTS = 4
)();

    reg  [SIZE-1:0] inA, inB;
    wire [SIZE-1:0] out;

    // DUT
    v_add #(.SIZE(SIZE), .NUM_ELEMENTS(NUM_ELEMENTS)) dut (
        .in1(inA),
        .in2(inB),
        .out(out)
    );

    task check;
        input [SIZE-1:0] a, b;
        input [SIZE-1:0] y;
        begin
            inA = a; inB = b;
            #1;
            if (out !== y) begin
                $display("FAIL: inA=%h inB=%h expected=%h got=%h @t=%0t", a,b,y,out,$time);
                $fatal(1);
            end else begin
                $display("OK  : inA=%h inB=%h out=%h @t=%0t", a,b,out,$time);
            end
        end
    endtask
      // waveform dump: start dumping immediately so you capture all transitions
  initial begin
    $dumpfile("wave.vcd");
    // Dump ONLY top-level signals (no dut scope, avoids alias issues in some viewers)
    $dumpvars(0, inA);
    $dumpvars(0, inB);
    $dumpvars(0, out);
  end

    initial begin
        inA = 0;
        inB = 0;
        #1;

        // [1,2,3,4] + [5,6,7,8] = [6,8,10,12]
        check(128'h00000001000000020000000300000004,
               128'h00000005000000060000000700000008,
               128'h00000006000000080000000A0000000C);

        // [0xFFFFFFFF,...] + [1,1,1,1] = [0,0,0,0] (wrap-around per lane)
        check(128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
               128'h00000001000000010000000100000001,
               128'h00000000000000000000000000000000);

        // lane-wise 32-bit wrap-around expected
        check(128'h1234567890ABCDEF1234567890ABCDEF,
               128'hFEDCBA0987654321FEDCBA0987654321,
               128'h11111081181111101111108118111110);

        // [0,0,0,0] + [0xFFFFFFFF,...] = [0xFFFFFFFF,...]
        check(128'h00000000000000000000000000000000,
               128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
               128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
