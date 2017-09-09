
`timescale 1us/1ps

module tb_transmitter (); /* this is automatically generated */

	reg uart_clk;
	reg rst_n;
	reg tf_empty;  
	reg [7:0]tf_data;

	wire tf_rdreq;
	wire uart_txd;





`define  BPS 9600
`define  UART_CLK (`BPS * 16)
`define  TUART_CLK (1000_000 / `UART_CLK /2)
`define  HALF_TUART_CLK (`BPS * 16 /2)

`define TBPS (1000_000/`BPS)
`define UART_CLK10 (`UART_CLK *10)

	
	transmitter inst_transmitter (
			.uart_clk (uart_clk),
			.rst_n    (rst_n),
			.tf_empty (tf_empty),
			.tf_data  (tf_data),
			.tf_rdreq (tf_rdreq),
			.uart_txd (uart_txd)
		);

	// input uart_clk,    
	// input rst_n,  
	// input tf_empty,  
	// input [7:0]tf_data,  
	// output reg tf_rdreq,
	// output reg uart_txd


	reg [7:0]temp;

	// clock
	initial begin
		uart_clk = 0;
		forever #`TUART_CLK uart_clk = ~uart_clk;
	end

	// reset
	initial begin
		rst_n = 0;
		temp =0;
		tf_empty =1;
		tf_data =0;
		#200
		rst_n = 1;
		#200
		tf_empty =1;
		// #`UART_CLK10
		temp =8'h55;    //下面的时间要精确计算才能获得仿真的结果

		#`TBPS  tf_data[0] = temp[0];
		#`TBPS   tf_data[1] = temp[1];
		#`TBPS   tf_data[2] = temp[2];
		#`TBPS   tf_data[3] = temp[3];
		#`TBPS   tf_data[4] = temp[4];
		#`TBPS   tf_data[5] = temp[5];
		#`TBPS   tf_data[6] = temp[6];
		#`TBPS   tf_data[7] = temp[7];

		#`TBPS  tf_empty =0;

		#2000  $stop;
		
	end

	// (*NOTE*) replace reset, clock, others

	

endmodule
