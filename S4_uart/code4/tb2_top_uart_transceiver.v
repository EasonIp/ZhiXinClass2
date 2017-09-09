
// `timescale 1us/1ps
`timescale 1ns/1ps

module tb2_top_uart_transceiver (); /* this is automatically generated */

	reg clk;    // Clock  50Mhz
	reg rst_n;  // Asynchronous reset active low
	reg [7:0]tdata;
	reg twrreq;
	reg rdreq;
	wire tfull;
	reg uart_rxd;
	wire uart_txd;
	// wire [7:0]rdata;
	wire [2:0] sel;
	wire [7:0] seg;
	wire rdempty;


	reg [3:0] row,
	output [3:0] col,

	input [7:0]tdata,
	input twrreq,
	output tfull,
	input uart_rxd,
	output uart_txd,
	
	input rdreq,
	output [7:0]rdata,
	// output [2:0] sel,
	// output [7:0] seg,
	output rdempty




`define  BPS 9600
`define  UART_CLK (`BPS * 16)    // 频率
`define  TUART_CLK (1000_000_000 / `UART_CLK /2)    //时间换算为1ns的单位
`define  HALF_TUART_CLK (`BPS * 16 /2)

`define TBPS (1000_000_000/`BPS)
`define UART_CLK10 (`UART_CLK *10)

	// clock
	initial begin
		clk = 0;
		forever #10  clk = ~clk;
	end


	reg  [7:0]temp;
	// reset
	initial begin
		uart_rxd = 1;
		rst_n = 0;
		temp =0;
		rdreq =1;
		#200
		rst_n = 1;

		#`UART_CLK10
		uart_rxd = 0;
		temp =8'h55;    //下面的时间要精确计算才能获得仿真的结果
		#`TBPS  uart_rxd = temp[0];
		#`TBPS  uart_rxd = temp[1];
		#`TBPS  uart_rxd = temp[2];
		#`TBPS  uart_rxd = temp[3];
		#`TBPS  uart_rxd = temp[4];
		#`TBPS  uart_rxd = temp[5];
		#`TBPS  uart_rxd = temp[6];
		#`TBPS  uart_rxd = temp[7];
		#`TBPS  uart_rxd = 1;
	end

	top_uart_transceiver inst_top_uart_transceiver
		(
			.clk      (clk),
			.rst_n    (rst_n),
			.row      (row),
			.col      (col),
			.tdata    (tdata),
			.twrreq   (twrreq),
			.tfull    (tfull),
			.uart_rxd (uart_rxd),
			.uart_txd (uart_txd),
			.rdreq    (rdreq),
			.rdata    (rdata),
			.rdempty  (rdempty)
		);



	// top_uart_transceiver inst_top_uart_transceiver
	// 	(
	// 		.clk      (clk),
	// 		.rst_n    (rst_n),
	// 		.tdata    (tdata),
	// 		.twrreq   (twrreq),
	// 		.tfull    (tfull),
	// 		.uart_rxd (uart_rxd),
	// 		.uart_txd (uart_txd),
	// 		.rdreq    (rdreq),
	// 		.sel      (sel),
	// 		.seg      (seg),
	// 		.rdempty  (rdempty)
	// 	);

endmodule
