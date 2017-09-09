
`timescale 1us/1ps

module tb_receiver (); /* this is automatically generated */

	reg uart_clk;
	reg rst_n;
	reg uart_rxd;
	wire [7:0]rf_data;
	wire fr_wrreq;

`define  BPS 9600
`define  UART_CLK (`BPS * 16)
`define  TUART_CLK (1000_000 / `UART_CLK /2)
`define  HALF_TUART_CLK (`BPS * 16 /2)

`define TBPS (1000_000/`BPS)
`define UART_CLK10 (`UART_CLK *10)

	
receiver inst_receiver (
			.uart_clk (uart_clk),
			.rst_n    (rst_n),
			.uart_rxd (uart_rxd),
			.rf_data  (rf_data),
			.fr_wrreq (fr_wrreq)
		);

	reg [7:0]temp;

	// clock
	initial begin
		uart_clk = 0;
		forever #`TUART_CLK uart_clk = ~uart_clk;
	end

	// reset
	initial begin
		uart_rxd = 1;
		rst_n = 0;
		temp =0;
		#200
		rst_n = 1;

		#200.1
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
		// #`TBPS  uart_rxd = 1;
	end

	// (*NOTE*) replace reset, clock, others

	

endmodule
