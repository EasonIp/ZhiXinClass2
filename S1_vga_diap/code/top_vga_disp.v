module top_vga_disp (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	output vga_hs,
	output vga_vs,
	output [7:0]vga_rgb
	
);
	wire clk_40M;

	vga_pll inst_vga_pll (
		.areset(!rst_n),
		.inclk0(clk), 
		.c0(clk_40M)
		);
	vga_control inst_vga_control (
		.clk(clk_40M), 
		.rst_n(rst_n), 
		.vga_hs(vga_hs), 
		.vga_vs(vga_vs), 
		.vga_rgb(vga_rgb)
		);



endmodule