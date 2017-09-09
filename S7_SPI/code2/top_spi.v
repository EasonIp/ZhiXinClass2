module top_spi (
	input  clk, // 50MHz
    input  rst_n,
    input  rw,
    input start,
    input  [3:0]addr,
    input  [19:0]wrdata,
    output rd_ok,  //
    output [19:0]rddata
);

	wire sclk;
	wire sdata;
	wire sen;

	spi_master inst_spi_master (
			.clk    (clk),
			.rst_n  (rst_n),
			// .ss     (ss),
			.addr   (addr),
			.wrdata (wrdata),
			.rd_ok  (rd_ok),
			.sen    (sen),
			.rddata (rddata),
			.sclk   (sclk),
			.sdata  (sdata)
		);

	spi_slave inst_spi_slave (
		.spi_ss(sen), 
		.spi_sclk(sclk), 
		.spi_sda(sdata)
		);





endmodule