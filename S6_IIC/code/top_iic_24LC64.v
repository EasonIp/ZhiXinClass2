module top_iic_24LC64 (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input key_wr,
	input key_rd,
	output [7:0]seg,
	output [2:0]sel,
	output led,
	output led2,
	output scl,
	inout sda
);

	wire [7:0]result;



	IIC_24LC64 inst_IIC_24LC64 (
			.clk    (clk),
			.rst_n  (rst_n),
			.key_wr (key_wr),
			.key_rd (key_rd),
			.scl    (scl),
			.sda    (sda),
			.led    (led),
			// .led2    (led2),
			.result (result)
		);


	seg7  inst_seg7 (
			.clk     (clk),
			.rst_n   (rst_n),
			.data_in ({4'd0,4'd0,4'd0,4'd0,result}),
			.sel     (sel),
			.seg     (seg)
		);

endmodule