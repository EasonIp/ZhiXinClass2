//=============================================================================
//     spi_master 功能模块
// --------------------------
// 2015-11-28 LC V1.0
// 建立模块，定义16个寄存器，完成读写仿真
// 
//=============================================================================
module spi_master
    (
      input  clk, // 50MHz
      input  rst_n,
      input  rw,    //读开始信号
      input start,   //  开始信号，地址中写入数据；
      input  [3:0]addr,
      input  [19:0]wrdata,
      output reg rd_ok,sen,  //
      output reg [19:0]rddata,
      // output reg ss,
      output  sclk,
      inout  sdata
    );

//============================================================================= 

	reg [31:0]cnt_sclk;
	parameter Cnt_sclk = 50_000_000/2_000_000 /2 -1;  //   2M

  wire clk_1us,flag1,flag2;

  divider inst_divider (
      .clk     (clk),
      .rst_n   (rst_n),
      .clk_1us (clk_1us),
      .flag1   (flag1),
      .flag2   (flag2)
    );

  reg sdata_wr,sdata_rd,flag;

  reg [31:0]cnt;
  reg start_flag,sclk_en;




//产生线性序列机
always @(posedge clk or negedge rst_n) 
begin : proc_lsm_1
  if(~rst_n) begin
     sen <= 0;
     cnt <= 32'd0;
     flag <= 1;
     rd_ok <=0;
     start_flag <= 0;
     sclk_en <= 0;
  end else begin
     if(start) begin
       start_flag <= 1;
       sclk_en <= 1;
     end else
     if(start_flag && flag2) begin
       sen <= 1;
       cnt <= 0;
       flag <= 1;      //标记状态
       rd_ok <= 0;
       start_flag <= 0;
     end else
     if(flag2) begin        //第二个沿信号扫描
           if(!rw) begin  // !rd 写
              if(cnt>=25) begin
                cnt <= 27;
                sen <=0;
                sclk_en <= 0;
              end
              else if(cnt<25) begin
                cnt <= cnt +1;
                sen <= 1;
              end
           end // rd  读
           else if(rw) begin
             if(cnt >=27) begin
               sen <= 0;
               rd_ok <= 1;
               sclk_en <= 0;
             end else if(cnt<27) begin
               if(cnt == 4) begin
                 flag <= 0;
                 cnt <= cnt +1;
                 sen <= 1;
                 rd_ok <= 0;
               end
             end
           end
     end // flag2
  end  //else begin
end  //proc_lsm_1


wire out;

assign sclk = clk_1us & sclk_en;   //  sclk  1M时钟
assign out = (sdata_wr | sdata_rd) & sclk_en;
assign sdata = flag? out:1'bz;

always @(posedge clk or negedge rst_n) 
begin : proc_3
  if(~rst_n) begin
     sdata_wr<= 0;
     sdata_rd<= 0;
     rddata<= 20'd0;
  end else begin
     if(flag2) begin           // 第二个沿信号，输出
       begin : master_write
        case(cnt)
          0 : sdata_wr <= rw;
          1 : begin sdata_wr <= addr[3];sdata_rd <= addr[3];end
          2 : begin sdata_wr <= addr[2];sdata_rd <= addr[2];end
          3 : begin sdata_wr <= addr[1];sdata_rd <= addr[1];end
          4 : begin sdata_wr <= addr[0];sdata_rd <= addr[0];end
          5 : begin sdata_wr <= wrdata[19];sdata_rd <= 0;end
          6 : sdata_wr <= wrdata[18];
          7 : sdata_wr <= wrdata[17];
          8 : sdata_wr <= wrdata[16];
          9 : sdata_wr <= wrdata[15];
          10 : sdata_wr <= wrdata[14];
          11 : sdata_wr <= wrdata[13];
          12 : sdata_wr <= wrdata[12];
          13 : sdata_wr <= wrdata[11];
          14 : sdata_wr <= wrdata[10];
          15 : sdata_wr <= wrdata[9];
          16 : sdata_wr <= wrdata[8];
          17 : sdata_wr <= wrdata[7];
          18 : sdata_wr <= wrdata[6];
          19 : sdata_wr <= wrdata[5];
          20 : sdata_wr <= wrdata[4];
          21 : sdata_wr <= wrdata[3];
          22 : sdata_wr <= wrdata[2];
          23 : sdata_wr <= wrdata[1];
          24 : sdata_wr <= wrdata[0];
          default : ;
      endcase
       end
     end
    else if(flag1 & rw)                   //第一个沿信号 扫描；并且在读状态
      begin: master_read
        case(cnt)
          0 : ;
          1 : ;
          2 : ;
          3 : ;
          4 : ;
          5 : ;
          6 : ;
          7 : rddata[19] <= sdata;
          8 : rddata[18] <= sdata;
          9 : rddata[17] <= sdata;
          10 :rddata[16] <= sdata;
          11 :rddata[15] <= sdata;
          12 :rddata[14] <= sdata;
          13 :rddata[13] <= sdata;
          14 :rddata[12] <= sdata;
          15 :rddata[11] <= sdata;
          16 :rddata[10] <= sdata;
          17 :rddata[9] <= sdata;
          18 :rddata[8] <= sdata;
          19 :rddata[7] <= sdata;
          20 :rddata[6] <= sdata;
          21 :rddata[5] <= sdata;
          22 :rddata[4] <= sdata;
          23 :rddata[3] <= sdata;
          24 :rddata[2] <= sdata;
          25 :rddata[1] <= sdata;
          26 :rddata[0] <= sdata;
          default : ;
        endcase
      end
  end
end


endmodule // spi_master