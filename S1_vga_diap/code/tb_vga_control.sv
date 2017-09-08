
`timescale 1ns/1ps

module tb_vga_control (); /* this is automatically generated */

	reg rst_n;
	reg clk;
	wire vga_hs;
	wire vga_vs;
	wire vga_rgb[7:0];
	// clock
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end
	vga_control inst_vga_control (
		.clk(clk), 
		.rst_n(rst_n), 
		.vga_hs(vga_hs), 
		.vga_vs(vga_vs),
		.vga_rgb(vga_rgb)
		);

	// reset
	initial begin
		
		rst_n = 0;
		#20
		rst_n = 1;
		repeat (50000) @(posedge clk);
		$stop;
		
	end

	// (*NOTE*) replace reset, clock, others



endmodule
