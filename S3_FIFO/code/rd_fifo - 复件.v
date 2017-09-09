module rd_fifo (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input rdfull,  
	input rdempty,  
	output reg rdreq
	
);

	reg [1:0]current_stage;

	// parameter  RD = 2'b01;
	// parameter Idel = 2'b00;


	always @(posedge clk or negedge rst_n) 
	begin : proc_1
		if(~rst_n) begin
			 rdreq <= 0;
			 current_stage <= 0;
		end else begin
			case (current_stage)
				0 	: 	//判断读满
					begin
						if(rdfull) begin
							rdreq <= 1;
							current_stage <= 1;
						end             //零状态等待
						else begin
							rdreq <= 0;
							current_stage <= 0;
						end
					end
				1	:   //fifo被填充满，全部没有读出时，开始读数据，直到读完
					begin
						
							if(rdempty) begin
								rdreq <= 0;
								current_stage <= 0;
							end
							else begin      //
								rdreq <= 1;  //所有数据读完,关了之后跳转0状态等待
								current_stage <= 1;
							end
					end
				default : current_stage <= 0;
			endcase
		end
	end





endmodule