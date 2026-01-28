`timescale 1ns/1ps


// parameter: it is a module-level constant
module krnl_and #
(
  parameter integer C_S_AXI_ADDR_WIDTH = 6, // 2^6 addresses -> 64 bytes of address space
  parameter integer C_S_AXI_DATA_WIDTH = 32 // 32-bit data bus
)
(
// clk: global clock signal -> all logic is synchronous to this clock
// rst_n: active-low reset signal

// clk is mandatory for axi-lite interfaces
  input  wire                          ap_clk,
  input  wire                          ap_rst_n,

  // AXI4-Lite slave interface (control)
  // AXI4-lite exposes a simple memory-mapped interface for reading/writing registers

  // a first wire contains the address, 
  input  wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_control_awaddr,
  input  wire                          s_axi_control_awvalid, // address valid
  output reg                           s_axi_control_awready, // address ready
  
  // a second wire contains the data to write
  input  wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_control_wdata, // data to write -> from master to slave
  input  wire [C_S_AXI_DATA_WIDTH/8-1:0] s_axi_control_wstrb, // byte enables -> it says which bytes of the data bus are valid
  input  wire                          s_axi_control_wvalid, // data valid -> master says "data is valid"
  output reg                           s_axi_control_wready, // data ready -> slave says "i'm ready to accept data"

  output reg  [1:0]                    s_axi_control_bresp, // write response (OKAY, SLVERR, etc)
  output reg                           s_axi_control_bvalid, // write response valid
  input  wire                          s_axi_control_bready, // write response ready

  input  wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_control_araddr, // read address
  input  wire                          s_axi_control_arvalid, // read address valid
  output reg                           s_axi_control_arready, // read address ready

  output reg  [C_S_AXI_DATA_WIDTH-1:0] s_axi_control_rdata, // read data -> from slave to master
  output reg  [1:0]                    s_axi_control_rresp, // read response (OKAY, SLVERR, etc)
  output reg                           s_axi_control_rvalid, // read data valid
  input  wire                          s_axi_control_rready // read data ready
);

  // ----------------------------
  // Local regs (kernel arguments)
  // ----------------------------
  // Axi-lite: it reads/writes registers. 
  // Now we create local regs to hold the values of the registers.
  // These regs are mapped to addresses.
  // These regs are the kernel arguments.
  reg in1_reg;
  reg in2_reg;

  wire out_wire;

  // DUT (your original module)
  // Here we instantiate the original example_and_gate module and connect the inputs/outputs
  // the registers we created above are connected to the inputs of the DUT
  example_and_gate dut (
    .in1(in1_reg),
    .in2(in2_reg),
    .out(out_wire)
  );

  // ----------------------------
  // ap_ctrl_hs style signals
  // ----------------------------
  reg ap_start;
  reg ap_done;
  
  // idle = 1 -> kernel is not doing anything
  // ready = 1 -> kernel can accept new inputs
  // notably, for a combinational kernel, ap_idle and ap_ready are always 1
  // because the kernel is always ready to accept new inputs and is never busy
  // so we can tie them to constant 1'b1. However, ap_start and ap_done are still needed.
  // For non-combinational kernels, these signals would have more complex behavior.
  wire ap_idle  = 1'b1;  // combinational, always idle
  wire ap_ready = 1'b1;  // always ready

  // Clear-on-read behavior for ap_done
  wire read_ctrl_reg;
  // ap_done is cleared when the control register is read

  // ----------------------------
  // AXI Lite single-transaction handling
  // ----------------------------
  // internal registers to hold the read and write addresses
  reg [C_S_AXI_ADDR_WIDTH-1:0] waddr;
  reg [C_S_AXI_ADDR_WIDTH-1:0] raddr;

  // Address constants (byte addresses)
  // once Axii-lite address is decoded, we can use these constants to identify which register is being accessed
  // here I am saying ADDR10 is the address where in1 is mapped
  // C_S_AXI_ADDR_WIDTH = 6, so addresses are 6 bits wide, from 0 to C_S_AXI_ADDR_WIDTH-1
  // C_S_AXI_ADDR_WIDTH is also the width of the address bus. In verilog numbers are specified as <size>'<base><value>
  // e.g., 6'h10 means a 6-bit wide hexadecimal number with value 0x10
  localparam [C_S_AXI_ADDR_WIDTH-1:0] ADDR_CTRL = 6'h00;
  localparam [C_S_AXI_ADDR_WIDTH-1:0] ADDR_IN1  = 6'h10;
  localparam [C_S_AXI_ADDR_WIDTH-1:0] ADDR_IN2  = 6'h18;
  localparam [C_S_AXI_ADDR_WIDTH-1:0] ADDR_OUT  = 6'h20;

  // Write strobes helper: write only bit0 if byte0 strobe asserted
  wire wstrb_byte0 = s_axi_control_wstrb[0];

  // Detect read of control reg to clear ap_done
  assign read_ctrl_reg = (s_axi_control_arvalid && s_axi_control_arready && (s_axi_control_araddr == ADDR_CTRL));

  // ----------------------------
  // Reset + main AXI processes
  // ----------------------------
  always @(posedge ap_clk) begin // at each clock cicle

    // if rst = 0 -> reset all registers to default values
    // _n means active-low reset. When rst=1, normal operation, when rst=0, reset
    if (!ap_rst_n) begin
      // AXI outputs

      s_axi_control_awready <= 1'b0;
      s_axi_control_wready  <= 1'b0;
      s_axi_control_bvalid  <= 1'b0;
      s_axi_control_bresp   <= 2'b00;
      s_axi_control_arready <= 1'b0;
      s_axi_control_rvalid  <= 1'b0;
      s_axi_control_rresp   <= 2'b00;
      s_axi_control_rdata   <= {C_S_AXI_DATA_WIDTH{1'b0}};

      // Internal
      waddr    <= {C_S_AXI_ADDR_WIDTH{1'b0}};
      raddr    <= {C_S_AXI_ADDR_WIDTH{1'b0}};
      in1_reg  <= 1'b0;
      in2_reg  <= 1'b0;
      ap_start <= 1'b0;
      ap_done  <= 1'b0;
    end else begin
      // ----------------------------
      // Write address channel
      // ----------------------------
      if (!s_axi_control_awready && s_axi_control_awvalid) begin
        // if slave is not ready and master is sending a valid address
        // then set awready to 1 and capture the address
        s_axi_control_awready <= 1'b1;
        waddr <= s_axi_control_awaddr;
      end else begin
        // else, lower awready
        s_axi_control_awready <= 1'b0;
      end

      // ----------------------------
      // Write data channel
      // ----------------------------
      if (!s_axi_control_wready && s_axi_control_wvalid) begin
        // if slave is not ready and master is sending valid data
        // then set wready to 1
        s_axi_control_wready <= 1'b1;
      end else begin
        // else, lower wready
        s_axi_control_wready <= 1'b0;
      end

      // Perform write when both address+data handshake in same cycle (simple slave)
      if (s_axi_control_awvalid && s_axi_control_awready && s_axi_control_wvalid && s_axi_control_wready) begin
        // if both address and data are valid and ready then perform the write
        s_axi_control_bvalid <= 1'b1;
        s_axi_control_bresp  <= 2'b00;

        case (waddr) // decode the write address
          ADDR_CTRL: begin // if writing to control register
            // bit0 = ap_start (W)
            if (wstrb_byte0) begin // if byte0 strobe is asserted
              ap_start <= s_axi_control_wdata[0]; // set ap_start
              // For this simple combinational kernel: pulse ap_done when started
              if (s_axi_control_wdata[0]) begin // if ap_start is set to 1
                ap_done <= 1'b1; // set ap_done to 1 immediately
              end
            end
          end

          ADDR_IN1: begin // if writing to in1 register
            if (wstrb_byte0) in1_reg <= s_axi_control_wdata[0]; // set in1_reg
          end

          ADDR_IN2: begin // if writing to in2 register
            if (wstrb_byte0) in2_reg <= s_axi_control_wdata[0]; // set in2_reg
          end
            default: begin
                // do nothing for undefined addresses
            end
        endcase
      end
        // Clear bvalid when master acknowledges the write response
        if (s_axi_control_bvalid && s_axi_control_bready) begin
            s_axi_control_bvalid <= 1'b0;
            end
        // ----------------------------
        // Read address channel
        // ----------------------------
        if (!s_axi_control_arready && s_axi_control_arvalid) begin
            // if slave is not ready and master is sending a valid read address
            // then set arready to 1 and capture the address
            s_axi_control_arready <= 1'b1;
            raddr <= s_axi_control_araddr;
        end else begin
            // else, lower arready
            s_axi_control_arready <= 1'b0;
        end
        // ----------------------------
        // Read data channel
        // ----------------------------
        if (s_axi_control_arvalid && s_axi_control_arready && !s_axi_control_rvalid) begin
            // if address handshake occurs and rvalid is not already set
            s_axi_control_rvalid <= 1'b1;
            s_axi_control_rresp  <= 2'b00;

            case (raddr) // decode the read address
                ADDR_CTRL: begin
                    s_axi_control_rdata <= {31'b0, ap_done}; // bit0 = ap_done (RO)
                end

                ADDR_IN1: begin
                    s_axi_control_rdata <= {31'b0, in1_reg}; // read in1_reg
                end

                ADDR_IN2: begin
                    s_axi_control_rdata <= {31'b0, in2_reg}; // read in2_reg
                end

                ADDR_OUT: begin
                    s_axi_control_rdata <= {31'b0, out_wire}; // read out_wire
                end

                default: begin
                    s_axi_control_rdata <= {C_S_AXI_DATA_WIDTH{1'b0}}; // return 0 for undefined addresses
                end
            endcase
        end
        // Clear rvalid when master acknowledges the read data
        if (s_axi_control_rvalid && s_axi_control_rready) begin
            s_axi_control_rvalid <= 1'b0;
        end
        // Clear ap_done on read of control register
        if (read_ctrl_reg) begin
            ap_done <= 1'b0;
        end
    end
end
endmodule

