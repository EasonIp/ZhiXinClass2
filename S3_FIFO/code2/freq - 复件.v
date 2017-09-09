// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2017 All rights reserve
// -----------------------------------------------------------------------------
// Author : yongchan jeon (Kris) poucotm@gmail.com
// File   : freq.v
// Create : 2017-07-22 21:39:18
// Editor : sublime text3, tab size (4), encoding(UTF-8)
// -----------------------------------------------------------------------------

module freq (clk,rst_n,clk_1k);
	input clk;    // Clock  50Mhz
	input rst_n;  // Asynchronous reset active low
	output reg clk_1k;

	reg [32:0] counter;    //定义大一点的范围，便于后面  #(.counter_num(24'd24999999 + 24'd24999999)) u1来参数传递复用模块freq
	parameter [32:0] counter_num = 50_000_000 / 1_000/ 2 -1;    //24_999   1KHZ clock
	always @(posedge clk or negedge rst_n) 
	begin : proc_1
		if(~rst_n) 
			begin
				 clk_1k <= 0;
				counter <= 16'd0;
			end 
		else 
			begin
				if(counter < counter_num ) 
					begin
						counter <= counter +1;

					end
				else
					begin
						counter <= 0;
						clk_1k <= ~clk_1k;
					end

			end
	end  //proc_1


endmodule