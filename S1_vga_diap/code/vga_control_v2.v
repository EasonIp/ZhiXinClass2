module vga_control (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	output reg vga_hs,
	output reg vga_vs,
	output reg [7:0]vga_rgb
);


	parameter
	 A_hs=11'd128,//行显示的前场像素数
	 B_hs=11'd88,//行同步的像素数
	 C_hs=11'd40,//行显示的后场像素数
	 D_hs=11'd800,//行有效的像素个数
	 Total_hs = A_hs + B_hs + C_hs  + D_hs,
	 A_vs=10'd4,//列显示的前场行数
	 B_vs=10'd23,//列同步的行数
	 C_vs=10'd1,//列显示的后场行数
	 D_vs=10'd600,//列有效的行数
 	Total_vs = A_vs + B_vs + C_vs  + D_vs；

	reg [11:0] hs_counter;  //1056
	reg [11:0] vs_counter;   //行628

	//先进行列计数(行扫描)  然后行计数(列扫描)  
	//列计数1055后行才开始计数
	always @(posedge clk or negedge rst_n) 
	begin : proc_x
		if(~rst_n) begin
			hs_counter <= 12'b0;
		end else begin
			if(hs_counter == (Total_hs - 1) ) begin
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
			if(vs_counter <= (Total_vs-1) ) begin
				if(hs_counter == (H_TOTAL-1) ) begin
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
			end else if( (hs_counter == (Total_hs-1) ) && vs_counter == (A_vs-1) ) begin
				vga_vs <= 0;
			end else begin
				vga_hs <= 1;
				vga_vs <= 1;
			end
		end
	end

//显示区域的内容
//行 列同时在c段时显示rgb数据

// 彩条赋值
always @(posedge clk or negedge rst_n)
begin : proc_disp
	if(~rst_n) begin
		vga_rgb <= 8'd0;
	end else begin
			// if( (hs_counter >=217 && hs_counter <=1015) && (vs_counter >27 && vs_counter < 627) ) begin
			if( (hs_counter >=217 && hs_counter <=515) && (vs_counter >27 && vs_counter < 227) ) begin

				vga_rgb<= 8'b111_000_00;
			end else
			if( (hs_counter >515 && hs_counter <=815) && (vs_counter >=227 && vs_counter < 427) ) begin

				vga_rgb<= 8'b000_111_00;
			end else
			if( (hs_counter >815 && hs_counter <=1015) && (vs_counter >=427 && vs_counter < 627) ) begin

				vga_rgb<= 8'b000_000_11;
			end else
			begin
				vga_rgb<= 8'b000_000_00;
			end
	end
end


// 纯色赋值
// always @(posedge clk or negedge rst_n)
// begin : proc_disp
// 	if(~rst_n) begin
// 		vga_rgb <= 8'd0;
// 	end else begin
// 			if( (hs_counter >= (A_hs + B_hs -1) && hs_counter <= (A_hs + B_hs + C_hs) ) && (vs_counter > (A_vs + B_vs) && vs_counter < (A_vs + B_vs + C_vs) ) ) begin
// 				vga_rgb<= 8'b111_100_00;
// 			end
// 			else
// 			begin
// 				vga_rgb<= 8'b000_000_00;
// 			end
// 	end
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