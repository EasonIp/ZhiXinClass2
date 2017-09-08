// 产生时序的时序状态机


module lsm (
	input clk,    // Clock

	input rst_n,  // Asynchronous reset active low
	output out
	
);

	reg [2:0]cnt;
//产生节拍数
	always @(posedge clk or negedge rst_n) 
	begin : proc_
		if(~rst_n) begin
			cnt <= 0;
		end else begin
			 if(cnt < 7) begin
			 	cnt <= cnt +1;
			 end
			 else
			 cnt <= 0;
		end
	end

	always @(posedge clk or negedge rst_n) 
	begin : proc_2
		if(~rst_n) begin
			out <= 0;
		end else begin
			case(cnt)
				0	:	out <=1;    //上面的节拍数产生跳转
				1	:	out <=0;
				2	:	out <=1;
				4	:	out <=0;
				6	:	out <=1;

			endcase
		end
	end


endmodule