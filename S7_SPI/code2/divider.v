// 产生 SPI时钟的上升沿和下降沿，第一个沿信号和第二个沿信号

module divider (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	output reg clk_1us,
	output reg flag1,
	output reg flag2
);

	parameter T1us = (25 -1);
	reg [15:0]cnt;
	always @(posedge clk or negedge rst_n) 
	begin : proc_clk_1us
		if(~rst_n) begin
			 cnt <= 0;
			clk_1us <= 0;
		end else begin
			if(cnt <= T1us) begin
				cnt <= cnt +1;

			end
			else
			begin
				cnt <= 0;
				clk_1us <= ~ clk_1us;
			end
		end
	end

	 reg [15:0]cnt2;
	 parameter P_cnt2= 50 -1;

	 always @(posedge clk or negedge rst_n) 
	 begin : proc_
	 	if(~rst_n) begin
	 		 flag1<= 1;
	 		 flag2<= 0;
	 		 cnt2 <= 0;
	 	end else begin
	 		 if(cnt2 >= P_cnt2) begin
	 		 	flag1 <= 1;
	 		 	cnt2 <= cnt2 + 1;
	 		 	if(cnt2 == T1us) begin
	 		 		 flag2 <= 1;
	 		 	end else begin
	 		 		flag2 <= 0;
	 		 	end

	 		 end
	 	end
	 end

endmodule