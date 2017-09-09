
`timescale 1ns/1ps

module tb_IIC_24LC64 (); /* this is automatically generated */

	reg clk;    // Clock  50M
   	reg rst_n;  // Asynchronous reset active low
   	reg key_wr;
   	reg key_rd;
    wire scl;  //串行时钟信号
    wire  sda;  //
    wire led;    // led==0 亮表明数据写入完毕
    wire [7:0]result;

	// clock
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end

	// reset
	initial begin
		rst_n = 0;
		key_wr =1;
		key_rd =1;
		#200
		rst_n = 1;
		#50000  key_wr = 0;    //2560ns=390K
		# 16000 key_wr = 1;
		#75000 key_rd =0;   //kay_reg放在外面？
		#3000  key_rd =1;
		 // #300000  $stop;
		
	end


	IIC_24LC64_sim inst_IIC_24LC64_sim (
			.clk    (clk),
			.rst_n  (rst_n),
			.key_wr (key_wr),
			.key_rd (key_rd),
			.scl    (scl),
			.sda    (sda),
			.led    (led),
			.result (result)
		);

endmodule
