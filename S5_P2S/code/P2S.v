module P2S (
	input clk,    
	input rst_n,  
	output reg clk_en, 
	output reg P2S_out
	
);

	parameter P_data = 8'b1010_1010;

	reg [15:0]cnt;
	reg [7:0]temp;   //para_buff;

	always @(posedge clk or negedge rst_n) 
	begin : proc_1
		if(~rst_n) begin
			cnt <= 0;
		end else if(cnt < 7) begin
			cnt <= cnt + 1 ;
		end else cnt <= 0;
	end

// 给temp赋初值，左移和取值8次，然后从新开始取temp的值；
// 当有输出的时候给出clk_en的信息;

	always @(posedge clk or negedge rst_n) 
	begin : proc_2
		if(~rst_n) begin
			temp <= P_data;
			P2S_out <= 0;
			clk_en <= 0;
		end else if(cnt < 7 ) begin
			P2S_out <= temp[7] ;
			temp <= {temp[6:0],temp[7]};
			clk_en <= 1;
		end else begin
			temp <= P_data;
			P2S_out <= 0;
			clk_en <= 0;
		end
	end



endmodule