
`timescale 1ns/1ps

module tb_krnl_and;

  // Clock / reset
  reg ap_clk;
  reg ap_rst_n;

  // AXI-Lite signals
  reg  [5:0]  awaddr;
  reg         awvalid;
  wire        awready;

  reg  [31:0] wdata;
  reg  [3:0]  wstrb;
  reg         wvalid;
  wire        wready;

  wire [1:0]  bresp;
  wire        bvalid;
  reg         bready;

  reg  [5:0]  araddr;
  reg         arvalid;
  wire        arready;

  wire [31:0] rdata;
  wire [1:0]  rresp;
  wire        rvalid;
  reg         rready;

  // DUT
  krnl_and dut (
    .ap_clk(ap_clk),
    .ap_rst_n(ap_rst_n),

    .s_axi_control_awaddr(awaddr),
    .s_axi_control_awvalid(awvalid),
    .s_axi_control_awready(awready),

    .s_axi_control_wdata(wdata),
    .s_axi_control_wstrb(wstrb),
    .s_axi_control_wvalid(wvalid),
    .s_axi_control_wready(wready),

    .s_axi_control_bresp(bresp),
    .s_axi_control_bvalid(bvalid),
    .s_axi_control_bready(bready),

    .s_axi_control_araddr(araddr),
    .s_axi_control_arvalid(arvalid),
    .s_axi_control_arready(arready),

    .s_axi_control_rdata(rdata),
    .s_axi_control_rresp(rresp),
    .s_axi_control_rvalid(rvalid),
    .s_axi_control_rready(rready)
  );

  // Clock: 100 MHz
  always #5 ap_clk = ~ap_clk;

  // ----------------------------
  // AXI-Lite helper tasks
  // ----------------------------
  task axil_write(input [5:0] addr, input [31:0] data);
    begin
      awaddr  <= addr;
      awvalid <= 1;
      wdata   <= data;
      wstrb   <= 4'b0001;
      wvalid  <= 1;
      bready  <= 1;

      wait (awready && wready);
      @(posedge ap_clk);

      awvalid <= 0;
      wvalid  <= 0;

      wait (bvalid);
      @(posedge ap_clk);
      bready <= 0;
    end
  endtask

  task axil_read(input [5:0] addr, output [31:0] data);
    begin
      araddr  <= addr;
      arvalid <= 1;
      rready  <= 1;

      wait (arready);
      @(posedge ap_clk);
      arvalid <= 0;

      wait (rvalid);
      data = rdata;
      @(posedge ap_clk);
      rready <= 0;
    end
  endtask
  
  // ----------------------------
  // Waveform dump (VCD)
  // ----------------------------
  initial begin
    $dumpfile("wave_krnl_and.vcd"); // relative path (goes where you run xsim)
    // Dump top-level TB signals (safe for most viewers)
    $dumpvars(0, tb_krnl_and);

    // Optional: also dump the DUT internal regs 
    // $dumpvars(0, dut.in1_reg);
    // $dumpvars(0, dut.in2_reg);
    // $dumpvars(0, dut.ap_start);
    // $dumpvars(0, dut.ap_done);
  end
  
  // ----------------------------
  // Test sequence
  // ----------------------------
  reg [31:0] val;

  initial begin
    ap_clk = 0;
    ap_rst_n = 0;

    awvalid = 0; wvalid = 0; arvalid = 0;
    bready  = 0; rready = 0;
    wstrb   = 0;

    #20;
    ap_rst_n = 1;

    // Write inputs 
    // the first value is an address, the second is the data to write. 

    // 6'h10 = ADDR_IN1 since in1 is mapped to address 0x10
    // 6'h18 = ADDR_IN2 since in2 is mapped to address 0x18

    axil_write(6'h10, 32'h1); // in1 = 1
    axil_write(6'h18, 32'h0); // in2 = 0

    // Start kernel
    axil_write(6'h00, 32'h1);

    // Read output
    axil_read(6'h20, val);

    if (val[0] !== 1'b0) begin
      $display("FAIL: expected 0, got %b", val[0]);
      $fatal;
    end else begin
      $display("PASS: AND result correct");
    end

    $finish;
  end

endmodule
