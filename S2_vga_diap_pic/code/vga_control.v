module vga_control (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [7:0]rom_out,
	output reg vga_hs,
	output reg vga_vs,
	output reg [15:0]addr,
	output reg [7:0]vga_rgb
);

	reg [11:0] hs_counter;  //1056
	reg [11:0] vs_counter;   //行628


	//先进行列计数(行扫描)  然后行计数(列扫描)  
	//列计数1055后行才开始计数
	always @(posedge clk or negedge rst_n) 
	begin : proc_x
		if(~rst_n) begin
			hs_counter <= 12'b0;
		end else begin
			if(hs_counter == 1055) begin
				hs_counter <= 12'd0;
				end
			else 
				begin
				hs_counter <= hs_counter + 1;
				end
		end
	end

	always @(posedge clk or negedge rst_n) 
	begin : proc_2
		if(~rst_n) begin
			vs_counter <= 12'b0;
		end else begin
			if(vs_counter <= 627) begin
				if(hs_counter == 1055) begin
				vs_counter <= vs_counter + 1;
				end
				else
				vs_counter <= vs_counter;
			end
			else
				vs_counter <= 0;
		end
	end


	// always @(posedge clk or negedge rst_n) 
	// begin : proc_x
	// 	if(~rst_n) begin
	// 		hs_counter <= 12'b0;
	// 		vs_counter <= 12'b0;
	// 	end else begin
	// 		if(hs_counter == 1055) begin
	// 			vs_counter <= vs_counter + 1;
	// 			if(vs_counter == 627) begin
	// 				hs_counter <= 12'd0;
	// 				vs_counter <= 12'd0;
	// 			end
	// 		end else 
	// 			begin
	// 				hs_counter <= hs_counter + 1;
	// 				// if(vs_counter == 628) begin
	// 				// 	vs_counter <= 12'd1;
	// 				// end else begin
	// 				// 	vs_counter <= vs_counter;
	// 				// end
	// 			end
	// 	end
	// end


// 时序划分abcd，并给行列输出值

	always @(posedge clk or negedge rst_n) 
	begin : proc_hsvs
		if(~rst_n) begin
			vga_hs <= 1;
			vga_vs <= 1;
		end else begin
			if(hs_counter <= 127) begin
				vga_hs <= 0;
			end else if( (hs_counter == 1055) && vs_counter == 3) begin
				vga_vs <= 0;
			end else begin
				vga_hs <= 1;
				vga_vs <= 1;
			end
		end
	end
    // assign VGA_HS = x_counter > 839 && x_counter < 968;
    // assign VGA_VS = y_counter > 600 && y_counter < 605;



//显示区域的内容
//行 列同时在c段时显示rgb数据

// 图片220*180赋值
parameter edge0 = 217;
parameter edge1 = 217 +220-1;
parameter edge2 = 27 ;
parameter edge3 = 27+180-1;


always @(posedge clk or negedge rst_n)
begin : proc_disp
	if(~rst_n) begin
		vga_rgb <= 8'd0;
		addr <= 0;
	end else begin
			// if( (hs_counter >=217 && hs_counter <=1015) && (vs_counter >27 && vs_counter < 627) ) begin
			// if( (hs_counter >=edge0 && hs_counter <=edge1) && (vs_counter >=edge2 && vs_counter < edge3) ) begin
			if( (hs_counter >=edge0 && hs_counter <= edge1) && (vs_counter >=edge2 && vs_counter <= edge3) ) begin
				  //220*180
					if(addr == 39599) begin
							addr <= 0;
							vga_rgb <= rom_out; 
							 // vga_rgb <= 8'b100_000_00; 
					end else
							begin
							addr <= addr +1;
							vga_rgb <= rom_out; 
							end
			end else
			begin
				vga_rgb<= 8'b000_000_00;
				// vga_rgb <= rom_out; 
				addr <= addr;
			end
	end
end


// 纯色赋值
// always @(posedge clk or negedge rst_n)
// begin : proc_disp
// 	if(~rst_n) begin
// 		vga_rgb <= 8'd0;
// 	end else begin
// 			if( (hs_counter >=217 && hs_counter <=1015) && (vs_counter >27 && vs_counter < 627) ) begin
// 				vga_rgb<= 8'b111_100_00;
// 			end
// 			else
// 			begin
// 				vga_rgb<= 8'b000_000_00;
// 			end
// 	end
// end

	// reg value;

	// always @(*) 
	// begin : proc_220_180
	// 	if(!rst_n) begin
	// 		value = 0;
	// 	end else begin
	// 				if( (hs_counter >=edge0 && hs_counter <= edge1) && (vs_counter >=edge2 && vs_counter <= edge3) ) begin
	// 					value =1;
	// 				end
	// 				else  value =0
	// 			end
	// end



// always @(posedge clk or negedge rst_n)
// begin : proc_disp
// 	if(~rst_n) begin
// 		vga_rgb <= 8'd0;
// 	end else begin
// 			if( (hs_counter >=217 && hs_counter <=1015) || (vs_counter >=27 && vs_counter <= 627) ) begin
// 				vga_rgb<= 8'b111_100_00;
// 			end
// 			else
// 			begin
// 				vga_rgb<= 8'b000_000_00;
// 			end
// 	end
// end

endmodule