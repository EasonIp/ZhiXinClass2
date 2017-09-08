module filter_v2(clk, rst_n, key_in, key_out);

	input clk;				//系统时钟50MHZ
	input rst_n;			//低电平复位有效
	input key_in;			//低电平有效的独立按键

	output reg key_out;		//按键次数的计数
	
	reg state;				//定义的状态
	reg [24:0] count;		//定义的计数器（20ms）

	
	parameter cnt_num = 40_000_000 / 50 / 2 - 1;  //20ms  计数
	// parameter cnt_num = 5;
	
	always @ (posedge clk or negedge rst_n)
	begin
		if(!rst_n)      //复位时对reg信号赋初值
			begin
				state <= 0;
				count <= 25'd0;
				key_out <= 1;
			end	
		else	
			begin
				case(state)		//0状态表示按键按下，1状态表示按键抬起
					0	:	begin
								if(!key_in)
									begin
										if(count < cnt_num)
											begin
												count <= count + 1;
												
												state <= 0;
											end
										else
											begin
												count <= 0;
												key_out <= 0;   //稳定
												state <= 1;
											end
									end
								else
									begin
										state <= 0;
										count <= 25'd0;
										key_out <= 1;
									end
							end
							
					1	:	begin
								
								if(key_in)
									begin
										if(count < cnt_num)
											begin
												count <= count + 1;
												state <= 1;
												// flag <= 0;
											end	
										else
											begin
												count <= 0;
												key_out <= 1;
												state <= 0;
											end
									end
								else
									begin
										count <= 0;
										key_out <= 1;
										state <= 1;
									end
							end
						default	:	state <= 0;
				endcase
			end
	end
	

endmodule 
