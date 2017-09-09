module transmitter (
	input uart_clk,    
	input rst_n,  
	input tf_empty,  
	input [7:0]tf_data,  
	output reg tf_rdreq,
	output reg uart_txd
);

	reg [9:0]cnt;
	parameter EP = 192;

	always @(posedge uart_clk or negedge rst_n) 
	begin : proc_1
		if(~rst_n) begin
			cnt <= EP;
		end else begin
			if( (cnt >= EP) && (tf_empty == 0) ) begin
				cnt <= 0;
			end  else if(cnt < EP) begin
				cnt <= cnt +1;
			end 
			// else
			// 		begin
			// 			cnt <= EP;   //   ????
			// 		end
		end
	end

	reg [7:0]temp;
always @(posedge uart_clk or negedge rst_n) 
	begin : proc_
		if(~rst_n) begin
			// cnt <= EP;
			temp <= 0;
			tf_rdreq <= 0;
			uart_txd <= 1;
		end else if( (cnt >= EP )&& (tf_empty == 0) )
					tf_rdreq <= 1;
			else
		 begin
			 case(cnt)
			 	0	: 	begin
			 				tf_rdreq <= 0;
			 				uart_txd <= 0;
			 			end
			 	1	:	begin
			 			temp[7:0] <= tf_data[7:0];	
			 			end
			 	16	:	begin
			 			uart_txd <= temp[0];	
			 			end
			 	32	:	begin
			 			uart_txd <= temp[1];	
			 			end
			 	48	:	begin
			 			uart_txd <= temp[2];	
			 			end
			 	64	:	begin
			 			uart_txd <= temp[3];	
			 			end
			 	80	:	begin
			 			uart_txd <= temp[4];	
			 			end
			 	96	:	begin
			 			uart_txd <= temp[5];	
			 			end
			 	112	:	begin
			 			uart_txd <= temp[6];	
			 			end
			 	128	:	begin
			 				uart_txd <= temp[7];		
			 			end
			 	144	:	begin
			 				uart_txd <= 1;		
			 			end
			 	
			 	default: begin
			 					tf_rdreq <= 1;   //hold
			 			end
			 endcase
		end
	end



endmodule