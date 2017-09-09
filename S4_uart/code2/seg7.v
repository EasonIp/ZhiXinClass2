
module seg7(clk, rst_n, data_in, sel, seg);

	input 		clk;
	input 		rst_n;
	input 		[23:0] data_in;
	output reg 	[2:0] sel;
	output reg 	[7:0] seg;
	
	// input [5:0]turn_off;
//	parameter data_in = 24'h123456;
	
	
	reg [2:0] state;
	reg [3:0] data_temp;
	reg [31:0] count;
	reg clk_1khz;
	
	parameter T = 50_000_000/1000/2 - 1;
//	parameter T = 5;
	
	always @ (posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			begin
				count <= 32'd0;
				clk_1khz <= 0;
			end
		else
			begin
				if(count < T)
					count <= count + 1;
				else
					begin
						count <= 0;
						clk_1khz <= ~clk_1khz;
					end
			end
	end
	
	parameter s0 = 3'd0;
	parameter s1 = 3'd1;
	parameter s2 = 3'd2;
	parameter s3 = 3'd3;
	parameter s4 = 3'd4;
	parameter s5 = 3'd5;

	
	always @ (posedge clk_1khz or negedge rst_n)
	begin
		if(!rst_n)
			begin
				sel <= 3'd0;
				state <= s0;
				data_temp <= 4'd0;
			end
		else
			begin
				case(state)
					s0	:	begin
								sel <= 3'd0;
								data_temp <= data_in[23:20];
								state <= s1;
							end
				
					s1	:	begin
								sel <= 3'd1;
								data_temp <= data_in[19:16];
								state <= s2;
							end
							
					s2	:	begin
								sel <= 3'd2;
								data_temp <= data_in[15:12];
								state <= s3;
							end
							
					s3	:	begin
								sel <= 3'd3;
								data_temp <= data_in[11:8];
								state <= s4;
							end	
						
					s4	:	begin
								sel <= 3'd4;
								data_temp <= data_in[7:4];
								state <= s5;
							end
							
					s5	:	begin
								sel <= 3'd5;
								data_temp <= data_in[3:0];
								state <= s0;
							end
					default	:	state <= s0;
				endcase
			end
	end
	
		/*********数码管对应的译码***********/
	always @ (*)
	begin
		if(!rst_n)
			seg = 8'b1100_0000;
		else
			begin
				case(data_temp)
					4'd0	:	seg = 8'b1100_0000;
					4'd1	:	seg = 8'b1111_1001;
					4'd2	:	seg = 8'b1010_0100;
					4'd3	:	seg = 8'b1011_0000;
					
					4'd4	:	seg <= 8'b1001_1001;
					4'd5	:	seg <= 8'b1001_0010;
					4'd6	:	seg <= 8'b1000_0010;
					4'd7	:	seg <= 8'b1111_1000;
					
					4'd8	:	seg = 8'b1000_0000;
					4'd9	:	seg = 8'b1001_0000;
					4'd10	:	seg = 8'b1000_1000;
					4'd11	:	seg = 8'b1000_0011;
					
					4'd12	:	seg = 8'b1100_0110;
					4'd13	:	seg = 8'b1010_0001;
					4'd14	:	seg = 8'b1000_0110;
					4'd15	:	seg = 8'b1000_1110;
				endcase
			end
	end

endmodule 

