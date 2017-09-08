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


	wire key_out0;
	wire key_out1;

	filter_v2  inst_filter_v2 (
			.clk     (clk_40M),
			.rst_n   (rst_n),
			.key_in  (key[0]),
			.key_out (key_out0)
		);

		filter_v2  inst_filter_v23 (
			.clk     (clk_40M),
			.rst_n   (rst_n),
			.key_in  (key[1]),
			.key_out (key_out1)
		);


	vga_control inst_vga_control (
			.clk     (clk_40M),
			.rst_n   (rst_n),
			.rom_out (q),
			.key     ({key_out1,key_out0}),
			.vga_hs  (vga_hs),
			.vga_vs  (vga_vs),
			.addr    (address),
			.vga_rgb (vga_rgb)
		);



	ppl_vga inst_pll_vga1 (
		.areset(!rst_n), 
		.inclk0(clk), 
		.c0(clk_40M)
		);

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