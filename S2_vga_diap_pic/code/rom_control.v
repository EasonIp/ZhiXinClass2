module rom_control (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	output reg [15:0]addr
	
);

	always @(posedge clk or negedge rst_n) 
	begin : proc_
		if(~rst_n) begin
			addr <= 0;
		end else begin
			if(addr <= 65536) begin
				addr <= 0;
			end else
				addr <= addr +1;
		end
	end

endmodule