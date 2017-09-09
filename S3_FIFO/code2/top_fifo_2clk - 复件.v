module top_fifo_2clk (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input key,
	output led_wr,
	output led_rd,
	output [2:0] sel,
	output [7:0] seg
);

	wire [7:0]data;
	wire [7:0]q;
	wire clk_1k;
	wire clk_10;
	wire rdreq;
	wire rdfull;
	wire rdempty;

	wire wrfull;
	wire wrempty;
	wire wrreq;

	// wire key_out;
		// filter_v2 inst_filter (
		// 	.clk     (clk_1k),
		// 	.rst_n   (rst_n),
		// 	.key_in  (key),
		// 	.key_out (key_out)
		// );



		freq inst_freq1k (
			.clk(clk), 
			.rst_n(rst_n), 
			.clk_1k(clk_1k)
			);

		freq #(.counter_num(2499999)) inst_freq10 (
			.clk(clk), 
			.rst_n(rst_n), 
			.clk_1k(clk_10));



	wr_fifo inst_wr_fifo
		(
			.clk     (clk_1k),
			.rst_n   (rst_n),
			.wrfull  (wrfull),
			.wrempty (wrempty),

			.key_out (key),
			.data    (data),
			.wrreq   (wrreq),
			.led_wr  (led_wr)
		);

	rd_fifo inst_rd_fifo
		(
			.clk     (clk_10),
			.rst_n   (rst_n),
			.rdfull  (rdfull),
			.rdempty (rdempty),
			.rdreq   (rdreq),
			.led_rd  (led_rd)
		);

	my_fifo inst_my_fifo
		(
			.data    (data),
			.rdclk   (clk_10),    //不同时钟
			.rdreq   (rdreq),
			.wrclk   (clk_1k),    //不同时钟
			.wrreq   (wrreq),
			.q       (q),
			.rdempty (rdempty),
			.rdfull  (rdfull),
			.wrempty (wrempty),
			.wrfull  (wrfull)
		);

	wire [3:0]hundreds;
	wire [3:0]tens;
	wire [3:0]ones;
	

	B2BCD inst_B2BCD (
		.binary_in(q), 
		.hundreds(hundreds), 
		.tens(tens), 
		.ones(ones)
		);

	seg7  inst_seg7 (
			.clk     (clk),
			.rst_n   (rst_n),
			.data_in ({4'd0,4'd0,4'd0,hundreds,tens,ones}),
			.sel     (sel),
			.seg     (seg)
		);


endmodule