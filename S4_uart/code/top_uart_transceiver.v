module top_uart_transceiver (
	input clk,    // Clock  50Mhz
	input rst_n,  // Asynchronous reset active low
	input [7:0]tdata,
	input twrreq,
	output tfull, 
	input uart_rxd, 
	output uart_txd, 
	
	input rdreq,
	// output [7:0]rdata,
	output [2:0] sel,
	output [7:0] seg,
	output rdempty
);
	wire [7:0]rdata;


	wire sys_clk;
	wire uart_clk;

	uart_pll inst_uart_pll (
		.areset(!rst_n), 
		.inclk0(clk), 
		.c0(sys_clk));

	divider inst_divider (
		.sys_clk(sys_clk), 
		.rst_n(rst_n), 
		.uart_clk(uart_clk));

	// input	[7:0]  data;
	// input	  rdclk;
	// input	  rdreq;
	// input	  wrclk;
	// input	  wrreq;
	// output	[7:0]  q;
	// output	  rdempty;
	
	// input uart_clk,    
	// input rst_n, 
	// input uart_rxd,
	// output rf_data,
	// output fr_wrreq

	// wire rf_data;
	wire [7:0]rf_data;
	wire fr_wrreq;


	// rec_fifo inst_rec_fifo
	// 	(
	// 		.data    (rf_data),
	// 		.rdclk   (uart_clk),
	// 		.rdreq   (fr_wrreq),
	// 		.wrclk   (sys_clk),
	// 		.wrreq   (wrreq),
	// 		.q       (rdata),
	// 		.rdempty (rdempty)
	// 	);

	rec_fifo inst_rec_fifo
		(
			.data    (rf_data),
			.rdclk   (uart_clk),
			.rdreq   (1'b1),
			.wrclk   (sys_clk),
			.wrreq   (fr_wrreq),

			.q       (rdata),
			.rdempty ()
		);

	receiver inst_receiver
		(
			.uart_clk (uart_clk),
			.rst_n    (rst_n),
			.uart_rxd (uart_rxd),
			.rf_data  (rf_data),
			.fr_wrreq (fr_wrreq)
		);
 

	wire [3:0]hundreds;
	wire [3:0]tens;
	wire [3:0]ones;


	B2BCD inst_B2BCD (
		.binary_in(rdata), 
		.hundreds(hundreds), 
		.tens(tens), 
		.ones(ones));

	seg7 inst_seg7 (
			.clk     (clk),
			.rst_n   (rst_n),
			.data_in ({4'd0,4'd0,4'd0,hundreds,tens,ones}),
			.sel     (sel),
			.seg     (seg)
		);


	// wire tf_empty;  
	// wire [7:0]tf_data;  
	// wire tf_rdreq;



	// trans_fifo inst_trans_fifo
	// 	(
	// 		.data    (tdata),
	// 		.rdclk   (uart_clk),
	// 		.rdreq   (tf_rdreq),
	// 		.wrclk   (sys_clk),
	// 		.wrreq   (tf_rdreq),
	// 		.q       (tf_data),
	// 		.rdempty (tf_empty),
	// 		.wrfull  (tfull)
	// 	);
	// // input	[7:0]  data;
	// // input	  rdclk;
	// // input	  rdreq;
	// // input	  wrclk;
	// // input	  wrreq;
	// // output	[7:0]  q;
	// // output	  rdempty;
	// // output	  wrfull;

	// 	transmitter inst_transmitter
	// 	(
	// 		.uart_clk (uart_clk),
	// 		.rst_n    (rst_n),
	// 		.tf_empty (tf_empty),
	// 		.tf_data  (tf_data),
	// 		.tf_rdreq (tf_rdreq),
	// 		.uart_txd (uart_txd)
	// 	);

	// // input uart_clk,    
	// // input rst_n,  
	// // input tf_empty,  
	// // input [7:0]tf_data,  
	// // output tf_rdreq,
	// // output uart_txd

endmodule