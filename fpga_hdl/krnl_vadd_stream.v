`timescale 1ns/1ps

module krnl_vadd_stream #(
  parameter SIZE = 128,
  parameter NUM_ELEMENTS = 4
)(
  input  wire                 ap_clk,
  input  wire                 ap_rst_n,

  // AXI4-Stream input A
  input  wire                 s_axis_a_tvalid,
  output wire                 s_axis_a_tready,
  input  wire [SIZE-1:0]      s_axis_a_tdata,
  input  wire                 s_axis_a_tlast,

  // AXI4-Stream input B
  input  wire                 s_axis_b_tvalid,
  output wire                 s_axis_b_tready,
  input  wire [SIZE-1:0]      s_axis_b_tdata,
  input  wire                 s_axis_b_tlast,

  // AXI4-Stream output
  output reg                  m_axis_out_tvalid,
  input  wire                 m_axis_out_tready,
  output reg  [SIZE-1:0]      m_axis_out_tdata,
  output reg                  m_axis_out_tlast
);

  // We can accept a new pair if output register is free,
  // or if downstream will consume current output this cycle.
  wire can_accept = (!m_axis_out_tvalid) || m_axis_out_tready;

  // Consume A and B only together
  wire take_pair = can_accept && s_axis_a_tvalid && s_axis_b_tvalid;

  assign s_axis_a_tready = can_accept && s_axis_b_tvalid;
  assign s_axis_b_tready = can_accept && s_axis_a_tvalid;

  wire [SIZE-1:0] sum_vec;

  v_add #(
    .SIZE(SIZE),
    .NUM_ELEMENTS(NUM_ELEMENTS)
  ) u_add (
    .in1(s_axis_a_tdata),
    .in2(s_axis_b_tdata),
    .out(sum_vec)
  );

  always @(posedge ap_clk or negedge ap_rst_n) begin
    if (!ap_rst_n) begin
      m_axis_out_tvalid <= 1'b0;
      m_axis_out_tdata  <= {SIZE{1'b0}};
      m_axis_out_tlast  <= 1'b0;
    end else begin
      // Clear valid when downstream consumes
      if (m_axis_out_tvalid && m_axis_out_tready) begin
        m_axis_out_tvalid <= 1'b0;
        m_axis_out_tlast  <= 1'b0;
      end

      // On input pair accept, produce output
      if (take_pair) begin
        m_axis_out_tdata  <= sum_vec;
        m_axis_out_tvalid <= 1'b1;

        // End-of-frame propagation (assumes aligned streams)
        m_axis_out_tlast  <= (s_axis_a_tlast && s_axis_b_tlast);
      end
    end
  end

endmodule
