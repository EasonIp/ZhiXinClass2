`timescale  1ns/1ps

module tb_lsm;

	reg clk,    // Clock

	reg rst_n,  // Asynchronous reset active low
	wire out;
	lsm inst_lsm (
		.clk(clk), 
		.rst_n(rst_n), 
		.out(out));


	initial
	clk =1;
	rst_n=0;
	#20 rst_n =1;

	#2000 $stop;
endmodule