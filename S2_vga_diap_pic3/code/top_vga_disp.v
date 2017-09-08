module top_vga_disp (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [1:0]key,
	output vga_hs,
	output vga_vs,
	output [7:0]vga_rgb
	// output [15:0] address
	
);
	wire clk_40M;
	wire [15:0] address;
	wire [7:0]q;

	vga_control inst_vga_control (
			.clk     (clk_40M),
			.rst_n   (rst_n),
			.rom_out (q),
			.key     (key),
			.vga_hs  (vga_hs),
			.vga_vs  (vga_vs),
			.addr    (address),
			.vga_rgb (vga_rgb)
		);



	pll_vga inst_pll_vga (
		.areset(!rst_n), 
		.inclk0(clk), 
		.c0(clk_40M));

		// vga_control inst_vga_control (
		// 	.clk     (clk_40M),
		// 	.rst_n   (rst_n),
		// 	.rom_out (q),
		// 	.vga_hs  (vga_hs),
		// 	.vga_vs  (vga_vs),
		// 	.addr    (address),
		// 	.vga_rgb (vga_rgb)
		// );


	vga_rom inst_vga_rom (
		.address(address), 
		.clock(clk_40M),
		.q(q)
		);

endmodule