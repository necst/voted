// This is a testbench for the example_and_gate module
`timescale 1ns/1ps

module tb_example_and_gate;
  reg  in1, in2; // drive inputs from the testbench
  wire out;

  // dut: device under test -- instantiation of the example_and_gate module
  example_and_gate dut (
    .in1(in1),
    .in2(in2),
    .out(out)
  );

  // task: a reusable block to apply inputs and check outputs
  task expect;
    input reg a, b;
    input reg y;
    begin
      in1 = a; in2 = b;
      #1; // wait for 1 time unit for the output to settle
      if (out !== y) begin
        $display("FAIL: in1=%0b in2=%0b expected=%0b got=%0b @t=%0t", a,b,y,out,$time);
        $fatal(1);
      end else begin
        $display("OK  : in1=%0b in2=%0b out=%0b @t=%0t", a,b,out,$time);
      end
    end
  endtask

  // waveform dump: start dumping immediately so you capture all transitions
  initial begin
    $dumpfile("wave.vcd");
    // Dump ONLY top-level signals (no dut scope, avoids alias issues in some viewers)
    $dumpvars(0, in1);
    $dumpvars(0, in2);
    $dumpvars(0, out);
  end

  // initial block: where the test sequence is defined
  initial begin
    // Initialize inputs to known values (avoid initial X in the waveform)
    in1 = 0;
    in2 = 0;
    #1;

    // Test all combinations of inputs for a 2-input AND gate
    expect(0,0,0);
    expect(0,1,0);
    expect(1,0,0);
    expect(1,1,1);

    $display("ALL TESTS PASSED");
    $finish; // end the simulation
  end
endmodule
