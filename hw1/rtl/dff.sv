module dff
  #(parameter [0:0] reset_val_p = 1'b0)
  (input [0:0] clk_i
  ,input [0:0] reset_i // positive-polarity, synchronous reset
  ,input [0:0] d_i
  ,input [0:0] en_i
  ,output [0:0] q_o);

   // Internal register.
   logic [0:0] q_r;
   // It is also possible to declare:
   // 
   // output logic [0:0] q_o
   // 
   // In the module ports declaration but I like that less since q_o
   // hides the fact that it is also a register.
   
   // This describes the internal FF behavior
   always_ff @(posedge clk_i) begin
      if(reset_i) begin // Positive, synchronous reset
	q_r <= reset_val_p;
      end else if (en_i) begin
	q_r <= d_i;
      end
   end

   // Connect the state element to the output
   assign q_o = q_r;
endmodule
