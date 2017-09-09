`timescale  1ns/1ps
module tb_spi (
	
	
);

	reg  clk, // 50MHz
    reg  rst_n,
    reg  rw,
    reg start,
    reg  [3:0]addr,
    reg  [19:0]wrdata,
    wire rd_ok,  //
    wire [19:0]rddata

	top_spi inst_top_spi
		(
			.clk    (clk),
			.rst_n  (rst_n),
			.rw     (rw),
			.start  (start),
			.addr   (addr),
			.wrdata (wrdata),
			.rd_ok  (rd_ok),
			.rddata (rddata)
		);





initial
begin
	clk = 1;
	forever #1 clk = ~clk;
end


initial
begin
	rst_n = 0;
	repeat(10) @(posedge clk);
	@(posedge clk) rst_n <= 1;
end

initial
begin
	start =0;
	rw =0;
	addr = 0;
	wrdata = 0;

	repeat(200) @(posedge clk);

	@(posedge clk)
	begin
		rw = 0;
		addr =3;
		wrdata =20'h12345;
	end

	@(posedge clk) start =1;
	@(posedge clk) start =0;
	repeat(2000) @(posedge clk);

	@(posedge clk)
		begin 
			rw =1;
			addr =3;
		end
	@(posedge clk) start =1;
	@(posedge clk) start =0;

	#4000 $stop;

end

endmodule