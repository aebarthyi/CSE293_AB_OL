// Top-level design file for the icebreaker FPGA board

/* verilator lint_off PINMISSING */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSEDSIGNAL */
module top
  (input [0:0] clk_12mhz_i
  ,input [0:0] reset_n_async_unsafe_i

  ,output uart_tx_o
  ,input  uart_rx_i);

   wire clk_o;
   wire reset_n_sync_r;
   wire reset_sync_r;

   wire reset_r; // Use this as your reset_signal

   dff
     #()
   sync_a
     (.clk_i(clk_o)
     ,.reset_i(1'b0)
     ,.en_i(1'b1)
     ,.d_i(reset_n_async_unsafe_i)
     ,.q_o(reset_n_sync_r));

   inv
     #()
   inv
     (.a_i(reset_n_sync_r)
     ,.b_o(reset_sync_r));

   dff
     #()
   sync_b
     (.clk_i(clk_o)
     ,.reset_i(1'b0)
     ,.en_i(1'b1)
     ,.d_i(reset_sync_r)
     ,.q_o(reset_r));

  (* blackbox *)
  // 18.375 (18.432 requested)
  SB_PLL40_PAD 
    #(.FEEDBACK_PATH("SIMPLE")
     ,.PLLOUT_SELECT("GENCLK")
     ,.DIVR(4'b0000)
     ,.DIVF(7'b011000)
     ,.DIVQ(3'b101)
     ,.FILTER_RANGE(3'b001)
     )
   pll_inst
     (.PACKAGEPIN(clk_12mhz_i)
     ,.PLLOUTCORE(clk_o)
     ,.RESETB(1'b1)
     ,.BYPASS(1'b0)
     );     

    logic [31:0] s_axis_tdata;
    logic s_axis_tvalid, s_axis_tready, tx_busy, rx_busy;
    logic overrun_error, frame_error;

    uart_rx #(.DATA_WIDTH(32))
    uart_rx_inst(
        .clk(clk_o),
        .rst(reset_r),

        /*
        * AXI output
        */
        .m_axis_tdata(s_axis_tdata),
        .m_axis_tvalid(s_axis_tvalid),
        .m_axis_tready(s_axis_tready),

        /*
        * UART interface
        */
        .rxd(uart_rx_i),

        /*
        * Status
        */
        .busy(rx_busy),
        .overrun_error(overrun_error),
        .frame_error(frame_error),

        /*
        * Configuration
        */
        .prescale(16'd20)

    );

    uart_tx #(.DATA_WIDTH(32))
    uart_tx_inst(
        .clk(clk_o),
        .rst(reset_r),

        /*
        * AXI input
        */
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),

        /*
        * UART interface
        */
        .txd(uart_tx_o),

        /*
        * Status
        */
        .busy(tx_busy),

        /*
        * Configuration
        */
        .prescale(16'd20)
    );
endmodule
