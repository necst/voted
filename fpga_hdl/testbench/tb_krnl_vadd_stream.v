`timescale 1ns/1ps

module tb_krnl_vadd_stream_axis;

  //----------------------------------------------------------------------------
  // Parameters
  //----------------------------------------------------------------------------
  localparam integer SIZE         = 128;
  localparam integer NUM_ELEMENTS = 4;
  localparam integer LANE_W       = SIZE / NUM_ELEMENTS;

  //----------------------------------------------------------------------------
  // Clock / Reset
  //----------------------------------------------------------------------------
  reg ap_clk;
  reg ap_rst_n;

  initial ap_clk = 1'b0;
  always #2.5 ap_clk = ~ap_clk; // 200 MHz

  task do_reset;
    begin
      ap_rst_n = 1'b0;
      repeat (5) @(posedge ap_clk);
      ap_rst_n = 1'b1;
      repeat (2) @(posedge ap_clk);
    end
  endtask

  //----------------------------------------------------------------------------
  // DUT I/O (stream-only)
  //----------------------------------------------------------------------------
  reg                 s_axis_a_tvalid;
  wire                s_axis_a_tready;
  reg  [SIZE-1:0]     s_axis_a_tdata;
  reg                 s_axis_a_tlast;

  reg                 s_axis_b_tvalid;
  wire                s_axis_b_tready;
  reg  [SIZE-1:0]     s_axis_b_tdata;
  reg                 s_axis_b_tlast;

  wire                m_axis_out_tvalid;
  reg                 m_axis_out_tready;
  wire [SIZE-1:0]     m_axis_out_tdata;
  wire                m_axis_out_tlast;

  //----------------------------------------------------------------------------
  // Instantiate DUT (stream-only krnl_vadd_stream)
  //----------------------------------------------------------------------------
  krnl_vadd_stream #(
    .SIZE(SIZE),
    .NUM_ELEMENTS(NUM_ELEMENTS)
  ) dut (
    .ap_clk(ap_clk),
    .ap_rst_n(ap_rst_n),

    .s_axis_a_tvalid(s_axis_a_tvalid),
    .s_axis_a_tready(s_axis_a_tready),
    .s_axis_a_tdata (s_axis_a_tdata),
    .s_axis_a_tlast (s_axis_a_tlast),

    .s_axis_b_tvalid(s_axis_b_tvalid),
    .s_axis_b_tready(s_axis_b_tready),
    .s_axis_b_tdata (s_axis_b_tdata),
    .s_axis_b_tlast (s_axis_b_tlast),

    .m_axis_out_tvalid(m_axis_out_tvalid),
    .m_axis_out_tready(m_axis_out_tready),
    .m_axis_out_tdata (m_axis_out_tdata),
    .m_axis_out_tlast (m_axis_out_tlast)
  );

  //----------------------------------------------------------------------------
  // Reference model (lane-wise add)
  //----------------------------------------------------------------------------
  function [SIZE-1:0] ref_add;
    input [SIZE-1:0] a;
    input [SIZE-1:0] b;
    integer i;
    reg [SIZE-1:0] y;
    reg [LANE_W-1:0] la, lb, ls;
    begin
      y = '0;
      for (i = 0; i < NUM_ELEMENTS; i = i + 1) begin
        la = a[i*LANE_W +: LANE_W];
        lb = b[i*LANE_W +: LANE_W];
        ls = la + lb;
        y[i*LANE_W +: LANE_W] = ls;
      end
      ref_add = y;
    end
  endfunction

  //----------------------------------------------------------------------------
  // Scoreboard queue: expected data + expected TLAST
  //----------------------------------------------------------------------------
  typedef struct packed {
    logic [SIZE-1:0] data;
    logic            last;
  } exp_t;

  exp_t exp_q[$];
  integer rx_count;
  integer tx_count;

  //----------------------------------------------------------------------------
  // X-proof handshake detectors
  //----------------------------------------------------------------------------
  wire in_fire;
  assign in_fire =
      (s_axis_a_tvalid === 1'b1) && (s_axis_a_tready === 1'b1) &&
      (s_axis_b_tvalid === 1'b1) && (s_axis_b_tready === 1'b1);

  wire out_fire;
  assign out_fire =
      (m_axis_out_tvalid === 1'b1) && (m_axis_out_tready === 1'b1);

  //----------------------------------------------------------------------------
  // Expected generator:
  // enqueue expected when DUT accepts an input pair
  // expected last = (a_last & b_last) to match DUT policy
  //----------------------------------------------------------------------------
  always @(posedge ap_clk or negedge ap_rst_n) begin
    if (!ap_rst_n) begin
      tx_count <= 0;
    end else begin
      if (in_fire) begin
        exp_t ee;
        ee.data = ref_add(s_axis_a_tdata, s_axis_b_tdata);
        ee.last = (s_axis_a_tlast && s_axis_b_tlast);
        exp_q.push_back(ee);
        tx_count <= tx_count + 1;
      end
    end
  end

  //----------------------------------------------------------------------------
  // Input driver:
  // drive on negedge, wait handshake on posedge, clear on negedge
  // TLAST is driven according to a packet length N
  //----------------------------------------------------------------------------
  task automatic send_pair;
    input [SIZE-1:0] a;
    input [SIZE-1:0] b;
    input            last_a;
    input            last_b;
    integer gap;
    begin
      @(negedge ap_clk);
      s_axis_a_tdata  = a;
      s_axis_b_tdata  = b;
      s_axis_a_tlast  = last_a;
      s_axis_b_tlast  = last_b;
      s_axis_a_tvalid = 1'b1;
      s_axis_b_tvalid = 1'b1;

      while (in_fire !== 1'b1) begin
        @(posedge ap_clk);
      end

      @(negedge ap_clk);
      s_axis_a_tvalid = 1'b0;
      s_axis_b_tvalid = 1'b0;
      s_axis_a_tdata  = '0;
      s_axis_b_tdata  = '0;
      s_axis_a_tlast  = 1'b0;
      s_axis_b_tlast  = 1'b0;

      gap = ($urandom % 3);
      repeat (gap) @(posedge ap_clk);
    end
  endtask

  //----------------------------------------------------------------------------
  // Output sink with random backpressure + checks
  //----------------------------------------------------------------------------
  task automatic run_sink;
    exp_t e;
    begin
      rx_count = 0;
      forever begin
        @(posedge ap_clk);

        if (!ap_rst_n) begin
          m_axis_out_tready <= 1'b0;
        end else begin
          m_axis_out_tready <= (($urandom % 4) != 0); // ~75% ready

          if (out_fire) begin
            if (exp_q.size() == 0) begin
              $fatal(1, "[SINK] Unexpected output. data=%h last=%0d",
                     m_axis_out_tdata, m_axis_out_tlast);
            end

            e = exp_q.pop_front();

            if (m_axis_out_tdata !== e.data) begin
              $fatal(1, "[SINK] Data mismatch. got=%h exp=%h (rx_count=%0d)",
                     m_axis_out_tdata, e.data, rx_count);
            end

            if (m_axis_out_tlast !== e.last) begin
              $fatal(1, "[SINK] TLAST mismatch. got=%0d exp=%0d (rx_count=%0d)",
                     m_axis_out_tlast, e.last, rx_count);
            end

            rx_count = rx_count + 1;
          end
        end
      end
    end
  endtask

  //----------------------------------------------------------------------------
  // Timeout watchdog
  //----------------------------------------------------------------------------
  initial begin
    #200_000; // 200 us
    $fatal(1, "[TB] TIMEOUT tx=%0d rx=%0d expq=%0d | A(v/r)=%0d/%0d B(v/r)=%0d/%0d | OUT(v/r)=%0d/%0d last=%0d",
           tx_count, rx_count, exp_q.size(),
           s_axis_a_tvalid, s_axis_a_tready,
           s_axis_b_tvalid, s_axis_b_tready,
           m_axis_out_tvalid, m_axis_out_tready, m_axis_out_tlast);
  end

  //----------------------------------------------------------------------------
  // Main
  //----------------------------------------------------------------------------
  integer N;
  integer k;
  reg [SIZE-1:0] a;
  reg [SIZE-1:0] b;

  initial begin
    // init
    s_axis_a_tvalid = 1'b0;
    s_axis_b_tvalid = 1'b0;
    s_axis_a_tdata  = '0;
    s_axis_b_tdata  = '0;
    s_axis_a_tlast  = 1'b0;
    s_axis_b_tlast  = 1'b0;
    m_axis_out_tready = 1'b0;

    do_reset();
    $display("[TB] Reset done @ %0t", $time);

    fork
      run_sink();
    join_none

    // Define one packet length
    N = 20;

    // Send one packet of N beats
    for (k = 0; k < N; k = k + 1) begin
      a = {$urandom, $urandom, $urandom, $urandom};
      b = {$urandom, $urandom, $urandom, $urandom};

      // Mark TLAST only on final beat of the packet
      send_pair(a, b, (k == N-1), (k == N-1));
    end

    // Wait until we saw N outputs and scoreboard emptied
    wait (rx_count == N);
    wait (exp_q.size() == 0);

    repeat (10) @(posedge ap_clk);

    $display("[TB] PASS. Checked %0d outputs (N=%0d).", rx_count, N);
    $finish;
  end

endmodule
