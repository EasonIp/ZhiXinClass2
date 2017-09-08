
`timescale 1ns/1ps

module tb_top_vga_pic (); /* this is automatically generated */

	reg rst_n;
	reg clk;
	reg [1:0]key;
	wire vga_hs;
	wire vga_vs;
	wire [7:0]vga_rgb;
	// wire [12:0] address;
	top_vga_disp inst_top_vga_disp
		(
			.clk     (clk),
			.rst_n   (rst_n),
			.key     (key),
			.vga_hs  (vga_hs),
			.vga_vs  (vga_vs),
			.vga_rgb (vga_rgb)
		);



	// clock
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end

	// reset
	initial begin
		rst_n = 0;
		key=11;
		#20
		rst_n = 1;
		key = 2'b10;
		#4500000  key=11;
		//repeat (5) @(posedge clk);

	end

	// (*NOTE*) replace reset, clock, others

	

endmodule
