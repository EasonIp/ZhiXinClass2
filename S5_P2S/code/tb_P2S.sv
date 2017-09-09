
`timescale 1ns/1ps

module tb_P2S (); /* this is automatically generated */

	reg clk;    
	reg rst_n;  
	wire clk_en; 
	wire P2S_out;

	// clock
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end

	// reset
	initial begin
		rst_n = 0;
		#20
		rst_n = 1;
		
	end


endmodule
