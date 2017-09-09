module receiver (
	input uart_clk,
	input rst_n,
	input uart_rxd,
	output reg [7:0]rf_data,
	output reg fr_wrreq
	
);

	reg [9:0]cnt;
	parameter EP = 184;


//要判断数据是否到达，到达之后怎么操作； 可以用状态机，可以用逻辑写
//产生节拍数


//状态机实现
// reg state;
// always @(posedge uart_clk or negedge rst_n) 
// begin : proc_
// 	if(~rst_n) begin
// 		 cnt<= 0;
// 		 state <= 0;
// 	end else begin
// 		 case(state)    
// 		 		0	: if(uart) begin
// 		 			/* code */
// 		 		end
// 		 endcase // state
// 	end
// end
// 0z状态 uart_rxd 为零  跳转1状态计数加一，否者还是0状态


//不用状态机写

	always @(posedge uart_clk or negedge rst_n) 
	begin : proc_1
		if(~rst_n) begin
			cnt <= EP;  
		end else begin
			if((!uart_rxd) && (cnt == EP) )   //  uart_rxd下降沿标志数据开始，并且cnt的到达终止符位，开始序列机的计数加一
				cnt <= 0;
				else if(cnt < EP) 
				cnt <= cnt +1;
				// else 
				// 	cnt <= 0;
		end
	end


//有问题，逻辑写反了
	// always @(posedge uart_clk or negedge rst_n) 
	// begin : proc_1
	// 	if(~rst_n) begin
	// 		cnt <= EP;  
	// 	end else begin
	// 		if((!uart_rxd) && (cnt == EP) ) begin   //  uart_rxd下降沿标志数据开始，并且cnt的到达终止符位，开始序列机的计数加一
	// 			if(cnt < EP) begin
	// 			cnt <= cnt +1;
	// 			end
	// 			else begin
	// 				cnt <= 0;
	// 			end
	// 		end
	// 	end
	// end





// //不用状态机写

// 	always @(posedge uart_clk or negedge rst_n) 
// 	begin : proc_1
// 		if(~rst_n) begin
// 			cnt <= EP;  
// 		end else begin
// 			if(rxd_flag) begin
// 				if(cnt < EP) begin
// 				cnt <= cnt +1;
// 				end
// 				else
// 				begin
// 					cnt <= EP;
// 				end
// 			end else begin
// 					cnt <= 0;
// 			end
// 		end
// 	end

// 	wire rxd_flag;
// 	always @(negedge uart_rxd ) 
// 	begin : proc_2
// 		if(~rst_n) begin
// 			rxd_flag <= 0;
// 		end else begin
// 			rxd_flag <= 1;
// 		end
// 	end

// //要判断数据是否到达，到达之后怎么操作
// 	always @(posedge uart_clk or negedge rst_n) 
// 	begin : proc_1
// 		if(~rst_n) begin
// 			cnt <= 0;
// 		end else begin
// 			if(cnt < EP) begin
// 				cnt <= cnt +1;
// 			end
// 			else
// 			begin
// 				cnt <= 0;
// 			end
// 		end
// 	end

always @(posedge uart_clk or negedge rst_n)
	begin : proc_3
		if(~rst_n) begin
			// cnt <= EP;
			rf_data <= 0;
			fr_wrreq <=0;
		end else begin
			 case(cnt)
			 	10 + 1*16	:	begin
			 					rf_data[0] <= uart_rxd;
			 					end
			 	10 + 2*16	:	begin
			 					rf_data[1] <= uart_rxd;
			 					end
			 	10 + 3*16	:	begin
			 						rf_data[2] <= uart_rxd;
			 					end
			 	10 + 4*16	:	begin
					 				rf_data[3] <= uart_rxd;
					 			end
			 	10 + 5*16	:	begin
					 				rf_data[4] <= uart_rxd;
					 			end
			 	10 + 6*16	:	begin
					 				rf_data[5] <= uart_rxd;
					 			end
			 	10 + 7*16	:	begin
					 				rf_data[6] <= uart_rxd;
					 			end
			 	10 + 8*16	:	begin
					 				rf_data[7] <= uart_rxd;
					 			end
			 	10 + 9*16	:	begin
					 				fr_wrreq <=1;    //写请求打开
					 			end
			 	10 + 9*16 +1	:	begin
					 				fr_wrreq <=0;     // 一个节拍就可以保证数据写入了
					 			end
			 	
			 	default : ;  //hold     后面到184中间差了一些节拍，后面可以不操作，可以直接一个分号
			 endcase
		end
	end


endmodule