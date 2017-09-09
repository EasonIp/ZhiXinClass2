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
      input  start,
      input  rw,
      input  [3:0]addr,
      input  [19:0]wrdata,
      output reg rd_ok,  //
      output reg [19:0]rddata,
      output reg sen,
      output reg sclk,
      inout  sdata
    );

//============================================================================= 
  wire clk_1us, flag1, flag2;

  divider div_1(
    .clk(clk), 
    .rst_n(rst_n), 
    .clk_1us(clk_1us), 
    .flag1(flag1), 
    .flag2(flag2)
    );


  reg sdata_en,sclk_en;
  reg start_flag;
  reg sdata_wr,sdata_rd;

  assign sclk = clk_1us & sclk_en;

  assign out = (sdata_wr | sdata_rd) & sclk_en;  //半双工，同一时刻只能读或写
  assign sdata = sdata_en ? out : 1'bz;


// //  sclk_en
// always @(posedge clk or negedge rst_n) 
// begin : proc_sclk_en
//   if(~rst_n) begin
//      sclk_en <= 1'b0;
//   end else begin
//     if(start) begin
//       sclk_en <= 1'b1;
//     end else
//     if(NS = ) begin
//       /* code */
//     end
//   end
// end

end

  reg [4:0]CS,NS;
  parameter [4:0]S0=5'd0;
  parameter [4:0]S1=5'd1;
  parameter [4:0]S2=5'd2;
  parameter [4:0]S3=5'd3;
  parameter [4:0]S4=5'd4;
  parameter [4:0]S5=5'd5;
  parameter [4:0]S6=5'd6;
  parameter [4:0]S7=5'd7;

  always @(posedge clk or negedge rst_n)
  begin : proc_CS_NS
    if(~rst_n) begin
      CS <= S0;
    end else begin
      CS <= NS ;
    end
  end

  always @(*) 
  begin : proc_CS_transfer
        NS = S0;
        case(CS)
              S0  :
                  begin
                    if(start) begin
                          // start_flag = 1'b1;
                          // sclk_en = 1'b1;
                          NS = S1;
                    end
                  end
              S1  :// 读写R/W  1bit==
                  begin
                      if(start_flag && flag2) begin
                          sen <= 1'b1;
                          cnt <= 1'b0;

                          sdata_en <= 1'b1;
                          rd_ok <= 1'b0;
                          start_flag <= 1'b0;
                          NS = S2
                      end
                  end
              S2  : //写地址 4bit  == flag2
                  begin
                      if( (!rd) &&  ) begin
                          NS <= S3;
                         end
                      if(start_flag && rw) begin
                          NS = S6
                         end
                      if(start_flag && (!rw) ) begin
                          NS = S3
                         end
                  end
              S3  ://写数据20bit   ==flag2
                  begin
                      if(/* condition */) begin
                       NS = 
                      end
                  end
              // S4  :// 读  R/W
              // S5  : //地址  4bit
              S6  :  //data_ready  2 个sclk节拍  ==flag1
                  begin
                    if(flag1 && rw) begin
                          NS = S7;
                    end
                  end
              S7  : //读20bit    ==flag1
                  begin
                      if(flag1) begin
                           NS = S0;
                      end
                  end
              default: NS = S0;
        endcase
  end

  reg [4:0]shift_cnt;

always @(posedge clk or negedge rst_n) 
begin : proc_NS_output
  if(~rst_n) begin
        //输出赋初值
        sdata_wr <= 1'b0;
        sdata_rd <= 1'b0;
        rddata <= 20'b0;
        sen <= 1'b0;
        sdata_en = 1'b1;
        rd_ok <= 1'b0;   //输出用于仿真观察的信号
        // start_flag <= 1'b0;
        sclk_en <= 1'b0;
  end else begin
     case(NS)
          S0  :
              begin

              end
          S1  :// 读写R/W  1bit==
              begin
                sclk_en <= 1'b1;
              end
          S2  ://写地址 4bit  == flag2
              begin

              end
          S3  ://写数据20bit   ==flag2
              begin
                if( shift_cnt < 19 ) begin
                    sdata_en <= 1'b1;
                    sdata_wr <= wrdata[18 - shift_cnt];
                    shift_cnt <= shift_cnt +1;
                end else begin
                    shift_cnt <=0;

                end
              end
          S4  : 
              begin

              end
          // S5  : 
          //     begin

          //     end
          S6  : //data_ready  2 个sclk节拍  ==flag1
              begin
                sclk_en <= 1'b0;
                rd_ok <= 1'b1; 
              end

          S7  : //读20bit    ==flag1
              begin
                rd_ok <= 1'b1;
              end



    endcase
  end
end

endmodule // spi_master