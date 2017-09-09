module divider (
	input sys_clk,    
	input rst_n,  
	output reg uart_clk
);

parameter cnt_num =   325; // 100_1000_000 /153600 /2 -1;
	reg [31:0]cnt;

always @(posedge sys_clk or negedge rst_n) 
begin : proc_
	if(~rst_n) begin
		cnt <= 0;
		uart_clk <= 1;
	end else begin
		if(cnt < cnt_num) begin
			cnt <= cnt + 1;
		end
		else
		begin
			cnt <= 0;
			uart_clk <= ~ uart_clk;
		end
	end
end

endmodule