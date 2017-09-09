
`timescale 1ns/1ps

module tb_top_fifo (); /* this is automatically generated */

	reg rst_n;
	reg clk;
	wire [7:0] q;



	top_fifo inst_top_fifo (.clk(clk), .rst_n(rst_n), .q(q));




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

	// (*NOTE*) replace reset, clock, others

endmodule
