module key_scan(clk, rst_n, row, col, flag, data);

	input clk;
	input rst_n;
	input [3:0] row;
	
	output reg [3:0] col;
	output reg flag;
	output reg [3:0] data;
	
	//分频1khz,时钟周期为1ms，为消抖做准备
	reg [31:0] counter;
	reg clk_1khz;
	
	parameter cnt_num = 50_000_000 / 1000 / 2 - 1;
	
	always @ (posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			begin
				counter <= 32'd0;
				clk_1khz <= 1'd0;
			end
		else
			begin
				if(counter < cnt_num)
					counter <= counter + 1;
				else
					begin
						counter <= 0;
						clk_1khz <= ~clk_1khz;
					end
			end
	end
	
	//矩阵键盘扫描电路
	reg [4:0] cnt_time;   //时间计数器
	reg [7:0] row_col;	//存储按键值
	reg [1:0] state;		//定义状态
	
	parameter s0 = 2'b00;
	parameter s1 = 2'b01;
	parameter s2 = 2'b10;
	
	always @ (posedge clk_1khz or negedge rst_n)
	begin
		if(!rst_n)
			begin
				cnt_time <= 5'd0;
				row_col <= 8'd0;
				state <= s0;
				col <= 4'b0000;
				flag <= 0;
			end
		else
			begin
				case(state)
					s0	:	begin
								if(row != 4'b1111)
									begin
										if(cnt_time < 19)
											begin
												cnt_time <= cnt_time + 1;
												flag <= 1'd0;
											end
										else
											begin
												cnt_time <= 0;
												col <= 4'b0111;
												state <= s1;
											end
									end
								else
									begin
										state <= s0;
										flag <= 1'd0;
									end
							end
					
					s1	:	begin
								if(row != 4'b1111)
									begin
										row_col <= {row,col};
										flag <= 1;
										col <= 4'b0000;	//用于判断按键是否被抬起
										state <= s2;
									end
								else
									begin
										col <= {col[0],col[3:1]};
										flag <= 0;
										state <= s1;
									end
							end
							
					s2	:	begin
								if(row == 4'b1111)
									begin
										if(cnt_time < 19)
											begin
												cnt_time <= cnt_time + 1;
												flag <= 0;
											end
										else
											begin
												flag <= 0;
												cnt_time <= 0;
												state <= s0;
												col <= 4'b0000;
											end
									end
								else
									begin
										cnt_time <= 0;
										flag <= 0;
										state <= s2;
									end
							end
					default	:	state <= s0;
				endcase
			end
	end
	
	always @ (*)
	begin
		if(!rst_n)
			data = 4'd0;
		else
			case(row_col)
				8'b1110_1110	:	data = 4'd0;
				8'b1110_1101	:	data = 4'd1;
				8'b1110_1011	:	data = 4'd2;
				8'b1110_0111	:	data = 4'd3;
				
				8'b1101_1110	:	data = 4'd4;
				8'b1101_1101	:	data = 4'd5;
				8'b1101_1011	:	data = 4'd6;
				8'b1101_0111	:	data = 4'd7;
				
				8'b1011_1110	:	data = 4'd8;
				8'b1011_1101	:	data = 4'd9;
				8'b1011_1011	:	data = 4'd10;
				8'b1011_0111	:	data = 4'd11;
				
				8'b0111_1110	:	data = 4'd12;
				8'b0111_1101	:	data = 4'd13;
				8'b0111_1011	:	data = 4'd14;
				8'b0111_0111	:	data = 4'd15;
			endcase
	end

endmodule
