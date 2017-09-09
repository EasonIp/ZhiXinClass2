module top_fifo (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	output [7:0]q
);

	wire [7:0]data;
	
	wire rdreq;
	wire rdfull;
	wire rdempty;

	
	wire wrfull;
	wire wrempty;
	wire wrreq;

	rd_fifo inst_rd_fifo (
			.clk     (clk),
			.rst_n   (rst_n),
			.rdfull  (rdfull),
			.rdempty (rdempty),
			.rdreq   (rdreq)
		);
		wr_fifo  inst_wr_fifo (
			.clk     (clk),
			.rst_n   (rst_n),
			.wrfull  (wrfull),
			.wrempty (wrempty),
			.data    (data),
			.wrreq   (wrreq)
		);

	my_fifo inst_my_fifo
		(
			.data    (data),
			.rdclk   (clk),    //同时钟
			.rdreq   (rdreq),
			.wrclk   (clk),    //同时钟
			.wrreq   (wrreq),
			.q       (q),
			.rdempty (rdempty),
			.rdfull  (rdfull),
			.wrempty (wrempty),
			.wrfull  (wrfull)
		);


endmodule