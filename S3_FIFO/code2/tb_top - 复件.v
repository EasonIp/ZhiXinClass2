
`timescale 1ns/1ns

module tb_top (); /* this is automatically generated */

	reg rst_n;
	reg clk;
	reg key;

	wire led_wr;
	wire led_rd;
	wire [2:0] sel;
	wire [7:0] seg;


	top_fifo_2clk inst_top_fifo_2clk
		(
			.clk    (clk),
			.rst_n  (rst_n),
			.key    (key),
			.led_wr (led_wr),
			.led_rd (led_rd),
			.sel    (sel),
			.seg    (seg)
		);




	// clock
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end

	// reset
	initial begin
		rst_n = 0;
		key =1;
		#20
		rst_n = 1;
		#450000
		key = 0;		//按键按下第一次
		#45000000
		key= 1;		//按键第一次抬起s
		
	end

	// (*NOTE*) replace reset, clock, others

endmodule
