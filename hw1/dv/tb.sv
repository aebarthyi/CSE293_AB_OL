`timescale 1ns / 1ps

module tb;

  parameter real CLOCK_PERIOD = 54.253; // 18.432 MHz clock period
  parameter real HALF_PERIOD = CLOCK_PERIOD / 2.0;
  parameter time BAUD_PERIOD = 8681;

  logic clk;
  logic reset;

  logic in_data;
  logic out_data;

  initial begin
    clk = 0;
    forever #(HALF_PERIOD) clk = ~clk; 
  end
  
  uart_module dut(
    .clk_i(clk),
    .reset_r(reset),
    .uart_rx_i(in_data),
    .uart_tx_o(out_data)
  );
  
  /*
    top dut(
      .clk_12mhz_i(clk),
      .reset_n_async_unsafe_i(reset),
      .uart_tx_o(out_data),
      .uart_rx_i(in_data)
    );
  */

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars();
    $display("Starting Testbench...");
    $display("Testbench finished.");
    
    reset = 0;

    // Start sequence
    in_data = 1;
    #(CLOCK_PERIOD)
    in_data = 0; 
    #(BAUD_PERIOD);

    // Actual data bits
    in_data = 1; 
    #(BAUD_PERIOD);
    in_data = 0;
    #(BAUD_PERIOD);
    in_data = 1;
    #(5*BAUD_PERIOD);
    in_data = 0;
    #(BAUD_PERIOD);

    // Stop bit
    in_data = 1;
    #(BAUD_PERIOD);
    
    #(10*BAUD_PERIOD);

    // Start sequence
    in_data = 1;
    #(CLOCK_PERIOD)
    in_data = 0; 
    #(BAUD_PERIOD);

    // Actual data bits
    in_data = 0; 
    #(BAUD_PERIOD);
    in_data = 1;
    #(BAUD_PERIOD);
    in_data = 0;
    #(5*BAUD_PERIOD);
    in_data = 1;
    #(BAUD_PERIOD);

    // Stop bit
    in_data = 1;
    #(BAUD_PERIOD);

    #(10*BAUD_PERIOD);
    $finish;
  end
endmodule