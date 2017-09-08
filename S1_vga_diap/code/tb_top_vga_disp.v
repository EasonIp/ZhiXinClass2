
`timescale 1ns/1ps

module tb_top_vga_disp (); /* this is automatically generated */

	reg clk;    // Clock
	reg rst_n;  // Asynchronous reset active low
	wire vga_hs;
	wire vga_vs;
	wire [7:0]vga_rgb;

	// clock
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end
	top_vga_disp inst_top_vga_disp (
		.clk(clk), 
		.rst_n(rst_n), 
		.vga_hs(vga_hs), 
		.vga_vs(vga_vs), 
		.vga_rgb(vga_rgb));


	// reset
	initial begin
		
		rst_n = 0;
		#20
		rst_n = 1;
		repeat (50_000_00) @(posedge clk);
		// $stop;
		
	end

endmodule
