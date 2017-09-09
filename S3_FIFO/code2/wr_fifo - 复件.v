module wr_fifo (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input wrfull,  
	input wrempty,
	input key_out,  
	output reg [7:0]data,  
	output reg wrreq,
	output led_wr
	
);
	// parameter Idel = 2'b00;
	// parameter WR = 2'b01;
	// parameter Empty = 2'b10;
	reg [1:0] current_stage;
	assign led_wr = (!wrfull)? 1'b1: 1'b0;

always @(posedge clk or negedge rst_n) begin : proc_
	if(~rst_n) begin
		data <= 0;
		wrreq <= 0;
		current_stage <= 2;
	end else begin
		 case (current_stage)
		 		0	:    //没有任何数据被写入时wrempty为真，fifo为空，跳转到写
		 				begin
		 					if(wrempty) begin
		 						data <= 0;
								wrreq <= 1;
		 						current_stage <= 1;
		 					end else begin
		 						current_stage <= 0;
		 					// 	data <= 0;
								// wrreq <= 1;
		 					end
		 				end
		 		1	:   //wrfull为真时fifo被写满
		 				begin
		 					if(!wrfull) begin
		 						wrreq <= 1;
		 						data <= data +1;
		 						current_stage <= 1;
		 						// if(data <255) begin
		 						// 	data <= data +1;
		 						// 	wrreq <= 1;
		 						// 	current_stage <= 1;
		 						// end else begin
		 						// 	data <= 0;
		 						// 	wrreq <= 1;
		 						// 	current_stage <= 1;
		 						// end
		 					end
		 					else begin
		 							current_stage <= 2;   //   按一次写一次
		 							wrreq <= 0;
		 							data <= 0;
		 					end
		 				end
		 		2	:
		 				begin
		 					if(!key_out) begin
		 						data <= 0;
								wrreq <= 0;
		 						current_stage <= 0;
		 					end
		 					else
		 						begin
		 						current_stage <= 2;
		 					   	end
		 				end
		 	default : current_stage <= 0;
		 endcase
	end
end

endmodule









// always @(posedge clk or negedge rst_n) begin : proc_
// 	if(~rst_n) begin
// 		data <= 0;
// 		wrreq <= 0;
// 		current_stage <= 0;
// 	end else begin
// 		 case (current_stage)
// 		 		0	:    //没有任何数据被写入时wrempty为真，fifo为空，跳转到写
// 		 				begin
// 		 					if(wrempty) begin
// 		 						data <= 0;
// 								wrreq <= 1;
// 		 						current_stage <= 1;
// 		 					end else begin
// 		 						current_stage <= 0;
// 		 					// 	data <= 0;
// 								// wrreq <= 1;
// 		 					end
// 		 				end
// 		 		1	:   //wrfull为真时fifo被写满
// 		 				begin
// 		 					if(!wrfull) begin
// 		 						wrreq <= 1;
// 		 						data <= data +1;
// 		 						current_stage <= 1;
// 		 						// if(data <255) begin
// 		 						// 	data <= data +1;
// 		 						// 	wrreq <= 1;
// 		 						// 	current_stage <= 1;
// 		 						// end else begin
// 		 						// 	data <= 0;
// 		 						// 	wrreq <= 1;
// 		 						// 	current_stage <= 1;
// 		 						// end
// 		 					end
// 		 					else begin
// 		 							current_stage <= 0;
// 		 							wrreq <= 0;
// 		 							data <= 0;
// 		 					end
// 		 				end

// 		 	default : current_stage <= 0;
// 		 endcase
// 	end
// end

// endmodule



// YT

// always @(posedge clk or negedge rst_n) begin : proc_
// 	if(~rst_n) begin
// 		data <= 0;
// 		wrreq <= 0;
// 		current_stage <= Idel;
// 	end else begin
// 		 case (current_stage)
// 		 		Idel	:
// 		 				begin
// 							current_stage <= Empty;
// 		 				end
// 		 		WR	:   //wrfull为真时fifo被写满
// 		 				begin
// 		 					if(!wrfull) begin
// 		 						if(data <255) begin
// 		 							data <= data +1;
// 		 							wrreq <= 1;
// 		 							current_stage <= WR;
// 		 						end else begin
// 		 							data <= 0;
// 		 							wrreq <= 1;
// 		 							current_stage <= WR;
// 		 						end
// 		 					end
// 		 					else begin
// 		 							current_stage <= WR;
// 		 							wrreq <= 0;
// 		 					end
// 		 				end
// 		 		Empty	:    //没有任何数据被写入时wrempty为真
// 		 				begin
// 		 					if(wrempty) begin
// 		 						data <= 0;
// 								wrreq <= 0;
// 		 						current_stage <= WR;
// 		 					end else begin
// 		 						current_stage <= WR;
// 		 					end
// 		 				end

// 		 	default : /* default */;
// 		 endcase
// 	end
// end
