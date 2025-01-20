// Top-level design file for the icebreaker FPGA board

/* verilator lint_off PINMISSING */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off WIDTHEXPAND */

`timescale 1ns / 1ps

module uart_module
  (input [0:0] clk_i
  ,input [0:0] reset_r

  ,output uart_tx_o
  ,input  uart_rx_i);

  logic [7:0] s_axis_tdata;
  logic s_axis_tvalid, s_axis_tready, tx_busy, rx_busy;
  logic overrun_error, frame_error;

  uart_rx #(.DATA_WIDTH(8))
  uart_rx_inst(
      .clk(clk_i),
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
  ) ;

  uart_tx #(.DATA_WIDTH(8))
  uart_tx_inst(
      .clk(clk_i),
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
